// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract VotingContract {
    address public owner;
    uint public immutable Comission;
    uint public maxCandidatesNum;
    uint public counter;

    struct Candidate {
        uint balance;
        bool existOnVoting;
    }

    struct Voting {
        uint startTime;
        uint winnerBalance;
        address winner;
        uint period;
        bool started;
        uint bank;
        mapping(address => Candidate) Candidates;
    }

    mapping(uint => Voting) private Votings;

    constructor(uint _comission, uint _maxCandidatesNum) {
        owner = msg.sender;
        Comission = _comission;
        maxCandidatesNum = _maxCandidatesNum;
    } 

    function addVoting(uint _period, address[] calldata _candidates) public onlyOwner {
        require(_candidates.length < maxCandidatesNum, "Too many candidates!");
        Votings[counter].period = _period;
        for (uint i; i < _candidates.length; i++) {
            addCandidate(counter, _candidates[i]);
        }

        emit VotingCreated(counter);
        counter++; 
    }

    function startVoting(uint _votingID) public onlyOwner {
        require(Votings[_votingID].started == false, "Voting has already started!");
        Votings[_votingID].started = true;
        Votings[_votingID].startTime = block.timestamp;

        emit VotingStarted(_votingID, Votings[_votingID].startTime);
    }

    function vote(uint _votingID, address _candidate) public payable {
        require(Votings[_votingID].started, "Voting has not started yet!");
        require(Votings[_votingID].Candidates[_candidate].existOnVoting, "No such candidate on this Voting!");
        require(Votings[_votingID].startTime + Votings[_votingID].period > block.timestamp, "Voting has already ended!");

        Votings[_votingID].bank += msg.value;
        Votings[_votingID].Candidates[_candidate].balance += msg.value;

        if (
            Votings[_votingID].Candidates[_candidate].balance > 
            Votings[_votingID].winnerBalance
        ) {
            Votings[_votingID].winnerBalance = Votings[_votingID].Candidates[_candidate].balance;
            Votings[_votingID].winner = _candidate;
        }
    }

    function withdrawPrize(uint _votingID) public {
        require(Votings[_votingID].started, "Voting not started yet");
        require(Votings[_votingID].startTime + Votings[_votingID].period < block.timestamp, "Voting is not over yet!");
        require(Votings[_votingID].winner == msg.sender, "You aren't the winner!");
        require(Votings[_votingID].bank > 0, "You have already received your prize!");

        uint256 amount = Votings[_votingID].bank;
        uint256 ownersComission = (Comission * amount) / 100;
        uint256 clearAmount = amount - ownersComission;
        Votings[_votingID].bank = 0;
        payable(owner).transfer(ownersComission);
        payable(msg.sender).transfer(clearAmount);
    }

    function getVotingInfo(uint _votingID) 
        public 
        view
        returns (
            uint, 
            uint,
            address,
            uint,
            bool,
            uint
        ) {
        return (
            Votings[_votingID].startTime,
            Votings[_votingID].winnerBalance,
            Votings[_votingID].winner,
            Votings[_votingID].period,
            Votings[_votingID].started,
            Votings[_votingID].bank
        );   
    }

    function editVotingPeriod(uint _votingID, uint _newPeriod) public onlyOwner {
        require(Votings[_votingID].started == false, "Voting has already started!");
        Votings[_votingID].period = _newPeriod;
    }

    function addCandidate(uint _votingID, address _candidate) public onlyOwner {
        require(Votings[_votingID].started == false, "Voting has already started!");
        Votings[_votingID].Candidates[_candidate].existOnVoting = true;

        emit CandidateInfo(_votingID, _candidate, true);
    }

    function removeCandidate(uint _votingID, address _candidate) public onlyOwner {
        require(Votings[_votingID].started == false, "Voting has already started!");
        Votings[_votingID].Candidates[_candidate].existOnVoting = false;

        emit CandidateInfo(_votingID, _candidate, false);
    }

    function checkCandidate(uint _votingID, address _candidate) public view returns (bool) {
        return (Votings[_votingID].Candidates[_candidate].existOnVoting);
    }

    function editNumberOfMaxCandidates(uint _newMaxCandidatesNum) public onlyOwner {
        maxCandidatesNum = _newMaxCandidatesNum;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You aren't an owner!");
        _;
    }

    event CandidateInfo(uint indexed votingID, address indexed candidate, bool existOnVoting);
    event VotingCreated(uint indexed votingID);
    event VotingStarted(uint indexed votingID, uint indexed startTime);
}