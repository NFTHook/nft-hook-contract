require("@nomicfoundation/hardhat-toolbox");

const { ACCOUNTS,DISACCOUNTS,INFURA_KEY,GANACHE_ACCOUNTS,DEPLOY_ACCOUNT,ETHERSCAN_API_KEY,OPSCAN_API_KEY,BASESCAN_API_KEY } = require('./secrets.json');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.4.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.4.11",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: {
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: DEPLOY_ACCOUNT
    },
    DIS: {
      url: `https://rpc.dischain.xyz`,
      accounts: DISACCOUNTS
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: ACCOUNTS
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_KEY}`,
      accounts: ACCOUNTS
    },
    optimism: {
      url: `https://optimism-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: DEPLOY_ACCOUNT
    },
    arbitrum: {
      url: `https://arbitrum-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: ACCOUNTS
    },
    linea: {
      url: `https://linea-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: ACCOUNTS
    },
    zora: {
      url: `https://rpc.zora.energy`,
      accounts: ACCOUNTS
    },
    base: {
      url: `https://developer-access-mainnet.base.org`,
      accounts: ACCOUNTS
    },
    ganache: {
      url: `HTTP://127.0.0.1:8545`,
      accounts: GANACHE_ACCOUNTS
    }
  },
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_API_KEY,
      goerli: ETHERSCAN_API_KEY,
      optimisticEthereum: OPSCAN_API_KEY,
      base: BASESCAN_API_KEY
    },
    customChains: [
      {
        network: "zora",
        chainId: 7777777,
        urls: {
          apiURL: "https://explorer.zora.energy/api",
          browserURL: "https://explorer.zora.energy"
        }
      },
      {
        network: "dis",
        chainId: 513100,
      }
    ]
  },
};