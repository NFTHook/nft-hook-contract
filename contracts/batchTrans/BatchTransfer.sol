// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IERC20.sol";
import "../interface/IERC721.sol";
import "../interface/IERC1155.sol";

contract BatchTransfer is Ownable, ReentrancyGuard {

    event TransferFailed(address indexed receiver, uint amount);
    event TransferFailed20(address indexed receiver, uint amount);
    event TransferFailed721(address indexed token, address indexed receiver, uint tokenId);
    event TransferFailed1155(address indexed token, address indexed receiver, uint id, uint amount, bytes data);

    constructor() Ownable(msg.sender) {}

    function batchTransferEqualAmountTrans(address[] calldata receivers, uint256 amount) external payable {
        uint256 totalAmount = amount * receivers.length;
        require(receivers.length > 0, "Receivers list is empty");
        require(msg.value >= totalAmount, "Sent value is less than required");
    
        for (uint256 i = 0; i < receivers.length; i++) {
            payable(receivers[i]).transfer(amount);
        }
    }

    function batchTransferVariableAmountTrans(address[] calldata receivers, uint256[] calldata amounts) external payable {
        
        require(receivers.length > 0, "Receivers list is empty");
        require(receivers.length == amounts.length, "Receiver and amount arrays must have the same length");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(msg.value >= totalAmount, "Sent value is less than required");

        for (uint256 i = 0; i < receivers.length; i++) {
            payable(receivers[i]).transfer(amounts[i]);
        }
    }

    // 批量转账相同金额的ETH
    function batchTransferEqualAmount(address[] calldata receivers, uint256 amount) external payable nonReentrant {
        uint256 totalAmount = amount * receivers.length;
        require(msg.value >= totalAmount, "Sent value is less than required");

        uint256 totalFailedAmount = 0;

        for (uint256 i = 0; i < receivers.length; i++) {
            (bool success, ) = receivers[i].call{value: amount}("");
            if (!success) {
                emit TransferFailed(receivers[i], amount);
                totalFailedAmount += amount;
            }
        }

        if (totalFailedAmount > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: totalFailedAmount}("");
            require(refundSuccess, "Refund to sender failed");
        }
    }

    // 批量转账不同金额的ETH
    function batchTransferVariableAmount(address[] calldata receivers, uint256[] calldata amounts) external payable nonReentrant {
        require(receivers.length == amounts.length, "Receiver and amount arrays must have the same length");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        require(msg.value >= totalAmount, "Sent value is less than required");

        uint256 totalFailedAmount = 0;

        for (uint256 i = 0; i < receivers.length; i++) {
            (bool success, ) = receivers[i].call{value: amounts[i]}("");
            if (!success) {
                emit TransferFailed(receivers[i], amounts[i]);
                totalFailedAmount += amounts[i];
            }
        }

        if (totalFailedAmount > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: totalFailedAmount}("");
            require(refundSuccess, "Refund to sender failed");
        }
    }

    //给不同的人转账相同的钱开启单事务
    function batchTransferSameAmountERC20Trans(address token, address[] calldata receivers, uint256 amount) external payable nonReentrant {
        uint256 totalAmount = amount * receivers.length;
        IERC20 tokenObj = IERC20(token);
        require(tokenObj.transferFrom(msg.sender, address(this), totalAmount), "Transfer to contract failed");

        for (uint256 i = 0; i < receivers.length; i++) {
            require(tokenObj.transfer(receivers[i], amount), "Transfer to receiver failed");
        }

    }

    //给不同的人转账相同的钱开启多事务
    function batchTransferSameAmountERC20(address token, address[] calldata receivers, uint256 amount) external payable nonReentrant {
        uint256 totalAmount = amount * receivers.length;
        uint256 totalFailedAmount = 0;
        IERC20 tokenObj = IERC20(token);

        require(tokenObj.transferFrom(msg.sender, address(this), totalAmount), "Transfer to contract failed");

        for (uint256 i = 0; i < receivers.length; i++) {
            bool success = tokenObj.transfer(receivers[i], amount);
            if (!success) {
                emit TransferFailed20(receivers[i], amount);
                totalFailedAmount += amount;
            }
        }

        if (totalFailedAmount > 0) {
            require(tokenObj.transfer(msg.sender, totalFailedAmount), "Refund to sender failed");
        }
    }

    // 批量转移ERC721代币给单个人
    function batchTransferERC721TokenT1(address token, address receiver, uint256[] calldata tokenIds) external nonReentrant {
        IERC721 tokenObj = IERC721(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            try tokenObj.safeTransferFrom(msg.sender, receiver, tokenIds[i]) {
                // 可以选择发出成功事件
            } catch {
                emit TransferFailed721(token, receiver, tokenIds[i]);
            }
        }
    }

    // 批量转移ERC721代币给多个人
    function batchTransferERC721Token(address token, address[] calldata receivers, uint256[] calldata tokenIds) external nonReentrant {
        require(receivers.length == tokenIds.length, "Receivers and token IDs must match in length");
        IERC721 tokenObj = IERC721(token);

        for (uint256 i = 0; i < receivers.length; i++) {
            try tokenObj.safeTransferFrom(msg.sender, receivers[i], tokenIds[i]) {
                // 可以选择发出成功事件
            } catch {
                emit TransferFailed721(token, receivers[i], tokenIds[i]);
            }
        }
    }

    // 批量转移ERC1155代币
    function batchTransferERC1155Token(address token, address[] calldata receivers, uint256 id, uint256[] calldata amounts, bytes calldata data) external nonReentrant {
        require(receivers.length == amounts.length, "Receivers and amounts must match in length");
        IERC1155 tokenObj = IERC1155(token);

        for (uint256 i = 0; i < receivers.length; i++) {
            try tokenObj.safeTransferFrom(msg.sender, receivers[i], id, amounts[i], data) {
                // 可以选择发出成功事件
            } catch {
                emit TransferFailed1155(token, receivers[i], id, amounts[i], data);
            }
        }
    }

    // 该函数允许合约接收以太
    receive() external payable {}

    function transferOut(address _payeeAddr) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_payeeAddr).transfer(balance);
    }

    function transferAllERC20Out(address _tokenAddress, address _payeeAddr) public onlyOwner {     
        IERC20 tokenObj = IERC20(_tokenAddress);
        uint256 balance = tokenObj.balanceOf(address(this));
        require(balance > 0, "No token balance to transfer");

        tokenObj.transfer(_payeeAddr, balance);
    }
}