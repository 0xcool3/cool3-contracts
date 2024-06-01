// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Cool3NameRegistry {
    uint256 public immutable nativeCurrencyAmount = 0.02 ether;
    uint256 public immutable cool3Amount = 2 * 10 ** 18; // 2 COOL3

    address public cool3Token;
    address public feeCollector;

    mapping(string => address) public nameToAddress;
    mapping(address => string) public addressToName;
    mapping(address => bytes) public pubkey;

    event NameRegistered(
        address indexed owner,
        string indexed name,
        address indexed addr
    );

    event PubkeyRegistered(address indexed owner, bytes indexed pubkey);

    constructor(address _cool3Token, address _feeCollector) {
        cool3Token = _cool3Token;
        feeCollector = _feeCollector;
    }

    function registerName(
        string memory name,
        bool isNativeCurrencyPayment
    ) public payable {
        require(nameToAddress[name] == address(0), "Name already registered");
        require(
            bytes(addressToName[msg.sender]).length == 0,
            "Name already registered"
        );

        if (isNativeCurrencyPayment == true) {
            require(
                msg.value >= nativeCurrencyAmount,
                "registerName: Invalid amount"
            );
            payable(feeCollector).transfer(msg.value);
        } else {
            IERC20(cool3Token).transferFrom(
                msg.sender,
                feeCollector,
                cool3Amount
            );
        }

        nameToAddress[name] = msg.sender;
        addressToName[msg.sender] = name;

        emit NameRegistered(msg.sender, name, msg.sender);
    }

    function registerPubkey(bytes memory _pubkey) public {
        pubkey[msg.sender] = _pubkey;
        emit PubkeyRegistered(msg.sender, _pubkey);
    }

    function getPubkeyByName(
        string memory name
    ) public view returns (bytes memory) {
        return pubkey[nameToAddress[name]];
    }
}
