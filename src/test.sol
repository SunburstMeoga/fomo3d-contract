//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function sqrt3(uint256 y) internal pure returns (uint256 z) {
        z = sqrt(y * 10**12);
        z = sqrt(z * 10**6);
        z = sqrt(z * 10**6);
    }

    function vote2power(uint256 y) internal pure returns (uint256 z) {
        z = (y * sqrt3(y)) / 17782794100;
    }
}


contract Test {
    uint public bn;
    uint public prev;

    constructor() {
        
    }

    function begin() external {
        bn = block.number + 5;
        prev = block.prevrandao;
    }

    function Shang(uint v) external pure returns(uint) {
        return Math.vote2power(v);
    }
}
