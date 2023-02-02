// SPDX-License-Identifier: BSD-2-Clause

pragma solidity ^0.8.16;

contract Roman {  
  
  function solution(uint n) public pure returns (string memory result) {
    uint16[13] memory dec = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    string[13] memory rom = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
    
    for (uint i; i < dec.length; i++) {
      while (n >= dec[i]) {
         n -= dec[i];
         result = string(abi.encodePacked(result, rom[i])); 
      }
   }
  }
}