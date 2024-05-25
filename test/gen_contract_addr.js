const bip39 = require('bip39');
const { hdkey } = require('ethereumjs-wallet');
const { ethers } = require('ethers');
// npx hardhat test ./test/gen_contract_addr.js
describe("计算合约地址", function () {

    async function findDesiredContractAddress() {
        let found = false;
        const desiredPrefix = '0x9527';
        const desiredPrefix1 = '0x0000';
        const desiredPrefix2 = '0x8888';
        const desiredPrefix3 = '0x6666';
        let deployerMnemonic, deployerPrivateKey, deployerAddress, contractAddress;

        while (!found) {
            // 生成助记词
            deployerMnemonic = bip39.generateMnemonic();
            // 从助记词生成种子
            const seed = await bip39.mnemonicToSeed(deployerMnemonic);
            // 从种子生成HD钱包
            const hdWallet = hdkey.fromMasterSeed(seed);
            // 获取第一个钱包
            const walletHdPath = "m/44'/60'/0'/0/0";
            const wallet = hdWallet.derivePath(walletHdPath).getWallet();
            // 获取私钥
            deployerPrivateKey = wallet.getPrivateKey().toString('hex');
            // 从私钥生成钱包地址
            deployerAddress = wallet.getAddressString()

            // 假设这是该地址的第一次交易（nonce为0）
            const nonce = 0n; // 使用BigInt
            contractAddress = getContractAddress(deployerAddress, nonce);

            // if (contractAddress.startsWith(desiredPrefix) || contractAddress.startsWith(desiredPrefix1) || contractAddress.startsWith(desiredPrefix2) || contractAddress.startsWith(desiredPrefix3)) {
                found = true;
            // }
        }
    
        console.log('符合条件的合约地址:', contractAddress);
        console.log('部署者助记词:', deployerMnemonic);
        console.log('部署者私钥:', deployerPrivateKey);
        console.log('部署者地址:', deployerAddress);
    }
    
    function getContractAddress(deployerAddress, nonce) {
        // 使用 ethers.utils.solidityPack 来编码地址和 nonce
        const input = ethers.solidityPacked(
            ['address', 'uint256'],
            [deployerAddress, nonce]
        );
    
        // 计算 keccak256 哈希值
        const contractAddressLong = ethers.keccak256(input);
        // 获取地址的最后 20 字节
        const contractAddress = '0x' + contractAddressLong.slice(-40);
        return contractAddress;
    }
    
    it("aaa", async function () {
        await findDesiredContractAddress()
    })
})