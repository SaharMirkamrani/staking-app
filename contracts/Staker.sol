// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ExampleExternalContract.sol";

contract Staker {
    uint256 public deadline = block.timestamp + 30 seconds;
    uint public threshold = 100000000000000 wei;
    bool public executed;
    bool public openForWithdraw;

    ExampleExternalContract public example;

    constructor(address contractAddress) {
        example = ExampleExternalContract(contractAddress);
    }

    modifier notCompleted() {
        require(!example.completed(), "It is already completed.");
        _;
    }

    mapping(address => uint) public balances;

    function stake() public payable {
        if (block.timestamp >= deadline) revert("You ran out of time!");
        balances[msg.sender] += msg.value;
    }

    function execute() public notCompleted {
        require(!executed, "This function cannot be executed more than once.");
        if (block.timestamp >= deadline) {
            if (address(this).balance >= threshold) {
                example.complete{value: address(this).balance}();
                executed = true;
            } else {
                openForWithdraw = true;
            }
        } else {
            revert("Time is not up yet!");
        }
    }

    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function timeLeft() public view returns (uint left) {
        if (block.timestamp >= deadline) return 0;
        if (block.timestamp < deadline) {
            left = deadline - block.timestamp;
        }
    }

    function withdraw() public notCompleted {
        require(openForWithdraw, "You are not allowed to withdraw funds.");
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).call{value: amount};
    }

    receive() external payable {
        stake();
    }
}
