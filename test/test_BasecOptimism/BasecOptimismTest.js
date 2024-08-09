const { time, loadFixture, } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

//npx hardhat run scripts/deploy.js --network polygonMumbai
//验证方式一
//npx hardhat flatten ./contracts/Contract.sol > ./flatten/Contract_zot_flatten.sol
//验证方式二
//npx hardhat verify --network goerli 0xdA35C2e65143262FfC2ef608Ad341821af55fb42
//npx hardhat test ./test/batchTrans/BatchTransferTest.js 

describe("BasecOptimismTest test", function () {

  async function deploy() {  

    const NFT = await ethers.getContractFactory("BasicOptimism");
    const nft = await NFT.deploy();

    const [owner] = await ethers.getSigners();

    return {nft, owner};
  }

  it(" mint ", async function () {

    const { nft, owner} = await loadFixture(deploy)

    const trans = await nft.mint(1)

    const tx = await trans.wait();

    console.log(`Gas Used for batchTransferEqualAmount: ${tx.gasUsed.toString()}`);
    
  });

});
