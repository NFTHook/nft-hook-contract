// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";


contract ElementWorld is ERC721A {

    uint256 public constant version = 1;
    uint256 public _unitPrice;
    uint256 private _unit3Price;
    string private _tokenURI = "https://ipfs.io/ipfs/QmYBQNXdoL2nUMjtzhwXeqPkezvd5Liz98ZAwZyoY3cYiA/json/";
    address private _payeeAddr = 0x000000001c1e0572adc0D80f01bFafD9BC3b098E;
    mapping(uint256 => uint256) private tokenRandomNumbers;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() ERC721A("Elemental World", "EWD") {
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

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    
        uint256 uriIndex = tokenRandomNumbers[tokenId]; // 获取token的随机数字
        
        require(uriIndex >= 1 && uriIndex <= 199, "Invalid URI index");

        return string(abi.encodePacked(_tokenURI, Strings.toString(uriIndex), ".json"));
    }

    receive() payable external {
    }

    function mint(uint256 quantity) public payable {
        require(quantity <= 3 || quantity == 10 || quantity == 100 , "ERC721: Invalid quantity");

        if (quantity > 10) {
            require(msg.value >= 0.0005 ether, "ERC721: Insufficient payment");
        }

        uint256 tokenIdStart = totalSupply();
        _safeMint(msg.sender, quantity);

        for (uint256 i = 1; i <= quantity; i++) {
            uint256 randomNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i))) % 199) + 1;
            tokenRandomNumbers[tokenIdStart+i] = randomNumber;
        }

        emit NewMint(msg.sender, quantity);
    } 

}