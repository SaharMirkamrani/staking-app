// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ExampleExternalContract {
    bool public completed;

    function complete() external payable {
        require(!completed, "This function has already been called.");
        require(msg.value > 0, "Please send some ether.");
        completed = true;
    }
}
