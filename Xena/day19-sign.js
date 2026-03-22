(async () => {
  const messageHash = "0xf9aca14df4c9b70b28f22b640a43867cde8e34cf1012d17d3ce3c6e0edcfe0be";
  const accounts = await web3.eth.getAccounts();
  const organizer = accounts[0]; // first account in Remix
  const signature = await web3.eth.sign(messageHash, organizer);
  console.log("Signature:", signature);
})();