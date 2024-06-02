// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury is Ownable {
  //================== events =============================================
  event Withdrawal(address indexed to, address indexed token, uint256 amount, uint256 when);

  //================== state variables ====================================
  address public benificiary;

  //================== constructor ========================================
  constructor(address initOwner) Ownable(initOwner) {
    benificiary = initOwner;
  }

  //================== onlyOwner functions ================================
  function setBenificiary(address _benificiary) public onlyOwner {
    benificiary = _benificiary;
  }

  //================== public functions ===================================
  receive() external payable {}

  function withdraw(address token, uint256 amount) public {
    if (token == address(0)) {
      payable(benificiary).transfer(amount);
    } else {
      IERC20(token).transfer(benificiary, amount);
    }
    emit Withdrawal(benificiary, token, amount, block.timestamp);
  }
}
