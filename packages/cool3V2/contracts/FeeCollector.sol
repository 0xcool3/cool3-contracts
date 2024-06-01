// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FeeCollector {
  //================== events =============================================
  event Distribute(address indexed token, uint256 when);

  //================== state variables ====================================
  address public immutable treasury;
  address public immutable market;
  address public immutable developer;

  //================== constructor ========================================
  constructor(address _treasury, address _market, address _developer) {
    treasury = _treasury;
    market = _market;
    developer = _developer;
  }

  //================== public functions ===================================
  receive() external payable {}

  function distribute(address token) public {
    if (token == address(0)) {
      uint256 fee1 = address(this).balance / 10;
      uint256 fee2 = fee1 * 8;
      payable(developer).transfer(fee1);
      payable(market).transfer(fee1);
      payable(treasury).transfer(fee2);
    } else {
      uint256 balance = IERC20(token).balanceOf(address(this));
      uint256 fee1 = balance / 10;
      uint256 fee2 = fee1 * 8;
      IERC20(token).transfer(developer, fee1);
      IERC20(token).transfer(market, fee1);
      IERC20(token).transfer(treasury, fee2);
    }
    emit Distribute(token, block.timestamp);
  }
}
