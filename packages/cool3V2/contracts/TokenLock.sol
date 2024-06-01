// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenLock is Ownable {
  //================== events =============================================
  event Withdrawal(address indexed to, address indexed token, uint256 amount, uint256 when);

  //================== constant fields ====================================
  uint256 public constant UNLOCK_RATE = 5;
  uint256 public constant UNLOCK_WAITTIME = 90 days;
  uint256 public constant UNLOCK_PERIOD = 30 days;

  //================== state variables ====================================
  uint256 public immutable unlockBeginTime;
  address public benificiary;
  mapping(address => uint256) public lastUnlockTime;

  //================== constructor ========================================
  constructor(address initOwner) Ownable(initOwner) {
    benificiary = initOwner;
    unlockBeginTime = block.timestamp + UNLOCK_WAITTIME;
  }

  //================== onlyOwner functions ================================
  function setBenificiary(address _benificiary) public onlyOwner {
    benificiary = _benificiary;
  }

  //================== public functions ===================================
  receive() external payable {}

  function withdraw(address token) public {
    uint256 currentTime = block.timestamp;
    require(unlockBeginTime <= currentTime, "TokenLock: Withdrawal not yet allowed");

    require(
      currentTime - lastUnlockTime[token] >= UNLOCK_PERIOD || lastUnlockTime[token] == 0,
      "TokenLock: Withdrawal not yet allowed"
    );

    uint256 amount;

    if (token == address(0)) {
      amount = ((address(this).balance * UNLOCK_RATE) / 1000);
      payable(benificiary).transfer(amount);
    } else {
      amount = ((IERC20(token).balanceOf(address(this)) * UNLOCK_RATE) / 1000);
      IERC20(token).transfer(benificiary, amount);
    }

    lastUnlockTime[token] = currentTime;
    emit Withdrawal(benificiary, token, amount, currentTime);
  }
}
