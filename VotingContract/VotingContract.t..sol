// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { VotingContract } from "../src/VotingContract.sol";

contract VotingTest is Test {
    VotingContract public votingContract;
    address[] public candidates = [0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC];

    function setUp() public {
        votingContract = new VotingContract(10, 10);
    }

    function testFail_TooManyCandidates() public {
        vm.expectRevert(bytes("Too many candidates!"));
        votingContract.addVoting(100, candidates);
    }

    function test_CreatesVoting() public {
        votingContract.addVoting(100, candidates);
        assertEq(votingContract.counter(), 1);
        votingContract.addVoting(100, candidates);
        assertEq(votingContract.counter(), 2);
    }

    function test_CandidateRemoved() public {
        votingContract.addVoting(100, candidates);
        votingContract.removeCandidate(0, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        assertEq(votingContract.checkCandidate(0, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8), false);         
    }

    function test_CandidateAdded() public {
        votingContract.addVoting(100, candidates);
        votingContract.addCandidate(0, 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc);
        assertEq(votingContract.checkCandidate(0, 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc), true);
    }

    function test_OnlyOwnerCanDeleteCandidate() public {
        votingContract.addVoting(100, candidates);
        vm.prank(address(0));
        vm.expectRevert(bytes("You aren't an owner!"));
        votingContract.removeCandidate(0, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    }

    function test_CantVoteBeforeStart() public {
        votingContract.addVoting(100, candidates);
        vm.expectRevert(bytes("Voting has not started yet!"));
        votingContract.vote(0, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    }

    function testFail_VoteForNotExistCandidate() public {
        votingContract.addVoting(100, candidates);
        votingContract.startVoting(0);
        votingContract.vote(0, 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f);
    }

    function test_VoteForAccount() public {
        votingContract.addVoting(1000, candidates);
        votingContract.startVoting(0);
        (bool success, ) = address(votingContract).call{value: 900}
            (abi.encodeWithSelector(votingContract.vote.selector, 0, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
        assertEq(success, true);
        vm.warp(1100);
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.expectRevert();
        votingContract.withdrawPrize(0);
    }

    function test_VoteAfterFinish() public {
        votingContract.addVoting(100, candidates);
        votingContract.startVoting(0);
        vm.warp(200);
        (bool success, ) = address(votingContract).call{value: 900}
            (abi.encodeWithSelector(votingContract.vote.selector, 0, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
        assertEq(success, false);
    }

    function test_CanChageCandidatesNum(uint _num) public {
        votingContract.editNumberOfMaxCandidates(_num);
        assertEq(votingContract.maxCandidatesNum(), _num);
    }

}
