// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MultiSig} from "../src/MultiSig.sol";

contract CreateTransaction is Script {
    MultiSig public multiSig;

    function setUp() public {
        multiSig = MultiSig(
            payable(0x5FbDB2315678afecb367f032d93F642f64180aa3)
        );
    }

    function run() public {
        // Create a transaction

        address user = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        uint256 amount = 1 ether;
        bytes memory data = "0x01";

        vm.startBroadcast();

        multiSig.createTransaction(user, data, amount);

        vm.stopBroadcast();

        console.log("Balance of Contract", address(multiSig).balance);

        (
            address _user,
            uint256 _amount,
            bytes memory _data,
            bool _isExecuted,
            uint256 _noOfconfirmation
        ) = multiSig.getTransactions(0);

        console.log("Transaction address ------>", _user);
        console.log("Transaction amount ------>", _amount);
        console.logBytes(_data);
        console.log("Transaction execued ? ------>", _isExecuted);
        console.log(
            "Transaction number of confirmation ------>",
            _noOfconfirmation
        );
    }
}
