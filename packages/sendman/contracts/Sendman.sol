// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./Multicall.sol";

contract Sendman is Multicall {
  //================== public functions ===================================
  function transferETH(uint256 _amount, address _to) public payable {
    address payable recipient = payable(_to);
    (bool success, ) = recipient.call{ value: _amount }("");
    require(success, "Transfer of ETH failed");
  }

  function transferERC20(address _token, uint256 _amount, address _to) public {
    require(IERC20(_token).transferFrom(msg.sender, _to, _amount), "Transfer of ERC20 failed");
  }

  function transferERC721(address _token, uint256 _id, address _to) public {
    IERC721(_token).safeTransferFrom(msg.sender, _to, _id);
  }

  function transferERC1155(address _token, uint256 _id, address _to, uint256 amount, bytes calldata data) public {
    IERC1155(_token).safeTransferFrom(msg.sender, _to, _id, amount, data);
  }
}
