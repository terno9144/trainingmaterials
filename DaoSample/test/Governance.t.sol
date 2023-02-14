// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import { MyToken } from "../src/MyToken.sol";
import { Governance } from "../src/Governance.sol";
import { Demo } from "../src/Demo.sol";


contract GovernanceTest is Test {
    Governance public governance;
    MyToken public myToken;
    Demo public demo;

    function setUp() public {
        myToken = new MyToken();
        governance = new Governance(myToken);
        demo = new Demo();
        demo.transferOwnership(address(governance));
    }

    function testWorks() public {
        (bool success, ) = address(governance).call{value: 100}("");
        require(success, "Transfer failed.");
        bytes32 propID = governance.propose(address(demo), 10, "pay(string)", bytes("test"), "Sample proposal");
        vm.warp(15);
        governance.vote(propID, 1);
        vm.warp(10000);
        vm.prank(address(governance), address(governance));
        governance.execute(address(demo), 10, "pay(string)", bytes("test"), keccak256("Sample proposal"));
    }
}