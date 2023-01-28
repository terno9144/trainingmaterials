// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract Op {
    /* 1 uint demo;    
    *
    * 2 using a single cell (32 bytes)
    * uint128 a = 1; 
    * uint128 b = 1; 
    * uint256 с = 1; 
    *
    * 3 If we use only one variable, then it is more profitable to use uint instead of uint8:
    * uint256 a = 1;
    *
    * 4 using static values: bytes32 public hash = "9F86D081884C7D659A2FEAA0C55AD015A3BF4F1B2B0B822CD15D6C15B0F00A08";
    *
    * using static arrays
    *
    * 5 uint8[] arr = [1, 2, 3]; better
    *
    * using fewer functions, less code fragmentation
    *
    * use strings that fit in 32 bytes
    *
    * 6 using intermediate variables:
    uint public result = 1;
    function doWork(uint[] memory data) public {
        uint temp = 1;
        for(uint i = 0; i < data.length) {
            temp *= data[i];
        }
        result = temp;
    }
    */
}

contract Un {
    /* 1 uint demo = 0;
    *
    * 2 using a multy cells
    * uint128 a = 1;
    * uint256 с = 1; 
    * uint128 b = 1;
    *
    * 3 uint8 a = 1; 
    *
    * 4 bytes32 puclic hash = keccak256(abi.encodePacked("test"));
    *
    * 5 uint[] arr = [1, 2, 3];
    *
    * 6 
    uint public result = 1;
    function doWork(uint[] memory data) public {
        for(uint i = 0; i < data.length) {
            result *= data[i];
        }
    }
    */
}