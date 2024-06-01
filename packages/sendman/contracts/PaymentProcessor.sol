// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PaymentProcessor {
    struct Payment {
        string id;
        address token;
        uint256 amount;
        address from;
        bool isPaid;
    }

    mapping(string => Payment) public payments;
    uint256 public paymentsCount;

    event PaymentReceived(
        string indexed id,
        address indexed token,
        uint256 amount,
        address from
    );

    function getPaymentsCount() public view returns (uint) {
        return paymentsCount;
    }

    function pay(
        string memory id,
        address feeToken,
        uint256 tokenAmount,
        address from,
        address feeCollector
    ) public payable {
        require(
            !payments[id].isPaid,
            "PaymentProcessor: Payment has been made"
        );

        if (feeToken == address(0)) {
            require(
                msg.value >= tokenAmount,
                "PaymentProcessor: Invalid payment amount"
            );
            payable(feeCollector).transfer(msg.value);
        } else {
            require(
                IERC20(feeToken).balanceOf(from) >= tokenAmount,
                "PaymentProcessor: Insufficient balance"
            );
            IERC20(feeToken).transferFrom(from, feeCollector, tokenAmount);
        }

        payments[id] = (Payment(id, feeToken, tokenAmount, from, true));
        paymentsCount++;
        emit PaymentReceived(id, feeToken, tokenAmount, from);
    }
}
