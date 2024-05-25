// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract TigerMumNFT is ERC721Enumerable, Ownable {

    uint256 public constant MAX_SUPPLY = 899;
    uint256 public constant MAX_PARTNER = 100;
	uint256 public constant MINT_LIMIT = 2;

    bytes32 private merkleRootPre;
    bytes32 private merkleRootPartner;
    uint256 public immutable maxPublicAddressDuringMint = 2;
    uint256 public immutable maxPerAddressDuringMint = 2;
    uint256 public immutable maxPatnerAddressDuringMint = 1;

    bool private salePublic = false;
    bool private salePre = false;
    bool private salePartner = false;
    uint256 private allowListMintAmount = 500;
    uint256 private publicMintPrice = 0.05 ether;
    uint256 private preMintPrice = 0.01 ether;
    uint256 private partnerMintPrice = 0.1 ether;

    mapping(address => bool) public addressAppeared;
    mapping(address => uint256) public addressPublicMintStock;
    mapping(address => uint256) public addressPerMintStock;
    mapping(address => uint256) public addressPartnerMintStock;

    //structs
    struct _token {
        uint256 tokenId;
        string tokenURI;

    }

    //strings
    string currentContractURI = "";
    string baseURI = "https://ipfs.io/ipfs/QmbcUcYPaHiRtymf56b7g19iJBF3TpFXdQhHMDyrQKvyiV/";
    string suffix = ".json";

    constructor() ERC721("TigerMum", "TIGER") {
    }

    event NewSupply(uint256 totalSupply);

    function changeContractURI(string memory newContractURI)
        public onlyOwner
        returns (string memory)
    {
        currentContractURI = newContractURI;
        return (currentContractURI);
    }

    function contractURI() public view returns (string memory) {
        return currentContractURI;
    }

    function setSuffix(string memory suffix_) external onlyOwner {
        suffix = suffix_;
    }

    function _suffix() internal view virtual returns (string memory) {
        return suffix;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setAllowPreMerkle(bytes32 root_) external onlyOwner{
        merkleRootPre = root_;
    }

    function setAllowPartnerMerkle(bytes32 root_) external onlyOwner{
        merkleRootPartner = root_;
    }

    function setAllowPublicStatus(bool status) external onlyOwner {
        salePublic = status;
    }

    function setAllowPreStatus(bool status) external onlyOwner {
        salePre = status;
    }

    function setAllowPartnerStatus(bool status) external onlyOwner {
        salePartner = status;
    }

    function tokenURI(uint256 tokenId) public view override
        returns (string memory)
    {
        return string(abi.encodePacked(super.tokenURI(tokenId), suffix));
    }

    // function refundIfOver(uint256 price) private {
    //     require(msg.value >= price, "Need to send more ETH.");
    //     if (msg.value > price) {
    //         payable(msg.sender).transfer(msg.value - price);
    //     }
    // }

    function walletOfOwner(address _owner)
        public
        view
        returns (_token[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        //Create an array of token structs.
        _token[] memory _tokens = new _token[](tokenCount);

        for (uint256 i; i < tokenCount; i++) {
            uint256 _tokenId = tokenOfOwnerByIndex(_owner, i);
            string memory _tokenURI = tokenURI(_tokenId);
            _tokens[i] = _token(_tokenId, _tokenURI);
        }

        return _tokens;
    }

    function publicMint(uint256 quantity) external payable {
        require(tx.origin == msg.sender, "The caller is another contract");
        require(salePublic, "public sale has not begun yet");
        require(totalSupply() + quantity <= MAX_SUPPLY, "reached max supply");
        if(!addressAppeared[msg.sender]){
            addressAppeared[msg.sender] = true;
            addressPublicMintStock[msg.sender] = maxPerAddressDuringMint;
            addressPerMintStock[msg.sender] = maxPerAddressDuringMint;
            addressPartnerMintStock[msg.sender] = maxPerAddressDuringMint;
        }
        require(addressPublicMintStock[msg.sender] >= quantity, "reached public list per address mint amount");
        addressPublicMintStock[msg.sender] -= quantity;
        _safeMint(msg.sender, quantity);
        allowListMintAmount -= quantity;
        // refundIfOver(preMintPrice * quantity);
    }

    function perMint(uint256 quantity, bytes32[] memory proof) external payable {
        require(tx.origin == msg.sender, "The caller is another contract");
        require(salePre, "allowList sale has not begun yet");
        require(totalSupply() + quantity <= MAX_SUPPLY, "reached max supply");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, merkleRootPre, leaf), "Invalid Merkle Proof.");
        if(!addressAppeared[msg.sender]){
            addressAppeared[msg.sender] = true;
            addressPublicMintStock[msg.sender] = maxPerAddressDuringMint;
            addressPerMintStock[msg.sender] = maxPerAddressDuringMint;
            addressPartnerMintStock[msg.sender] = maxPerAddressDuringMint;
        }

        require(addressPerMintStock[msg.sender] >= quantity, "reached allow list per address mint amount");
        addressPerMintStock[msg.sender] -= quantity;
        _safeMint(msg.sender, quantity);
        allowListMintAmount -= quantity;
        // refundIfOver(preMintPrice * quantity);
    }

    function partnerMint(uint256 quantity, bytes32[] memory proof) external payable {
        require(tx.origin == msg.sender, "The caller is another contract");
        require(salePartner, "allowList sale has not begun yet");
        require(totalSupply() + quantity <= MAX_PARTNER, "reached max supply");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, merkleRootPartner, leaf), "Invalid Merkle Proof.");
        if(!addressAppeared[msg.sender]){
            addressAppeared[msg.sender] = true;
            addressPublicMintStock[msg.sender] = maxPerAddressDuringMint;
            addressPerMintStock[msg.sender] = maxPerAddressDuringMint;
            addressPartnerMintStock[msg.sender] = maxPerAddressDuringMint;
        }
        require(addressPartnerMintStock[msg.sender] >= quantity, "reached partner list per address mint amount");
        addressPartnerMintStock[msg.sender] -= quantity;
        _safeMint(msg.sender, quantity);
        allowListMintAmount -= quantity;
        // refundIfOver(partnerMintPrice*quantity);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdrawTo(address _owner) public onlyOwner{
        uint256 balance = address(this).balance;
        payable(_owner).transfer(balance);
    }
}