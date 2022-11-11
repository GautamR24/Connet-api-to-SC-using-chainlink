require("@nomicfoundation/hardhat-toolbox");
require("dotenv");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/Pgda-GOHH0CHAfBH0jCmqfhvbwitCPp_",
      accounts: ["1ee7a3c28042920680fec6b7a45cbe20d9d891a4c7eaf8de121b694e06e8a05b"]
    }
  },
  etherscan: {
    apiKey: "BUVFYBCKRN3PB5QC9IIUU68DRTBD6R7WMS"

  },
};
