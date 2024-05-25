// Sources flattened with hardhat v2.18.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/interface/IERC1155.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

interface IERC1155 {

    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}


// File contracts/interface/IERC20.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}


// File contracts/interface/IERC721.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}


// File contracts/batchTrans/BatchTransfer.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;





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
