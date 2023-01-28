// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

/*
* @author terno9144
* @notice We check the existence of a transaction through the Merkle tree
* @dev create a merkle tree in the constructor, and then check it through the verify function
* for verification, we need to manually enter higher-level transactions in the tree (want to update it!)
*/

contract MerkleTree {
    bytes32[] public hashes;
    string[4] transactions = [
        "TX1: Sherlock -> John",
        "TX2: John -> Patrick",
        "TX3: Kim -> John",
        "TX4: Robert -> Kim"
    ];

    constructor() {
        for(uint i = 0; i < transactions.length; i++) {
            hashes.push(makeHash(transactions[i]));
        }

        uint count = transactions.length;
        uint offset = 0;

        while(count > 0) {
            for(uint i = 0; i < count - 1; i += 2) {
                hashes.push(keccak256(abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])));
            }
            offset += count;
            count /= 2; 
        }
    }

    /*
    * Hash tree
    *         root
    *   H1-2        H3-4
    * H1    H2    H3    H4
    * Tx1   Tx2   Tx3   Tx4
    *
    * root hash (index 6): 0x79ab06a96379cd4de74fc70be64595587ec5625e1ea661a1e01fe2c031fa2a47
    * transaction we want to check: "TX2: John -> Patrick" (index 1)
    * proof contains transactions for verification, in this case it is: H1, H3-4:
    * H1: 0x42e81e4ee398c91795855f56994d566fcc0d0bd7777fe9d9ea1b9a518343918a   (index 0)
    * H3-4: 0x48cc43a8a9b3e60e143883eee57ffec069a3013c4882d6ffa87e5edcb53aff8d (index 5)
    */

    //verifying the hash
    function veryfy(string memory transaction, uint index, bytes32 root, bytes32[] memory proof) public pure returns(bool) {
        bytes32 hash = makeHash(transaction);
        for(uint i = 0; i < proof.length; i++) {
            bytes32 element = proof[i];
            if(index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, element));
            } else {
                hash = keccak256(abi.encodePacked(element, hash));
            }
            index /= 2;
        }
        return hash == root;
    }

    //this function creates a hash
    function makeHash(string memory input) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(input));
    }
}