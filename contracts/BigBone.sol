// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";  

contract BigBone is ERC721A, Ownable {

    uint256 public constant MAX_SUPPLY = 5000;
    uint256 public constant FREE_SUPPLY = 2;
    uint256 public constant PAID_SUPPLY = 10;

    uint256 private _flag = 1;
    string private _defTokenURI = "";
    string private _baseTokenURI = "https://ipfs.io/ipfs/QmPCfYuV2ZuT92BTnGKckht9tqYPYHQCW8Ghc4zfR3Cykn/json/";

    mapping(address => bool) private _hasMinted;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() Ownable(msg.sender) ERC721A("Big Bone", "BGB") {
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
            return string(abi.encodePacked(_baseTokenURI, Strings.toString(tokenId),".json"));
        }
    }

    function mint(uint256 quantity) public payable {
        require(totalSupply() + quantity <= MAX_SUPPLY, "ERC721: Exceeds maximum supply");
        require(quantity == 1 || quantity == FREE_SUPPLY || quantity == PAID_SUPPLY || quantity == 100, "ERC721: Invalid quantity");

        if (quantity == 1 ) {
            require(msg.value >= 0.001 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else if (quantity == FREE_SUPPLY ) {
            _safeMint(msg.sender,quantity);
        } else if (quantity == 100 ) {
            require(msg.value >= 0.05 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else {
            require(msg.value >= 0.005 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        }
        
        emit NewMint(msg.sender, quantity);
    }

}