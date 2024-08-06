// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MultiSig} from "../src/MultiSig.sol";

contract MultiSigScript is Script {
    MultiSig public multiSig;

    address[] public owners;
    uint256 public confirmationsRequired;

    function setUp() public {
        // Define the owners and the number of confirmations required
        owners = [
            address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
            address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8),
            address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC)
        ];
        confirmationsRequired = 2;
        vm.startBroadcast();

        multiSig = new MultiSig(owners, confirmationsRequired);

        vm.stopBroadcast();
    }

    function run() public view {
        console.log(
            "MultiSig Contract Successfully deployed at ---",
            address(multiSig)
        );
        console.log("Balance of Contract", address(multiSig).balance);
        //console.CONSOLE_ADDRESS("Transaction", multiSig.getTransactions(0));
    }
}
