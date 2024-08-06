// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultiSig {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public totalNoOfConfirmation;

    struct Transaction {
        address user;
        uint256 amount;
        bytes data;
        bool isExecuted;
        uint256 noOfConfirmation;
    }
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    modifier OnlyOwner() {
        require(isOwner[msg.sender], "not the owner");
        _;
    }
    modifier OnlyConfirmedTransaction(uint256 _txIndex) {
        require(
            transactions[_txIndex].noOfConfirmation >= totalNoOfConfirmation &&
                transactions[_txIndex].noOfConfirmation <= owners.length,
            "Transaction not confirmed"
        );
        _;
    }

    event SubmitTransaction(
        address indexed sender,
        uint256 indexed txIndex,
        string message
    );
    event ConfirmTransaction(
        address indexed sender,
        uint256 indexed txIndex,
        string message
    );
    event RevokeTransaction(
        address indexed sender,
        uint256 indexed txIndex,
        string message
    );
    event ExecuteTransaction(
        address indexed sender,
        uint256 indexed txIndex,
        string message
    );
    event DepositEth(address indexed sender, uint256 amount);

    constructor(address[] memory _owners, uint256 _totalNoOfConfirmation) {
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            isOwner[owner] = true;

            owners.push(owner);
        }
        totalNoOfConfirmation = _totalNoOfConfirmation;
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactions(
        uint256 _txIndex
    ) public view returns (address, uint256, bytes memory, bool, uint256) {
        require(_txIndex < transactions.length, "Transaction not found");
        Transaction storage transaction = transactions[_txIndex];
        return (
            transaction.user,
            transaction.amount,
            transaction.data,
            transaction.isExecuted,
            transaction.noOfConfirmation
        );
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    receive() external payable {
        emit DepositEth(msg.sender, msg.value);
    }

    function createTransaction(
        address user,
        bytes memory data,
        uint256 amount
    ) public OnlyOwner {
        uint256 _txIndex = transactions.length;
        transactions.push(
            Transaction({
                user: user,
                amount: amount,
                data: data,
                isExecuted: false,
                noOfConfirmation: 0
            })
        );
        emit SubmitTransaction(
            user,
            _txIndex,
            "Transaction created and submitted sucessfully"
        );
    }

    function confirmTransaction(uint256 _txIndex) public OnlyOwner {
        require(_txIndex < transactions.length, "Transaction not found");

        Transaction storage transaction = transactions[_txIndex];
        isConfirmed[_txIndex][msg.sender] = true;
        transaction.noOfConfirmation += 1;
        emit ConfirmTransaction(msg.sender, _txIndex, "Confirmed transaction");
    }

    function revokeTransaction(uint256 _txIndex) public OnlyOwner {
        require(_txIndex < transactions.length, "Transaction not found");
        require(
            isConfirmed[_txIndex][msg.sender] == true,
            "Owner never confirmed this transaction"
        );
        Transaction storage transaction = transactions[_txIndex];
        require(
            transaction.isExecuted == false,
            "Transaction already executed"
        );
        transaction.noOfConfirmation -= 1;
        emit RevokeTransaction(msg.sender, _txIndex, "Revoked transaction");
    }

    function executeTransaction(
        uint256 _txIndex
    ) public OnlyOwner OnlyConfirmedTransaction(_txIndex) {
        require(
            address(this).balance >= transactions[_txIndex].amount,
            "Insufficient funds"
        );
        Transaction storage transaction = transactions[_txIndex];
        require(
            transaction.isExecuted == false,
            "Transaction already executed"
        );
        transaction.isExecuted = true;
        (bool success, ) = transaction.user.call{value: transaction.amount}(
            transaction.data
        );
        require(success, "Transaction failed");
        emit ExecuteTransaction(msg.sender, _txIndex, "Excecuted successfully");
    }
}
