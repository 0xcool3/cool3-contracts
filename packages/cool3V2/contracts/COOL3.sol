// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./TokenLock.sol";
import "./Market.sol";
import "./Treasury.sol";
import "./FeeCollector.sol";
import "./Cool3NameRegistry.sol";

contract COOL3 is ERC20 {
    address public tokenLock;
    address public treasury;
    address public market;
    address public feeCollector;
    address public cool3NameRegistry;

    address public immutable developer =
        0x34b0387a072BeefdC9910AD20118D52432512193;

    constructor() ERC20("COOL3 V2", "COOL3") {
        // mint
        _mint(address(this), 10_000_000 * 10 ** decimals());

        // create receiver contracts
        tokenLock = address(new TokenLock(developer));
        treasury = address(new Treasury(developer));
        market = address(new Market(address(this)));
        feeCollector = address(new FeeCollector(treasury, market, developer));
        cool3NameRegistry = address(
            new Cool3NameRegistry(address(this), feeCollector)
        );

        // transfer
        _transfer(address(this), tokenLock, 5_000_000 * 10 ** decimals());
        _transfer(address(this), treasury, 3_000_000 * 10 ** decimals());
        _transfer(address(this), market, 2_000_000 * 10 ** decimals());
    }
}
