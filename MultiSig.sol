// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSig {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Confirm(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid threshold");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    receive() external payable { emit Deposit(msg.sender, msg.value); }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false, numConfirmations: 0}));
        emit Submit(transactions.length - 1);
    }

    function confirmTransaction(uint _txId) public onlyOwner {
        require(!isConfirmed[_txId][msg.sender], "Already confirmed");
        transactions[_txId].numConfirmations += 1;
        isConfirmed[_txId][msg.sender] = true;
        emit Confirm(msg.sender, _txId);
    }

    function executeTransaction(uint _txId) public {
        Transaction storage transaction = transactions[_txId];
        require(transaction.numConfirmations >= required, "Not enough confirmations");
        require(!transaction.executed, "Already executed");

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "TX failed");
        emit Execute(_txId);
    }
}
