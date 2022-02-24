/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");

const {
  API_URL_RINKEBY,
  API_URL_ROBSTEN,
  API_URL_KOVAN,
  API_URL_BSC,
  API_URL_BTNET,
  API_URL_POLYGON,
  API_URL_MUMBAI,
  PRIVATE_KEY,
} = process.env;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.6",
      },
      {
        version: "0.6.12",
      },
      {
        version: "0.8.1",
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/ZcirrUeRRZ_B-aoZnzpk2GSsGJR1dXj4",
      },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    rinkeby: {
      url: API_URL_RINKEBY,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    robsten: {
      url: API_URL_ROBSTEN,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    kovan: {
      url: API_URL_KOVAN,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    bsc: {
      url: API_URL_BSC,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    btnet: {
      url: API_URL_BTNET,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mumbai: {
      url: API_URL_MUMBAI,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};
