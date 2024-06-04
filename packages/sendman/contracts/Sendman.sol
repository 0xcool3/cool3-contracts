// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Compatibility.sol";

interface ICOOL3 {
  function feeCollector() external view returns (address);
}

enum Operation {
  Call,
  DelegateCall
}

contract Sendman is Compatibility {
  //================== constant fields ====================================
  address public constant COOL3 = 0x37A39600A67211d67AB2ed12A6841dCf2Ad175d4;
  uint256 public constant NATIVE_CURRENCY_PRICE = 0.002 ether;
  uint256 public constant COOL3_TOKEN_PRICE = 2 * 10 ** 17; // 0.2 COOL3

  //================== state variables ====================================
  address public owner;
  address public cool3Token;
  address public feeCollector;

  //================== public functions ===================================
  function initialize(address _owner) public payable {
    require(address(owner) == address(0), "AlreadyInitialized");
    cool3Token = COOL3;
    feeCollector = ICOOL3(COOL3).feeCollector();
    owner = _owner;
  }

  function execute(
    address tokenIn,
    address to,
    uint256 value,
    bytes memory data,
    Operation operation
  ) external payable {
    require(msg.sender == owner, "Only owner can execute");
    if (tokenIn == address(0)) {
      require(msg.value >= NATIVE_CURRENCY_PRICE, "Sendman: Invalid amount");
      payable(feeCollector).transfer(NATIVE_CURRENCY_PRICE);
    } else {
      require(IERC20(cool3Token).transferFrom(msg.sender, feeCollector, COOL3_TOKEN_PRICE), "Transfer of COOL3 failed");
    }
    if (operation == Operation.DelegateCall) {
      assembly {
        let success := delegatecall(gas(), to, add(data, 0x20), mload(data), 0, 0)
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
        let success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
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
