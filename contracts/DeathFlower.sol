// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract DeathFlower is ERC721A, Ownable {

    uint256 constant public TOTALSUPPLY = 6553500;
    uint256 constant public LIGHTSPEED = 0.0000299792458 ether;
    uint256 constant public FREE_SUPPLY = 3;
    uint256 constant public ONCE_MINT_SUPPLY_10 = 10;
    uint256 constant public ONCE_MINT_SUPPLY_100 = 100;
    uint256 constant public ONCE_MINT_SUPPLY_200 = 200;

    string private _baseUri = "https://ipfs.io/ipfs/QmVkyAJgd6xANVZYRxdhoTnkbapUTPQbYVaUZLSuX3sn67/";
    address public wishLogic;
    uint256 public cbflag = 0;

    mapping(address => uint256) public wishedLights;
    mapping(address => bool) public wishImpled;
    address public reqdev;

    constructor(address _reqdev) Ownable(msg.sender) ERC721A("Death Flower", "DFR") {
        require(_reqdev != address(0), "Invalid Req Address");
        reqdev = _reqdev;
    }

    function wishToLights(uint256 wishTimes) external payable {
        require(totalSupply() + wishTimes <= TOTALSUPPLY, "ERC721: Exceeds maximum supply");
        if(wishTimes != FREE_SUPPLY) {
            if(wishTimes == ONCE_MINT_SUPPLY_10) {
                require(msg.value == LIGHTSPEED * 10, "invalid light speed amount");
            } else if(wishTimes == ONCE_MINT_SUPPLY_100) {
                require(msg.value == LIGHTSPEED * 60, "invalid light speed amount");
            } else if(wishTimes == ONCE_MINT_SUPPLY_200) {
                require(msg.value == LIGHTSPEED * 100, "invalid light speed amount");
            } else {
                require(msg.value == LIGHTSPEED * wishTimes, "invalid light speed amount");
            }
        }

        _mint(msg.sender, wishTimes);
        wishedLights[msg.sender] += wishTimes;

        emit WishMake(msg.sender, wishTimes);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if(cbflag==1) {
            require( _exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
            return string(abi.encodePacked(_baseUri, Strings.toString(tokenId)));
        }
        return _baseURI();
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUri;
    }

    function changeBaseURI(string calldata _newBaseUri, uint256 _cbflag) external onlyOwner {
        _baseUri = _newBaseUri;
        cbflag = _cbflag;
    }

    function modifyWishLogic(address _newLogic) external onlyOwner {
        require(_newLogic != address(0));
        wishLogic = _newLogic;
    }

    function implementMyWish() external payable {
        require(wishLogic != address(0), "not in time");

        uint256 wishTimes = wishedLights[msg.sender];
        require(wishTimes > 0, "not exist code");
        require(!wishImpled[msg.sender], "wish had been implemented");


        (bool exeResult, ) = address(wishLogic).call{value:msg.value}(abi.encodeWithSignature("implementMyWish(uint256)", wishTimes));
        require(exeResult, "oops, wish implement failed.");
        wishImpled[msg.sender] = true;

        emit WishImplemented(msg.sender, wishTimes);
    }

    function wd() external {
        payable(reqdev).transfer(address(this).balance);
    }

    receive() external payable {}

    event WishMake(address indexed minter, uint256 wishTimes);
    event WishImplemented(address indexed minter, uint256 wishTimes);
}