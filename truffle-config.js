require('dotenv').config();

const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    
   local: {
    host: "localhost",
    port: process.env.PORT,
    network_id: "*"
   },

   kovan: {
       provider: function() { 
        return new HDWalletProvider(process.env.MNEMONIC, process.env.WEB3_PROVIDER_ADDRESS);
       },
       network_id: 42,
       gas: process.env.GAS,
       gasPrice: process.env.GAS_PRICE,
   }
  }
 };
