// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "erc721a/contracts/ERC721A.sol";  
import {DefaultOperatorFilterer} from "./DefaultOperatorFilterer.sol";


contract DreamWeave is ERC721A, ERC2981, Ownable, DefaultOperatorFilterer {

    uint256 public constant MAX_SUPPLY = 100000;
    uint256 public constant FREE_SUPPLY = 3;
    uint256 public constant PAID_SUPPLY = 10;

    uint256 private _flag;
    string private _defTokenURI = "https://ipfs.io/ipfs/QmWRqj2n9si6psZLmuvcvCK6DNSqPYkg7jFRoDUF1zCXPz";
    string private _baseTokenURI = "";

    mapping(address => bool) private _hasMinted;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() Ownable(msg.sender) ERC721A("DreamWeave", "DW") {
        _setDefaultRoyalty(msg.sender, 0);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981)
    returns (bool) {
      return super.supportsInterface(interfaceId);
    }

    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
    }

    function transferOut(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
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
        require(totalSupply() + quantity <= MAX_SUPPLY, "ERC721: Exceeds maximum supply");
        require(quantity == 1 || quantity == FREE_SUPPLY || quantity == PAID_SUPPLY, "ERC721: Invalid quantity");

        if (quantity <= FREE_SUPPLY ) {
            _safeMint(msg.sender,quantity);
        } else {
            require(msg.value >= 0.0001 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        }
        
        emit NewMint(msg.sender, quantity);
    }

}