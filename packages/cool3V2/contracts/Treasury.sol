// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury is Ownable {
    address benificiary;

    receive() external payable {}

    constructor(address initOwner) Ownable(initOwner) {
        benificiary = initOwner;
    }

    function setBenificiary(address _benificiary) public onlyOwner {
        benificiary = _benificiary;
    }

    function withdraw() public {
        payable(benificiary).transfer(address(this).balance);
    }

    function withdrawERC20(address token, uint256 amount) public {
        IERC20(token).transfer(benificiary, amount);
    }
}
