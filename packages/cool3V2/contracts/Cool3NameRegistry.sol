// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Cool3NameRegistry {
  //================== events =============================================
  event NameRegistered(address indexed owner, string name, uint256 when);
  event PubkeyRegistered(address indexed owner, bytes pubkey, uint256 when);

  //================== constant fields ====================================
  uint256 public constant NATIVE_CURRENCY_PRICE = 0.02 ether;
  uint256 public constant COOL3_TOKEN_PRICE = 2 * 10 ** 18; // 2 COOL3

  //================== state variables ====================================
  address public immutable cool3Token;
  address public immutable feeCollector;

  mapping(string => address) public nameToAddress;
  mapping(address => string) public addressToName;
  mapping(address => bytes) public pubkey;

  //================== constructor ========================================
  constructor(address _cool3Token, address _feeCollector) {
    cool3Token = _cool3Token;
    feeCollector = _feeCollector;
  }

  //================== public functions ===================================
  function registerName(string memory name, bool useNativeCurrencyPayment) public payable {
    require(nameToAddress[name] == address(0), "Name already registered");
    require(bytes(addressToName[msg.sender]).length == 0, "Name already registered");

    if (useNativeCurrencyPayment == true) {
      require(msg.value >= NATIVE_CURRENCY_PRICE, "registerName: Invalid amount");
      payable(feeCollector).transfer(msg.value);
    } else {
      require(IERC20(cool3Token).transferFrom(msg.sender, feeCollector, COOL3_TOKEN_PRICE), "Transfer of COOL3 failed");
    }

    nameToAddress[name] = msg.sender;
    addressToName[msg.sender] = name;

    emit NameRegistered(msg.sender, name, block.timestamp);
  }

  function registerPubkey(bytes memory _pubkey) public {
    pubkey[msg.sender] = _pubkey;
    emit PubkeyRegistered(msg.sender, _pubkey, block.timestamp);
  }

  function getPubkeyByName(string memory name) public view returns (bytes memory) {
    return pubkey[nameToAddress[name]];
  }
}
