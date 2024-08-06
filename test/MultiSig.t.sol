// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MultiSig} from "../src/MultiSig.sol";

contract MultiSigTest is Test {
    MultiSig public multiSig;
    address[] public owners;
    uint256 public requiredConfirmations;

    function setUp() public {
        owners = new address[](3);
        owners[0] = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        owners[1] = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        owners[2] = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        requiredConfirmations = 2;

        multiSig = new MultiSig(owners, requiredConfirmations);
        vm.deal(address(multiSig), 5 ether);
    }

    function testCreateTransaction() public {
        vm.prank(owners[0]);
        multiSig.createTransaction(
            address(0x90F79bf6EB2c4f870365E785982E1f101E93b906),
            "hi",
            1 ether
        );
        (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint confirmations
        ) = multiSig.getTransactions(0);

        assertEq(to, address(0x90F79bf6EB2c4f870365E785982E1f101E93b906));
        assertEq(value, 1 ether);
        assertEq(data, "hi");
        assertFalse(executed);
        assertEq(confirmations, 0);
    }

    function testConfirmTransaction() public {
        vm.prank(owners[0]);
        multiSig.createTransaction(
            address(0x90F79bf6EB2c4f870365E785982E1f101E93b906),
            "hi",
            1 ether
        );

        vm.prank(owners[0]);
        multiSig.confirmTransaction(0);
        (, , , , uint confirmations) = multiSig.getTransactions(0);
        assertEq(confirmations, 1);

        vm.prank(owners[1]);
        multiSig.confirmTransaction(0);
        (, , , , confirmations) = multiSig.getTransactions(0);
        assertEq(confirmations, 2);
    }

    function testExecuteTransaction() public {
        vm.deal(address(multiSig), 3 ether); // Fund this contract with 3 ETH
        vm.prank(owners[0]);
        multiSig.createTransaction(
            address(0x90F79bf6EB2c4f870365E785982E1f101E93b906),
            "0x01",
            1 ether
        );

        vm.prank(owners[0]);
        multiSig.confirmTransaction(0);
        vm.prank(owners[1]);
        multiSig.confirmTransaction(0);

        uint balanceBefore = address(0x90F79bf6EB2c4f870365E785982E1f101E93b906)
            .balance;

        vm.prank(owners[0]);
        multiSig.executeTransaction(0);

        uint balanceAfter = address(0x90F79bf6EB2c4f870365E785982E1f101E93b906)
            .balance;
        assertEq(balanceAfter, balanceBefore + 1 ether);
        (, , , bool executed, ) = multiSig.getTransactions(0);
        assertTrue(executed);
    }

    function testRevokeConfirmation() public {
        vm.prank(owners[0]);
        multiSig.createTransaction(address(0x4), "0x01", 1 ether);

        vm.prank(owners[1]);
        multiSig.createTransaction(address(0x5), "0x02", 1 ether);

        vm.prank(owners[0]);
        multiSig.confirmTransaction(1);

        vm.prank(owners[1]);
        multiSig.confirmTransaction(1);

        vm.prank(owners[2]);
        multiSig.confirmTransaction(1);
        (, , , , uint confirmations) = multiSig.getTransactions(1);
        assertEq(confirmations, 3);

        vm.prank(owners[1]);
        multiSig.revokeTransaction(1);
        (, , , , confirmations) = multiSig.getTransactions(1);
        assertEq(confirmations, 2);
    }
}
//[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db]
