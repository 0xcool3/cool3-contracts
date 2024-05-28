// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Compatibility.sol";
enum Operation {
    Call,
    DelegateCall
}

contract Sendman is Compatibility {
    address public factory;

    function initialize(address _factory) public {
        require(address(factory) == address(0), "AlreadyInitialized");
        factory = _factory;
    }

    function execute(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation
    ) external payable {
        require(msg.sender == factory, "Only factory can execute");
        if (operation == Operation.DelegateCall) {
            assembly {
                let success := delegatecall(
                    gas(),
                    to,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
                returndatacopy(0, 0, returndatasize())
                switch success
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
            }
        } else {
            assembly {
                let success := call(
                    gas(),
                    to,
                    value,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
                returndatacopy(0, 0, returndatasize())
                switch success
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
            }
        }
    }
}
