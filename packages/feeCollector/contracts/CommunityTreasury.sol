// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CommunityTreasury {
    address public immutable cool3 = 0x913Aa323127A2E1E5604bD84D3f3d8B929215f52;

    receive() external payable {}

    event ExchangeETH(address recipient, uint256 amount);
    event ExchangeCool3(address recipient, uint256 amount);

    function exchangeAndSendCool3(
        address recipient,
        uint256 tokenAmount
    ) public payable {
        require(tokenAmount >= 1000, "Minimum token amount is 1000");
        require(
            IERC20(cool3).balanceOf(address(this)) >= tokenAmount,
            "Insufficient COOL3 balance"
        );

        // 1000 cool3 = 1 ETH
        uint256 ethAmount = tokenAmount / 1000;
        require(msg.value >= ethAmount, "Insufficient ETH balance");
        IERC20(cool3).transfer(recipient, tokenAmount);
        emit ExchangeCool3(recipient, ethAmount);
    }

    function exchangeAndSendETH(address recipient, uint256 tokenAmount) public {
        require(tokenAmount >= 1000, "Minimum token amount is 1000");
        require(
            IERC20(cool3).transferFrom(msg.sender, address(this), tokenAmount),
            "Token transfer failed"
        );

        // 1000 cool3 = 1 ETH
        uint256 ethAmount = (tokenAmount) / 1000;
        require(address(this).balance >= ethAmount, "Insufficient ETH balance");
        payable(recipient).transfer(ethAmount);
        emit ExchangeETH(recipient, ethAmount);
    }
}
