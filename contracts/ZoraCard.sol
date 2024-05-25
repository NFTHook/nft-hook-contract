// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract ZoraCard is ERC721A {

    uint256 public constant version = 2;
    address private _payeeAddr = 0x000000001c1e0572adc0D80f01bFafD9BC3b098E;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() ERC721A("ZoraCard", "ZCD") {
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

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(_exists(tokenId_), "ERC721Metadata: URI query for nonexistent token");

        address ownerAddr = ownerOf(tokenId_);
        string memory balanceStr = weiToEther(getBalance(ownerAddr));
        return string(
            abi.encodePacked(
                '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
                ' <g> <title>Layer 1</title>',
                '<text transform="matrix(1.2241 0 0 2.22649 -45.3384 -342.291)" stroke="#000" font-weight="bold" font-style="normal" xml:space="preserve" text-anchor="start" font-family="Noto Sans JP" font-size="24" id="svg_1" y="240.67757" x="79.43699" stroke-width="0" fill="#000000">Balance</text>',
                '<text stroke-width="2" transform="matrix(1.12727 0 0 1.75429 -8.02419 -26.0385)" stroke="#f2f204" font-weight="bold" xml:space="preserve" text-anchor="start" font-family="Noto Sans JP" font-size="40" id="svg_3" y="60.62966" x="21.4341" fill="#4444d6">ZORA TO THE MOON</text>',
                '<text transform="matrix(1.99115 0 0 5.1187 -107.159 -947.588)" stroke="#57e212" xml:space="preserve" text-anchor="start" font-family="Noto Sans JP" font-size="24" id="svg_4" y="257.1258" x="93.49333" stroke-width="0" fill="#f9f900">',balanceStr,'</text>',
                '<text font-weight="bold" stroke="#000" xml:space="preserve" text-anchor="start" font-family="Noto Sans JP" font-size="15" id="svg_9" y="484" x="24" stroke-width="0" fill="#000000">NO.',uintToDecimalString(tokenId_),'</text>',
                ' </g> </svg>'
            )
        );
    }

    // Helper function to convert wei to ether with 4 decimal places
    function weiToEther(uint256 weiAmount) internal pure returns (string memory) {
        uint256 etherAmount = weiAmount / 1e18; // 1 ether = 1e18 wei
        uint256 decimals = etherAmount % 1e4; // Get the first 4 decimal places
        return string(abi.encodePacked(uintToStr(etherAmount), ".", uintToStr(decimals)));
    }

    // Helper function to convert uint to string
    function uintToStr(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp > 0) {
            temp /= 10;
            digits++;
        }
        bytes memory buffer = new bytes(digits);
        while (value > 0) {
            buffer[--digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // Function to get the balance of an address
    function getBalance(address addr) internal view returns (uint256) {
        return addr.balance;
    }

    function uintToDecimalString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 length;
        while (temp > 0) {
            temp /= 10;
            length++;
        }

        bytes memory buffer = new bytes(length);
        temp = value;
        for (uint256 i = length; i > 0; i--) {
            buffer[i - 1] = bytes1(uint8(48 + uint256(temp % 10)));
            temp /= 10;
        }

        return string(buffer);
    }

    receive() payable external {
    }

    function mint(uint256 quantity) public payable {
        _safeMint(msg.sender, quantity);
        emit NewMint(msg.sender, quantity);
    }

}