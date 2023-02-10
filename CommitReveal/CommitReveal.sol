// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Timelock {
    address public owner;
    address[] public candidates = [
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];

    mapping(address => bytes32) public commits;
    mapping(address => uint) public votes;
    bool votingStopped;
    
    constructor() {
        owner == msg.sender;
    }
    
    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /* for the hashing our vote we can use this options:
    ethers.utils.solidityKeccak256(['address', 'bytes32', 'address'], ['address of candidate', 'secret word', 'address of voter']);
    for the secret word we can use ethers.utils.formatBytes32String('secret word');
    */

    function commitVote(bytes32 _hashedVote) external {
        require(!votingStopped);
        require(commits[msg.sender] == bytes32(0));

        commits[msg.sender] = _hashedVote;
    }

    function revealVote(address _candidate, bytes32 _secret) external {
        require(votingStopped);

        bytes32 commit = keccak256(abi.encodePacked(_candidate, _secret, msg.sender));

        require(commit == commits[msg.sender]);

        delete commits[msg.sender];

        votes[_candidate]++;
    }

    function stopVoting() external OnlyOwner {
        require(!votingStopped);

        votingStopped = true;
    }
}