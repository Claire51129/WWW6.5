/**
 * Day19 — 组织者链下签名脚本（与 SignThis.sol 中 messageHash / personal_sign 规则一致）
 *
 * 用法:
 *   node day19_signScript.mjs --rpc <RPC_URL> --contract <合约地址> --attendee <参与者地址> --privateKey <组织者私钥>
 *
 * 可选: --json  仅输出一行 JSON（v/r/s/messageHash），便于脚本拼接
 */

import { ethers } from "ethers";

const MIN_ABI = [
  "function getMessageHash(address attendee) view returns (bytes32)",
  "function eventName() view returns (string)",
  "function organizer() view returns (address)",
];

function arg(name) {
  const i = process.argv.indexOf(name);
  if (i === -1 || !process.argv[i + 1]) return null;
  return process.argv[i + 1];
}

function die(msg) {
  console.error(msg);
  process.exit(1);
}

async function main() {
  const rpc = arg("--rpc");
  const contractAddr = arg("--contract");
  const attendee = arg("--attendee");
  const privateKey = arg("--privateKey");
  const jsonOnly = process.argv.includes("--json");

  if (!rpc || !contractAddr || !attendee || !privateKey) {
    die(
      "缺少参数。示例:\n  node day19_signScript.mjs --rpc https://sepolia.infura.io/v3/KEY --contract 0x... --attendee 0x... --privateKey 0x..."
    );
  }

  if (!ethers.isAddress(contractAddr) || !ethers.isAddress(attendee)) {
    die("--contract / --attendee 必须是合法地址");
  }

  const provider = new ethers.JsonRpcProvider(rpc);
  const wallet = new ethers.Wallet(privateKey, provider);
  const c = new ethers.Contract(contractAddr, MIN_ABI, provider);

  const onChainOrganizer = await c.organizer();
  if (onChainOrganizer.toLowerCase() !== wallet.address.toLowerCase()) {
    console.warn(
      `[警告] 链上 organizer=${onChainOrganizer}，当前私钥地址=${wallet.address}，签出的签名将无法通过合约校验。`
    );
  }

  const name = await c.eventName();
  const messageHashOnChain = await c.getMessageHash(attendee);

  // 本地复算，便于教学对照（须与链上 getMessageHash 一致）
  const messageHashLocal = ethers.solidityPackedKeccak256(
    ["address", "address", "string"],
    [attendee, contractAddr, name]
  );

  if (messageHashOnChain !== messageHashLocal) {
    die(
      `messageHash 不一致: 链上=${messageHashOnChain} 本地=${messageHashLocal}，请检查 RPC/合约地址/参与者地址。`
    );
  }

  // 与 MetaMask personal_sign( digest ) 一致：对 32 字节 digest 加 "\x19Ethereum Signed Message:\n32" 再 keccak 后 ECDSA 签名
  const signature = await wallet.signMessage(ethers.getBytes(messageHashOnChain));
  const sig = ethers.Signature.from(signature);

  const out = {
    messageHash: messageHashOnChain,
    v: sig.v,
    r: sig.r,
    s: sig.s,
    signature,
    organizer: wallet.address,
    contract: contractAddr,
    attendee,
    eventName: name,
  };

  if (jsonOnly) {
    console.log(
      JSON.stringify({
        messageHash: out.messageHash,
        v: out.v,
        r: out.r,
        s: out.s,
        signature: out.signature,
      })
    );
    return;
  }

  console.log("--- Day19 签名结果（交给任意账户发送 checkInWithSignature 即可）---");
  console.log("eventName:", name);
  console.log("messageHash:", messageHashOnChain);
  console.log("v:", sig.v);
  console.log("r:", sig.r);
  console.log("s:", sig.s);
  console.log("raw signature:", signature);
  console.log("\n合约调用参数示例 (ethers):");
  console.log(
    `checkInWithSignature("${attendee}", ${sig.v}, "${sig.r}", "${sig.s}")`
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
