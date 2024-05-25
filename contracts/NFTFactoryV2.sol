// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFT721V2.sol";

contract NFTFactoryV2 is Ownable {

    address[] public deployedNFTs;
    event NFTCreated(address indexed nftAddress);
    event NFTMinted(address indexed nftAddress, address indexed minter, uint256 indexed quantity);

    function createNFT(
        string memory name,
        string memory symbol,
        string memory defTokenURI,
        uint256 unitPrice,
        uint256 unit3Price
    ) external{

        NFT721 newNFT = new NFT721(name, symbol, defTokenURI, unitPrice, unit3Price);

        deployedNFTs.push(address(newNFT));
        emit NFTCreated(address(newNFT));
    }

    // function changeDefURI(address contractAddr,string calldata _tokenURI) external onlyOwner {
    //     NFT721 nft = NFT721(payable(contractAddr));
    //     nft.changeDefURI(_tokenURI);
    // }

    function changeTokenURIFlag(address contractAddr,uint256 flag_,uint256 jsonNum_) external onlyOwner {
        NFT721 nft = NFT721(payable(contractAddr));
        nft.changeTokenURIFlag(flag_,jsonNum_);
    }

    function changeURI(address contractAddr,string calldata tokenURI_) external onlyOwner {
        NFT721 nft = NFT721(payable(contractAddr));
        nft.changeURI(tokenURI_);
    }

    function changeMS(address contractAddr,uint256 MAX_SUPPLY_) external onlyOwner {
        NFT721 nft = NFT721(payable(contractAddr));
        nft.changeMS(MAX_SUPPLY_);
    }

    function setPayeeAddress(address contractAddr,address newPayeeAddr) external onlyOwner {
        NFT721 nft = NFT721(payable(contractAddr));
        nft.setPayeeAddress(newPayeeAddr);
    }

    function transferOwnership(address contractAddr,address newOwner) external onlyOwner {
        NFT721 nft = NFT721(payable(contractAddr));
        nft.transferOwnership(newOwner);
    }

    function getDeployedLastNFTs() external view returns (address) {
        return deployedNFTs[deployedNFTs.length-1];
    }

    function getDeployedNFTs() external view returns (address[] memory) {
        return deployedNFTs;
    }

    function transferOut(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    function transferAllERC20Out(address _tokenAddress, address _to) public onlyOwner {
        require(_to != address(0), "Invalid recipient address");
        
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to transfer");
        
        token.transfer(_to, balance);
    }

    receive() payable external {
    }
}
