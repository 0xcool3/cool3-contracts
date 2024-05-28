// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Governor.sol";
import "./AdminLessERC1967Factory.sol";

contract GovernorFactory is AdminLessERC1967Factory {
    address[] public deployedGovernors;
    address public implementation;

    event GovernorCreated(
        address indexed creator,
        address governorAddress,
        string name
    );

    constructor() {
        implementation = address(new Governor("", IERC20(address(0)), 0, 0));
    }

    function createGovernor(
        string memory _name,
        uint256 _index,
        bytes calldata _data
    ) public returns (address) {
        bytes32 salt = bytes32(
            uint256(keccak256(abi.encodePacked(_data, _index))) &
                type(uint96).max
        );
        address newGovernor = deployDeterministicAndCall(
            implementation,
            salt,
            _data
        );
        deployedGovernors.push(newGovernor);
        emit GovernorCreated(msg.sender, newGovernor, _name);
        return address(newGovernor);
    }

    function getDeployedGovernorsCount() public view returns (uint) {
        return deployedGovernors.length;
    }
}
