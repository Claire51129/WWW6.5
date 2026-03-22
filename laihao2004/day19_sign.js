(async () => {
  const messageHash = "0xf0c8f2f39c5edaf0457b9ea5beb13a4c2e086f932403ab1a38d06a076e51093b";
  const accounts = await web3.eth.getAccounts();
  const organizer = accounts[0]; // first account in Remix
  const signature = await web3.eth.sign(messageHash, organizer);
  console.log("Signature:", signature);
})();
