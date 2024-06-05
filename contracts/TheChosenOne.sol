// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";  

contract TheChosenOne is ERC721A, Ownable {

    uint256 public constant ROUND_COUNT = 16;
    uint256 public constant ROUND_FEE = 50;
    uint256 public constant INVITE_SHARE = 10;

    uint256 public constant FREE_SUPPLY = 3;
    uint256 public constant PAID_SUPPLY = 10;

    uint256 public currentRound = 1;
    bool public roundSettling = false;
    address public devTreater;

    mapping(uint256 => address[]) public roundParticipants;
    mapping(uint256 => address[]) public roundWinner;
    mapping(uint256 => uint256) public roundPrize;
    mapping(uint256 => uint256) public roundWinCode;

    event RoundJoin(uint256 indexed round, address indexed inviter, uint256 seq);
    event RoundWinner(uint256 indexed round, uint256 count, address[] users);

  
    string private _defTokenURI = "https://ipfs.io/ipfs/QmY9zSvzzUirpSSMksDbyvyuRN82pqoRD2pGQAAV78317S";

    mapping(address => bool) private _hasMinted;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() Ownable(msg.sender) ERC721A("TheChosenOne", "TCO") {
    }

    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
    }

    function transferOut(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    function changeTokenURIFlag(address _devTreater) external onlyOwner {
        devTreater = _devTreater;
    }

    function changeDefURI(string calldata _tokenURI) external onlyOwner {
        _defTokenURI = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _defTokenURI;
    }

    modifier isSettling() {
        require(!roundSettling, "Forbid join while settling");
        _;
    }

    struct RoundInfo {
        uint256 index;
        address[] users;
        uint256 prize;
        address[] winners;
        uint256 wincode;
    }

    function currentRoundInfo() view public returns(RoundInfo memory data) {
        data.index = currentRound;
        data.users = roundParticipants[currentRound];
        data.prize = roundPrize[currentRound];
    }

    function historyRoundInfo(uint256 _hisRound) view public returns(RoundInfo memory data) {
        data.index = _hisRound;
        data.winners = roundWinner[_hisRound];
        data.prize = roundPrize[_hisRound];
        data.users = roundParticipants[_hisRound];
        data.wincode = roundWinCode[_hisRound];
    }

    function _pickWinner() internal {
        if(roundParticipants[currentRound].length == ROUND_COUNT) {
            roundSettling = true;
            uint256 comw = uint256(keccak256(
                abi.encodePacked(currentRound, block.timestamp, blockhash(block.number - 1))
            )) % ROUND_COUNT;
            
            address[] memory winners = new address[](ROUND_COUNT);
            uint256 winnerCount = 0;

            roundWinCode[currentRound] = comw;  // record success code
            for(uint256 i=0; i < roundParticipants[currentRound].length; i++) {
                if(testCode(roundParticipants[currentRound][i], comw)) {
                    winnerCount++;
                    winners[i] = roundParticipants[currentRound][i];
                }
            }
            // delete roundParticipants[currentRound];  //save all participants data
            _distributePrize(winnerCount, winners);            
            currentRound++;
            roundSettling = false;
        }
    }

    function _distributePrize(uint256 _count, address[] memory _winners) private {
        uint256 winnerPrize = roundPrize[currentRound];
        if(devTreater != address(0)) {
            payable(devTreater).transfer( winnerPrize * ROUND_FEE / 100);
            winnerPrize = winnerPrize * (100 - ROUND_FEE) / 100;
        }
        if(_count==0) {
            roundPrize[currentRound] = 0;
            roundPrize[currentRound + 1] += winnerPrize;
        } else {
            uint256 eachPrize = winnerPrize / _count;
            for(uint256 i=0; i < _winners.length; i++) {
                if(_winners[i] != address(0)) {
                    roundWinner[currentRound].push(_winners[i]);
                    bool transVal = _secTransfer(_winners[i], eachPrize);
                    if(!transVal) {
                        roundPrize[currentRound + 1] += (eachPrize);  //to cumulate prize to next round when bad contract 
                    }
                }
            }
            emit RoundWinner(currentRound, _count, _winners);
        }
    }

    function _secTransfer(address target, uint256 amount) private returns(bool) {
        (bool result,) = payable(target).call{value: amount, gas: 50_000}("");
        return result;
    }

    receive() payable external {
        if(currentRound > 0) {
            roundPrize[currentRound] += msg.value;
        }
    }

    function testCode(address wallet, uint256 comw) pure public returns(bool) {
        return uint8(comw) == uint8(uint160(wallet) % ROUND_COUNT);
    }

    function mint(uint256 quantity) public payable {
        require(quantity <= FREE_SUPPLY || quantity == 10 || quantity == 100 || quantity == 200, "ERC721: Invalid quantity");

        if (quantity <= FREE_SUPPLY ) {
            _safeMint(msg.sender,quantity);
        } else if (quantity == 100 ) {
            require(msg.value >= 0.000888 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
            roundParticipants[currentRound].push(msg.sender);
            roundParticipants[currentRound].push(msg.sender);
            roundPrize[currentRound] += msg.value/2;
        } else if (quantity == 200 ) {
            require(msg.value >= 0.001688 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
            roundParticipants[currentRound].push(msg.sender);
            roundParticipants[currentRound].push(msg.sender);
            roundParticipants[currentRound].push(msg.sender);
            roundPrize[currentRound] += msg.value/2;
        } else {
            require(msg.value >= 0.0000888 ether, "ERC721: Insufficient payment");
            _safeMint(msg.sender,quantity);
            roundParticipants[currentRound].push(msg.sender);
            roundPrize[currentRound] += msg.value/2;
        }

        _pickWinner();

        emit NewMint(msg.sender, quantity);
        emit RoundJoin(currentRound, msg.sender, roundParticipants[currentRound].length);
    }

}