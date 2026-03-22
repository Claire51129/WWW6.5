(async () => {
  const messageHash = "0xf0b5ce1a22d79e0d815e8a5661de3a6a46b746c9e83f00b8ef751e6f1a3ea374";
  const accounts = await web3.eth.getAccounts();
  const organizer = accounts[0]; // first account in Remix
  const signature = await web3.eth.sign(messageHash, organizer);
  console.log("Signature:", signature);
})();