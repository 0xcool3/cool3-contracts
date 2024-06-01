// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FeeCollector {
    address public treasury;
    address public market;
    address public developer;

    receive() external payable {}

    constructor(address _treasury, address _market, address _developer) {
        treasury = _treasury;
        market = _market;
        developer = _developer;
    }

    function distrubuteETH() public {
        uint256 fee1 = address(this).balance / 10;
        uint256 fee2 = (address(this).balance / 10) * 8;
        payable(developer).transfer(fee1);
        payable(market).transfer(fee1);
        payable(treasury).transfer(fee2);
    }

    function distrubuteERC20(address token) public {
        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 fee1 = balance / 10;
        uint256 fee2 = (balance / 10) * 8;
        IERC20(token).transfer(developer, fee1);
        IERC20(token).transfer(market, fee1);
        IERC20(token).transfer(developer, fee2);
    }
}
