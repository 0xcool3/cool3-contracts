// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Market {
  //================== events =============================================
  event Swap(
    address indexed recipient,
    address indexed tokenIn,
    address indexed tokenOut,
    uint256 tokenInAmount,
    uint256 tokenOutAmount,
    uint256 when
  );

  //================== constant fields ====================================
  address public constant NATIVE_CURRENCY = address(0);
  uint256 public constant RATIO = 1000;

  //================== state variables ====================================
  address public immutable COOL3;

  //================== constructor ========================================
  constructor(address _COOL3) {
    COOL3 = _COOL3;
  }

  //================== public functions ===================================
  receive() external payable {}

  function swap(address tokenIn, address tokenOut, uint256 tokenInAmount) public payable {
    require(tokenIn != tokenOut, "Invalid tokenIn and tokenOut");
    require(tokenIn == NATIVE_CURRENCY || tokenIn == COOL3, "Invalid tokenIn");
    require(tokenOut == NATIVE_CURRENCY || tokenOut == COOL3, "Invalid tokenOut");
    uint256 tokenOutAmount;
    if (tokenIn == NATIVE_CURRENCY) {
      require(msg.value >= tokenInAmount, "Invalid NATIVE_CURRENCY amount");
      tokenOutAmount = msg.value * RATIO;
      require(IERC20(COOL3).balanceOf(address(this)) >= tokenOutAmount, "Insufficient COOL3 balance");
      IERC20(COOL3).transfer(msg.sender, tokenOutAmount);
    } else {
      require(IERC20(COOL3).transferFrom(msg.sender, address(this), tokenInAmount), "Token transfer failed");
      tokenOutAmount = (tokenInAmount) / RATIO;
      require(address(this).balance >= tokenOutAmount, "Insufficient WETH balance");
      payable(msg.sender).transfer(tokenOutAmount);
    }
    emit Swap(msg.sender, tokenIn, tokenOut, tokenInAmount, tokenOutAmount, block.timestamp);
  }
}
