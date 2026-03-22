// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GasOptimizedVoting
 * @dev Implementation of Day 14: Bitwise operations, Struct packing, and Fixed-size types
 */
contract GasOptimizedVoting {
    
    struct Proposal {
        bytes32 name;       // Slot 1: Fixed size instead of string
        uint32 voteCount;   // Slot 2: Packed uints
        uint32 startTime;   // Slot 2
        uint32 endTime;     // Slot 2
        bool executed;      // Slot 2
    }

    Proposal[] public proposals;

    // Bit-mapping: Each bit in bytes32 represents a vote status for a proposalId
    mapping(address => bytes32) public votesRegistry;

    error AlreadyVoted();
    error VotingClosed();
    error InvalidProposal();

    /**
     * @dev Optimization: uint32 for timestamps and bytes32 for strings
     */
    function createProposal(bytes32 _name, uint32 _duration) external {
        proposals.push(Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp + _duration),
            executed: false
        }));
    }

    /**
     * @dev Optimization: Bitwise check (storage access reduction) and storage pointers
     */
    function vote(uint256 _proposalId) external {
        if (_proposalId >= proposals.length) revert InvalidProposal();
        
        // Cache in storage pointer to avoid redundant lookups
        Proposal storage p = proposals[_proposalId];
        
        if (block.timestamp > p.endTime) revert VotingClosed();

        // Bitwise logic: bytes32 as a bitset
        bytes32 voterFlags = votesRegistry[msg.sender];
        bytes32 mask = bytes32(1 << (_proposalId % 256));

        if ((voterFlags & mask) != 0) revert AlreadyVoted();

        // Update storage bitwise
        votesRegistry[msg.sender] = voterFlags | mask;
        p.voteCount++;
    }

    /**
     * @dev Optimization: View function (no gas cost off-chain)
     */
    function hasVoted(address _voter, uint256 _proposalId) public view returns (bool) {
        bytes32 mask = bytes32(1 << (_proposalId % 256));
        return (votesRegistry[_voter] & mask) != 0;
    }

    /**
     * @dev Returns proposal details including computed 'active' status
     */
    function getProposal(uint256 _proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ) {
        if (_proposalId >= proposals.length) revert InvalidProposal();
        Proposal storage p = proposals[_proposalId];
        
        return (
            p.name,
            p.voteCount,
            p.startTime,
            p.endTime,
            p.executed,
            block.timestamp <= p.endTime
        );
    }
}
