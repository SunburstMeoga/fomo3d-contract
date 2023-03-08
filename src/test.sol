//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

contract Test {
    uint public bn;
    uint public prev;

    constructor() {
        
    }

    function begin() external {
        bn = block.number + 5;
        prev = block.prevrandao;
    }

    function verify() external {

    }
}
