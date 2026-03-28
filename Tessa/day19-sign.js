// 用钱包帮主办方签名消息哈希
(async () => {    //这是一个“自动执行的函数”，程序一运行就会执行这个函数里的代码
  const messageHash = "<paste-your-hash-here>";   // 替换成你在 Remix 里看到的消息哈希
  const accounts = await web3.eth.getAccounts(); // 获取钱包里的账户列表
  const organizer = accounts[0]; // first account in Remix （管理者账号）
  const signature = await web3.eth.sign(messageHash, organizer);  // 使用管理者账号对消息哈希进行签名，得到签名字符串
  console.log("Signature:", signature);
})();

// 必须和你部署合约的账号一致
// 运行这个脚本后，你会在控制台看到一个签名字符串，把它复制下来，下一步我们会把它放到合约里验证
// 注意：这个签名字符串是基于消息哈希和管理者账号生成的，如果你换了消息哈希或者账号，签名字符串也会不同，所以一定要确保它们一致！
// messageHash（要签的内容）；organizer（谁签）