const hre = require("hardhat");
//npx hardhat run scripts/deploy_batch_trans.js --network sepolia
//https://sepolia.etherscan.io/
async function main() {
    const [owner] = await ethers.getSigners();

    // console.log(owner)

    const BatchTransfer = await ethers.getContractFactory("BatchTransfer");

    const gasLimit = 5000000;
    const gasPrice = ethers.parseUnits('3', 'gwei');

    const batchTransfer = await BatchTransfer.deploy({
      gasLimit: gasLimit,
      gasPrice: gasPrice
    });



    console.log("batchTransfer:",batchTransfer)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
