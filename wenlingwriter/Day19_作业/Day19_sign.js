
(async () => {
    const messageHash = "<0x375b3AEaBabB987D773EC50E61377cEe970436A3>";
    const accounts = await web3.eth.getAccounts();
    const organizer = accounts[0]; // first account in Remix
    const signature = await web3.eth.sign(messageHash, organizer);
    console.log("Signature:", signature);
  })();
  
  
