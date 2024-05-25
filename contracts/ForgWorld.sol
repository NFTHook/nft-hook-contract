// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";  

contract Bone is ERC721A, Ownable {

    uint256 private _flag = 1;
    string private _defTokenURI = "";
    string private _baseTokenURI = "https://ipfs.io/ipfs/QmPCfYuV2ZuT92BTnGKckht9tqYPYHQCW8Ghc4zfR3Cykn/json/";
    address private _payeeAddr = 0x000000001c1e0572adc0D80f01bFafD9BC3b098E;


    mapping(address => bool) private _hasMinted;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() ERC721A("Bone", "Bone") {
    }

    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
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

            uint256 uriIndex = tokenId % 5000;

            return string(abi.encodePacked(_baseTokenURI, Strings.toString(uriIndex),".json"));
        }
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

    receive() payable external {
    }

    function mint(uint256 quantity) public payable {
        require(quantity <= 3 || quantity == 10 || quantity == 100 , "ERC721: Invalid quantity");

        if (quantity == 1) {
            _safeMint(msg.sender,quantity);
        } else if (quantity == 3 ) {
            require(msg.value >= 0.0000777 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else if (quantity == 100 ) {
            require(msg.value >= 0.00777 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        } else {
            require(msg.value >= 0.000777 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
        }
        
        emit NewMint(msg.sender, quantity);
    }

}