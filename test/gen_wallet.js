const bip39 = require('bip39');
const { hdkey } = require('ethereumjs-wallet');
const { ethers } = require('ethers');
// npx hardhat test ./test/gen_wallet.js 
async function generateWallet() {
    var r = true
    while(r){
        // 生成助记词
        const mnemonic = bip39.generateMnemonic();
        

        // 从助记词生成种子
        const seed = await bip39.mnemonicToSeed(mnemonic);
        
        // 从种子生成HD钱包
        const hdWallet = hdkey.fromMasterSeed(seed);
        
        // 获取第一个钱包
        const walletHdPath = "m/44'/60'/0'/0/0";
        const wallet = hdWallet.derivePath(walletHdPath).getWallet();
        
        // 获取私钥
        const privateKey = wallet.getPrivateKey().toString('hex');

        const addr = wallet.getAddressString()

        if (addr.startsWith("0x55555")) {
            console.log('私钥:', privateKey);
            console.log('助记词:', mnemonic);
            console.log('钱包地址:', wallet.getAddressString());
            r = false
        }

    }
}

generateWallet();
