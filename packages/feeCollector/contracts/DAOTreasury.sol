// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOTreasury is Ownable {
    address benificiary;

    constructor() Ownable(0x34b0387a072BeefdC9910AD20118D52432512193) {}

    function setBenificiary(address _benificiary) public onlyOwner {
        benificiary = _benificiary;
    }

    function withdraw() public {
        payable(benificiary).transfer(address(this).balance);
    }

    receive() external payable {}
}
