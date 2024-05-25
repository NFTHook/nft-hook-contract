// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "erc721a/contracts/ERC721A.sol";


contract NFT721 is ERC721A, Ownable {

    uint256 public constant version = 1;
    uint256 public _unitPrice;
    uint256 private _unit3Price;
    string private _defTokenURI;
    address private _payeeAddr = 0x000000001c1e0572adc0D80f01bFafD9BC3b098E;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor(
        string memory name_,
        string memory symbol_,
        string memory defTokenURI_,
        uint256 unitPrice_,
        uint256 unit3Price_
    ) ERC721A(name_, symbol_) {
        _defTokenURI = defTokenURI_;
        _unitPrice = unitPrice_;
        _unit3Price = unit3Price_;
    }

    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
    }

    function transferOut() public {
        uint256 balance = address(this).balance;
        payable(address(_payeeAddr)).transfer(balance);
    }

    function transferAllERC20Out(address _tokenAddress) public {     
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to transfer");

        token.transfer(address(_payeeAddr), balance);
    }

    function changeDefURI(string calldata _tokenURI) external onlyOwner {
        _defTokenURI = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _defTokenURI;
    }

    receive() payable external {
    }

    function mint(uint256 quantity) public payable {
        require(quantity <= 3 || quantity == 10 || quantity == 100 || quantity == 200 || quantity == 500 , "ERC721: Invalid quantity");

        if (quantity == 1) {
            require(msg.value >= _unitPrice, "ERC721: Insufficient payment");
        } else if (quantity == 3) {
            require(msg.value >= _unit3Price, "ERC721: Insufficient payment");
        } else if (quantity == 100) {
            require(msg.value >= _unitPrice * 50, "ERC721: Insufficient payment");
        } else if (quantity == 200) {
            require(msg.value >= _unitPrice * 90, "ERC721: Insufficient payment");
        } else if (quantity == 500) {
            require(msg.value >= _unitPrice * 180, "ERC721: Insufficient payment");
        } else {
            require(msg.value >= _unitPrice * 6, "ERC721: Insufficient payment");
        }

        _safeMint(msg.sender, quantity);
        emit NewMint(msg.sender, quantity);
    }

}