// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IERC20.sol";
import "../interface/IERC721.sol";
import "../interface/IERC1155.sol";

contract C2c is Ownable, ReentrancyGuard {

    struct NFTSale {
        address seller;
        address token;
        uint256 tokenId;
        uint256 price;
        address buyer;
        bool isERC1155;
        uint256 amount; // only for ERC1155
    }

    mapping(bytes32 => NFTSale) public nftSales;

    event NFTListed(address indexed seller, address indexed token, uint256 indexed tokenId, uint256 price, address buyer, bool isERC1155, uint256 amount);
    event NFTPurchased(address indexed buyer, address indexed seller, address indexed token, uint256 tokenId, uint256 price, bool isERC1155, uint256 amount);
    event NFTSaleCancelled(address indexed seller, address indexed token, uint256 indexed tokenId, bool isERC1155, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function listNFTForSale(
        address token,
        uint256 tokenId,
        uint256 price,
        address buyer,
        bool isERC1155,
        uint256 amount
    ) external nonReentrant {
        bytes32 saleId = keccak256(abi.encodePacked(msg.sender, token, tokenId, isERC1155, amount));
        require(nftSales[saleId].seller == address(0), "NFT is already listed");

        if (isERC1155) {
            IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        } else {
            IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        }

        nftSales[saleId] = NFTSale({
            seller: msg.sender,
            token: token,
            tokenId: tokenId,
            price: price,
            buyer: buyer,
            isERC1155: isERC1155,
            amount: amount
        });

        emit NFTListed(msg.sender, token, tokenId, price, buyer, isERC1155, amount);
    }

    function cancelNFTSale(
        address token,
        uint256 tokenId,
        bool isERC1155,
        uint256 amount
    ) external nonReentrant {
        bytes32 saleId = keccak256(abi.encodePacked(msg.sender, token, tokenId, isERC1155, amount));
        NFTSale memory sale = nftSales[saleId];
        require(sale.seller == msg.sender, "Only seller can cancel");

        if (sale.isERC1155) {
            IERC1155(sale.token).safeTransferFrom(address(this), msg.sender, sale.tokenId, sale.amount, "");
        } else {
            IERC721(sale.token).transferFrom(address(this), msg.sender, sale.tokenId);
        }

        delete nftSales[saleId];

        emit NFTSaleCancelled(msg.sender, sale.token, sale.tokenId, sale.isERC1155, sale.amount);
    }

    function purchaseNFT(
        address token,
        uint256 tokenId,
        bool isERC1155,
        uint256 amount
    ) external payable nonReentrant {
        bytes32 saleId = keccak256(abi.encodePacked(nftSales[saleId].seller, token, tokenId, isERC1155, amount));
        NFTSale memory sale = nftSales[saleId];
        require(sale.seller != address(0), "NFT is not listed for sale");
        require(sale.buyer == address(0) || sale.buyer == msg.sender, "Not authorized buyer");
        require(msg.value >= sale.price, "Insufficient payment");

        if (sale.isERC1155) {
            IERC1155(sale.token).safeTransferFrom(address(this), msg.sender, sale.tokenId, sale.amount, "");
        } else {
            IERC721(sale.token).transferFrom(address(this), msg.sender, sale.tokenId);
        }

        address payable recipient = payable(sale.seller);
        recipient.transfer(sale.price);

        delete nftSales[saleId];

        emit NFTPurchased(msg.sender, sale.seller, sale.token, sale.tokenId, sale.price, sale.isERC1155, sale.amount);
    }

    // 该函数允许合约接收以太
    receive() external payable {}

    function transferOut(address _payeeAddr) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_payeeAddr).transfer(balance);
    }

    function transferAllERC20Out(address _tokenAddress, address _payeeAddr) public onlyOwner {     
        IERC20 tokenObj = IERC20(_tokenAddress);
        uint256 balance = tokenObj.balanceOf(address(this));
        require(balance > 0, "No token balance to transfer");

        tokenObj.transfer(_payeeAddr, balance);
    }
}
