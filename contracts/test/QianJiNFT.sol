// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";  
import "@openzeppelin/contracts/access/Ownable.sol";

contract QianJiNFT is ERC721A, Ownable {
    constructor()
        ERC721A("QianJiNFT", "QJNFT")
        Ownable(msg.sender)
    {}

    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
    }

    function mint(uint256 quantity) public {
        _safeMint(msg.sender, quantity);
    }
}