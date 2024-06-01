// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Market {
    address public COOL3;
    address public immutable NativeCurrency = address(0);
    uint256 public immutable ratio = 1000;
    event Swap(address recipient, address tokenOut, uint256 amount);

    receive() external payable {}

    constructor(address _COOL3) {
        COOL3 = _COOL3;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 tokenInAmount
    ) public payable {
        require(
            tokenIn == NativeCurrency || tokenIn == COOL3,
            "Invalid tokenIn"
        );
        require(
            tokenOut == NativeCurrency || tokenOut == COOL3,
            "Invalid tokenOut"
        );

        if (tokenIn == NativeCurrency) {
            require(
                msg.value >= tokenInAmount,
                "Invalid NativeCurrency amount"
            );

            uint256 amount = msg.value * ratio;
            require(
                IERC20(COOL3).balanceOf(address(this)) >= amount,
                "Insufficient COOL3 balance"
            );
            IERC20(COOL3).transfer(msg.sender, amount);
            emit Swap(msg.sender, tokenOut, amount);
        } else {
            require(
                IERC20(COOL3).transferFrom(
                    msg.sender,
                    address(this),
                    tokenInAmount
                ),
                "Token transfer failed"
            );

            uint256 amount = (tokenInAmount) / ratio;

            require(
                address(this).balance >= amount,
                "Insufficient WETH balance"
            );

            payable(msg.sender).transfer(amount);
            emit Swap(msg.sender, tokenOut, amount);
        }
    }
}
