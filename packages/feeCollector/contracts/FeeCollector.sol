// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DAOTreasury.sol";
import "./CommunityTreasury.sol";

contract FeeCollector {
    address public DAOTreasuryAddress;
    address public CommunityTreasuryAddress;
    address public developerAddress;

    constructor() {
        DAOTreasuryAddress = address(new DAOTreasury());
        CommunityTreasuryAddress = address(new CommunityTreasury());
        developerAddress = 0x34b0387a072BeefdC9910AD20118D52432512193;
    }

    receive() external payable {
        uint256 fee1 = msg.value / 10;
        uint256 fee2 = (msg.value / 10) * 8;

        // Developer fee
        payable(developerAddress).transfer(fee1);

        // Community Treasury fee
        payable(CommunityTreasuryAddress).transfer(fee1);

        // DAO Treasury Fee
        payable(DAOTreasuryAddress).transfer(fee2);
    }
}
