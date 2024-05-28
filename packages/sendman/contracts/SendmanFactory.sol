// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Sendman.sol";
import "./AdminLessERC1967Factory.sol";

contract SendmanFactory is AdminLessERC1967Factory {
    address[] public deployedSendmans;
    address public implementation;

    event SendmanCreated(address indexed creator, address newSendman);

    event Executed(
        address indexed creator,
        address indexed sendmanAddress,
        uint256 _index
    );

    constructor() {
        implementation = address(new Sendman());
    }

    function createSendman(
        uint256 _index,
        bytes calldata _data
    ) public returns (address) {
        bytes32 salt = bytes32(
            uint256(keccak256(abi.encodePacked(msg.sender, _index))) &
                type(uint96).max
        );
        address newSendman = deployDeterministicAndCall(
            implementation,
            salt,
            _data
        );
        deployedSendmans.push(newSendman);
        emit SendmanCreated(msg.sender, newSendman);
        return address(newSendman);
    }

    function getDeployedSendmansCount() public view returns (uint) {
        return deployedSendmans.length;
    }

    function getSendmanAddress(
        address owner,
        uint256 _index
    ) public view returns (address) {
        bytes32 salt = bytes32(
            uint256(keccak256(abi.encodePacked(owner, _index))) &
                type(uint96).max
        );
        return predictDeterministicAddress(salt);
    }

    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function execute(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation,
        uint256 _index,
        bytes calldata initData
    ) public payable {
        address sendmanAddress = getSendmanAddress(msg.sender, _index);

        if (!isContract(sendmanAddress)) {
            createSendman(_index, initData);
        }

        // Collect Fee
        require(msg.value - value >= 0.001 ether, "Insufficient funds");
        payable(0xF46E1362612e83202C938CEaaf3CbAad15f9C0C8).transfer(
            msg.value - value
        );

        Sendman(payable(sendmanAddress)).execute{value: value}(
            to,
            value,
            data,
            operation
        );

        emit Executed(msg.sender, sendmanAddress, _index);
    }
}
