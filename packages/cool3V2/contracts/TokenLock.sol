// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Token Lock Contract with Time-based Withdrawal
 * @dev Allows the owner to withdraw a limited amount of tokens or Ether from the contract every 30 days.
 */
contract TokenLock is Ownable {
    address benificiary;
    uint256 public unlockBeginTime;
    uint256 public unlockRate = 1;
    uint256 public unlockWaitTime = 30 days;
    uint256 public unlockPeriod = 30 days;

    // Mapping from token addresses to the last unlock time
    mapping(address => uint256) public lastUnlockTime;

    // Event to log withdrawals
    event Withdrawal(
        address indexed token,
        uint256 amount,
        uint256 when,
        address to
    );

    /**
     * @dev Allows the contract to receive Ether directly.
     */
    receive() external payable {}

    /**
     * @dev Initializes the contract setting the initial owner.
     */
    constructor(address initOwner) Ownable(initOwner) {
        benificiary = initOwner;
        unlockBeginTime = block.timestamp + unlockWaitTime;
    }

    function setBenificiary(address _benificiary) public onlyOwner {
        benificiary = _benificiary;
    }

    /**
     * @dev Withdraws tokens or Ether from the contract if the time lock has passed.
     * Allows only {unlockRate}% of the total balance to be withdrawn every {unlockPeriod} days.
     * @param token The token address (zero address for Ether).
     */
    function withdraw(address token) public onlyOwner {
        require(
            unlockBeginTime <= block.timestamp,
            "TokenLock: Withdrawal not yet allowed"
        );

        require(
            block.timestamp - lastUnlockTime[token] >= unlockPeriod ||
                lastUnlockTime[token] == 0,
            "TokenLock: Withdrawal not yet allowed"
        );

        uint256 amount;

        if (token == address(0)) {
            amount = (address(this).balance / 100) * unlockRate;
            payable(benificiary).transfer(amount);
        } else {
            amount =
                (IERC20(token).balanceOf(address(this)) / 100) *
                unlockRate;
            IERC20(token).transfer(benificiary, amount);
        }

        lastUnlockTime[token] = block.timestamp;
        emit Withdrawal(token, amount, block.timestamp, benificiary);
    }
}
