// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./Sendman.sol";
import "./AdminLessERC1967Factory.sol";

contract SendmanFactory is AdminLessERC1967Factory {
  //================== events =============================================
  event ProxyCreated(address indexed from, address sendmanAddress);
  event Executed(address indexed from, address indexed sendmanAddress);

  //================== state variables ====================================
  address public immutable implementation;
  address[] public deployedSendmans;

  //================== constructor ========================================
  constructor() {
    implementation = address(new Sendman());
  }

  //================== public functions ===================================
  function getDeployedSendmansCount() public view returns (uint) {
    return deployedSendmans.length;
  }

  function getSendmanAddress(address owner, uint256 _index) public view returns (address) {
    bytes32 salt = bytes32(uint256(keccak256(abi.encodePacked(owner, _index))) & type(uint96).max);
    return predictDeterministicAddress(salt);
  }

  function createProxy(uint256 _index, bytes calldata _data) public payable returns (address) {
    address from = msg.sender;
    bytes32 salt = bytes32(uint256(keccak256(abi.encodePacked(from, _index))) & type(uint96).max);
    address newProxy = deployDeterministicAndCall(implementation, salt, _data);
    deployedSendmans.push(newProxy);
    emit ProxyCreated(from, newProxy);
    return address(newProxy);
  }
}
