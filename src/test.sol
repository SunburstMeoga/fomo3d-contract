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

contract Mining{
    uint public a;

    function set(uint b) public {
        a = b;
    }

    function initialize(uint b) public {
        a = b;
    }
}


contract Test {
    address public addr;

    constructor() {
    }

    function begin(uint a) external {
        address mining;
        bytes memory bytecode = type(Mining).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(a));
        assembly {
            mining := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        // 如果创建了一个重复的合约，会得到一个空地址，执行下面的方法出现错误而回滚
        Mining(mining).initialize(100);
        addr = mining;
    }

    function Shang(uint v) external pure returns(uint) {
        return Math.vote2power(v);
    }
}
