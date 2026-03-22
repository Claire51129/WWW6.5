(async () => {
  const messageHash = "0xDA07165D4f7c84EEEfa7a4Ff439e039B7925d3dF";
  const accounts = await web3.eth.getAccounts();
  const organizer = accounts[0]; // first account in Remix
  const signature = await web3.eth.sign(messageHash, organizer);
  console.log("Signature:", signature);
})();