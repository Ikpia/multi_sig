// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MultiSig} from "../src/MultiSig.sol";

contract ConfirmTransaction is Script {
    MultiSig public multiSig;

    function setUp() public {
        multiSig = MultiSig(
            payable(0x5FbDB2315678afecb367f032d93F642f64180aa3)
        );
    }

    function run() public {
        // Create a transaction
        //address[] memory owners = multiSig.getOwners();

        vm.startBroadcast();

        multiSig.confirmTransaction(0);

        vm.stopBroadcast();

        (, , , , uint256 _noOfconfirmation) = multiSig.getTransactions(0);
        console.log("number of confirmation", _noOfconfirmation);

        // Execute the transaction
        // multiSig.executeTransaction{value: amount}(0);
    }
}
