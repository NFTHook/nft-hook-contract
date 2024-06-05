// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

contract ZREX is ERC721A, Ownable {

    uint256 public constant FREE_SUPPLY = 3;
    uint256 public constant PAID_SUPPLY = 10;

    uint256 private _flag;
    string private _defTokenURI = "https://ipfs.io/ipfs/QmXdMNFACfSxK21K8sntdgJ6eFwxkxKaBbyCxBW3ep4p3K";
    string private _baseTokenURI = "";

    mapping(address => bool) private _hasMinted;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() Ownable(msg.sender) ERC721A("Zrex", "ZRE") {
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
        require(quantity <= FREE_SUPPLY || quantity == PAID_SUPPLY || quantity == 100 || quantity == 200 || quantity == 500 , "ERC721: Invalid quantity");

        if (quantity < FREE_SUPPLY ) {
            require(msg.value >= 0.000013568 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else if (quantity == FREE_SUPPLY ) {
            require(msg.value >= 0.000001 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else if (quantity == 100 ) {
            require(msg.value >= 0.00088 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else if (quantity == 200 ) {
            require(msg.value >= 0.0016 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else if (quantity == 500 ) {
            require(msg.value >= 0.0044 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else {
            require(msg.value >= 0.000088 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        }
        
        emit NewMint(msg.sender, quantity);
    }

}