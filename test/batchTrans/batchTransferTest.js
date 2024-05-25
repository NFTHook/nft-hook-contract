const { time, loadFixture, } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

//npx hardhat run scripts/deploy.js --network polygonMumbai
//验证方式一
//npx hardhat flatten ./contracts/Contract.sol > ./flatten/Contract_zot_flatten.sol
//验证方式二
//npx hardhat verify --network goerli 0xdA35C2e65143262FfC2ef608Ad341821af55fb42
//npx hardhat test ./test/batchTrans/BatchTransferTest.js 

describe("BatchTransfer Test", function () {

  async function deploy() {  

    const QianJiNFT = await ethers.getContractFactory("QianJiNFT");
    const qianJiNFT = await QianJiNFT.deploy();

    const QianJiNFT1155 = await ethers.getContractFactory("QianJiNFT1155");
    const qianJiNFT1155 = await QianJiNFT1155.deploy();
      
    const BatchTransfer = await ethers.getContractFactory("BatchTransfer");
    const batchTransfer = await BatchTransfer.deploy();

    const [owner, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10] = await ethers.getSigners();

    return {batchTransfer, qianJiNFT, qianJiNFT1155, owner, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10};
  }

  it("执行批量转账给所有的人转相同的钱 batchTransferEqualAmount ", async function () {

    const { batchTransfer, owner, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10} = await loadFixture(deploy)

    const r1blc = await ethers.provider.getBalance(r1.address)
    const r2blc = await ethers.provider.getBalance(r2.address)
    const r3blc = await ethers.provider.getBalance(r3.address)
    const r4blc = await ethers.provider.getBalance(r4.address)
    const r5blc = await ethers.provider.getBalance(r5.address)
    const r6blc = await ethers.provider.getBalance(r6.address)
    

    const amount = ethers.parseEther("1");
    const totalAmount = amount * BigInt(6);
    
    // 执行批量转账操作
    const batchTrans = await batchTransfer.batchTransferEqualAmount(
      [r1.address, r2.address, r3.address,r4.address,r5.address,r6.address],
      amount,
      {
        value: totalAmount
      }
    );

    // 等待交易完成，并获取交易回执
    const txReceipt = await batchTrans.wait();

    // 输出消耗的gas数量
    console.log(`Gas Used for batchTransferEqualAmount: ${txReceipt.gasUsed.toString()}`);


    // 验证每个接收者的余额
    // 注意: 此检查可能不正确，因为直接查询余额可能没有考虑到其他因素如矿工费用等
    const balances = await Promise.all([
      ethers.provider.getBalance(r1.address),
      ethers.provider.getBalance(r2.address),
      ethers.provider.getBalance(r3.address),
      ethers.provider.getBalance(r4.address),
      ethers.provider.getBalance(r5.address),
      ethers.provider.getBalance(r6.address),
    ]);

    // console.log("转账后余额:",balances[0].toString(),"  ",(amount + r1blc).toString())

    expect(balances[0].toString()).to.equal((amount + r1blc).toString());
    expect(balances[1].toString()).to.equal((amount + r2blc).toString());
    expect(balances[2].toString()).to.equal((amount + r3blc).toString());
    expect(balances[3].toString()).to.equal((amount + r4blc).toString());
    expect(balances[4].toString()).to.equal((amount + r5blc).toString());
    expect(balances[5].toString()).to.equal((amount + r6blc).toString());
  });

  it("执行批量转账给所有的人转不同的钱 batchTransferVariableAmount ", async function () {

    const { batchTransfer, owner, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10} = await loadFixture(deploy)

    const r1blc = await ethers.provider.getBalance(r1.address)
    const r2blc = await ethers.provider.getBalance(r2.address)
    const r3blc = await ethers.provider.getBalance(r3.address)
    const r4blc = await ethers.provider.getBalance(r4.address)
    const r5blc = await ethers.provider.getBalance(r5.address)
    const r6blc = await ethers.provider.getBalance(r6.address)
    

    const amount = ethers.parseEther("1");
    const totalAmount = amount * BigInt(6);
    
    // 执行批量转账操作
    const batchTrans = await batchTransfer.batchTransferVariableAmount(
      [r1.address, r2.address, r3.address,r4.address,r5.address,r6.address],
      [amount, amount, amount, amount, amount, amount],
      {
        value: totalAmount
      }
    );

    // 等待交易完成，并获取交易回执
    const txReceipt = await batchTrans.wait();

    // 输出消耗的gas数量
    console.log(`Gas Used for batchTransferVariableAmount: ${txReceipt.gasUsed.toString()}`);


    // 验证每个接收者的余额
    // 注意: 此检查可能不正确，因为直接查询余额可能没有考虑到其他因素如矿工费用等
    const balances = await Promise.all([
      ethers.provider.getBalance(r1.address),
      ethers.provider.getBalance(r2.address),
      ethers.provider.getBalance(r3.address),
      ethers.provider.getBalance(r4.address),
      ethers.provider.getBalance(r5.address),
      ethers.provider.getBalance(r6.address),
    ]);

    // console.log("转账后余额:",balances[0].toString(),"  ",(amount + r1blc).toString())

    expect(balances[0].toString()).to.equal((amount + r1blc).toString());
    expect(balances[1].toString()).to.equal((amount + r2blc).toString());
    expect(balances[2].toString()).to.equal((amount + r3blc).toString());
    expect(balances[3].toString()).to.equal((amount + r4blc).toString());
    expect(balances[4].toString()).to.equal((amount + r5blc).toString());
    expect(balances[5].toString()).to.equal((amount + r6blc).toString());
  });

  it("批量转移ERC721代币给同一个人 batchTransferERC721TokenT1", async function () {
    const { batchTransfer, qianJiNFT, owner, r1, r2, r3 } = await loadFixture(deploy);

    // 铸造ERC721代币
    await qianJiNFT.mint(4);

    const receiver = r1.address;
    const tokenIds = [1,2,3];

    await qianJiNFT.setApprovalForAll(batchTransfer.target, true);

    // 批量转移ERC721代币
    const batchTrans = await batchTransfer.batchTransferERC721TokenT1(qianJiNFT.target, receiver, tokenIds);

    const txReceipt = await batchTrans.wait();


    console.log(`Gas Used for batchTransferERC721TokenT1: ${txReceipt.gasUsed.toString()}`);


    // 验证每个接收者的代币
    expect(await qianJiNFT.ownerOf(1)).to.equal(r1.address);
    expect(await qianJiNFT.ownerOf(2)).to.equal(r1.address);
    expect(await qianJiNFT.ownerOf(3)).to.equal(r1.address);
  });

  it("批量转移ERC721代币 batchTransferERC721Token", async function () {
    const { batchTransfer, qianJiNFT, owner, r1, r2, r3 } = await loadFixture(deploy);

    // 铸造ERC721代币
    await qianJiNFT.mint(4);

    const receivers = [r1.address, r2.address, r3.address];
    const tokenIds = [1,2,3];

    await qianJiNFT.setApprovalForAll(batchTransfer.target, true);

    // 批量转移ERC721代币
    const batchTrans = await batchTransfer.batchTransferERC721Token(qianJiNFT.target, receivers, tokenIds);

    const txReceipt = await batchTrans.wait();

    console.log(`Gas Used for batchTransferERC721Token: ${txReceipt.gasUsed.toString()}`);

    // 验证每个接收者的代币
    expect(await qianJiNFT.ownerOf(1)).to.equal(r1.address);
    expect(await qianJiNFT.ownerOf(2)).to.equal(r2.address);
    expect(await qianJiNFT.ownerOf(3)).to.equal(r3.address);
  });

  it("批量转移ERC1155代币", async function () {
    const { batchTransfer, qianJiNFT1155, owner, r1, r2, r3 } = await loadFixture(deploy);

    // 铸造ERC1155代币
    await qianJiNFT1155.mint(1,1000,"0x");
  
    await qianJiNFT1155.setApprovalForAll(batchTransfer.target, true);

    const receivers = [r1.address, r2.address, r3.address];
    const id = 1;
    const amounts = [1, 1, 1];

    // 批量转移ERC1155代币
    const batchTrans = await batchTransfer.batchTransferERC1155Token(qianJiNFT1155.target, receivers, id, amounts, "0x");

    const txReceipt = await batchTrans.wait();

    console.log(`Gas Used for batchTransferERC721Token: ${txReceipt.gasUsed.toString()}`);

    // 验证每个接收者的代币余额
    expect(await qianJiNFT1155.balanceOf(r1.address, 1)).to.equal(1);
    expect(await qianJiNFT1155.balanceOf(r2.address, 1)).to.equal(1);
    expect(await qianJiNFT1155.balanceOf(r3.address, 1)).to.equal(1);
  });

});
