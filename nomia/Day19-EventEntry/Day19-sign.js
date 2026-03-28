
(async () => {
  const messageHash = "<0xb0dc8d3f25488fa6877930f123d6aae5cf3f909433c84203204d6fae5dd7954d>";
  const accounts = await web3.eth.getAccounts();
  const organizer = accounts[0]; // first account in Remix
  const signature = await web3.eth.sign(messageHash, organizer);
  console.log("Signature:", signature);
})();

//0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

//0x304098a1d2bdbab38b8659b332ea898a25574b28d43dffe8bcd1be41a3a9568a30956f4f560584329df20ea4aac081708d971b50831ece815f9bee3795922c8c1b