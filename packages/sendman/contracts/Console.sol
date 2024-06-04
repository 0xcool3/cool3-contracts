// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Console {
  event LogString(string message);
  event LogUint(uint value);
  event LogAddress(address addr);
  event LogBool(bool value);
  event LogBytes(bytes value);

  function log(string memory message) public {
    emit LogString(message);
  }

  function log(uint value) public {
    emit LogUint(value);
  }

  function log(address addr) public {
    emit LogAddress(addr);
  }

  function log(bool value) public {
    emit LogBool(value);
  }

  function log(bytes memory value) public {
    emit LogBytes(value);
  }
}
