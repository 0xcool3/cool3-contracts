// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IMulticall } from "./IMulticall.sol";

abstract contract Multicall is IMulticall {
  //================== constant fields ====================================
  uint256 public constant NATIVE_CURRENCY_PRICE = 0.002 ether;
  uint256 public constant COOL3_TOKEN_PRICE = 2 * 10 ** 17; // 0.2 COOL3
  address public constant COOL3 = 0x37A39600A67211d67AB2ed12A6841dCf2Ad175d4;
  address public constant FEE_COLLECTOR = 0x7ba0Fa34e917EF23505491d80f54DF6A7f658698;

  //================== public functions ===================================
  function multicall(bytes[] calldata data, address tokenIn) public payable override returns (bytes[] memory results) {
    if (tokenIn == address(0)) {
      require(msg.value >= NATIVE_CURRENCY_PRICE, "multicall: Invalid amount");
      payable(FEE_COLLECTOR).transfer(NATIVE_CURRENCY_PRICE);
    } else {
      require(IERC20(COOL3).transferFrom(msg.sender, FEE_COLLECTOR, COOL3_TOKEN_PRICE), "Transfer of COOL3 failed");
    }

    results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; i++) {
      (bool success, bytes memory result) = address(this).delegatecall(data[i]);

      if (!success) {
        // handle custom errors
        if (result.length == 4) {
          assembly {
            revert(add(result, 0x20), mload(result))
          }
        }
        // Next 5 lines from https://ethereum.stackexchange.com/a/83577
        if (result.length < 68) revert();
        assembly {
          result := add(result, 0x04)
        }
        revert(abi.decode(result, (string)));
      }

      results[i] = result;
    }
  }
}
