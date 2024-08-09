// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "erc721a/contracts/ERC721A.sol";  

contract BasicOptimism is ERC721A, Ownable {

    uint256 private _flag = 0;
    string private _defTokenURI = "https://ipfs.io/ipfs/QmQtwFrFi9NcG5UbHDUSaFo5uVb53TnFGrz23ozUuQKUoo";
    string private _baseTokenURI = "";
    address private _payeeAddr = 0x000000001c1e0572adc0D80f01bFafD9BC3b098E;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() Ownable(msg.sender) ERC721A("BasicOptimism", "BOM") {
    }

    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
    }

    function transferOut() public {
        uint256 balance = address(this).balance;
        payable(_payeeAddr).transfer(balance);
    }

    function transferAllERC20Out(address _tokenAddress) public {     
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to transfer");

        token.transfer(address(_payeeAddr), balance);
    }

    function changeTokenURIFlag(uint256 flag) external onlyOwner {
        _flag = flag;
    }

    function changeDefURI(string calldata _tokenURI) external onlyOwner {
        _defTokenURI = _tokenURI;
    }

    function changeURI(string calldata _tokenURI) external onlyOwner {
        _baseTokenURI = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (_flag == 0) {
            return _defTokenURI;
        } else {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
            return string(abi.encodePacked(_baseTokenURI, Strings.toString(tokenId)));
        }
    }

   function mint(uint256 quantity) public payable {
        _safeMint(msg.sender, quantity);
        emit NewMint(msg.sender, quantity);
    }

}