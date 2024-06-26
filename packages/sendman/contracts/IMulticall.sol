// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMulticall {
  function multicall(bytes[] calldata data, address tokenIn) external payable returns (bytes[] memory results);
}
