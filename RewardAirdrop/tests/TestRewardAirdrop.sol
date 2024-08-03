// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../contracts/RewardToken.sol";
import "../contracts/Governance.sol";

contract TestRewardAirdrop {
    RewardToken private rewardToken;
    Governance private governance;
    address private owner;

    event TestPassed(string testName);

    constructor() {
        owner = msg.sender;
    }

    function beforeEach() public {
        rewardToken = new RewardToken(1000000 * 10 ** 18);
        governance = new Governance(address(rewardToken));
    }

    function testInitialSupply() public {
        beforeEach();
        uint256 expectedSupply = 1000000 * 10 ** 18;
        require(rewardToken.totalSupply() == expectedSupply, "Initial supply mismatch");
        emit TestPassed("testInitialSupply");
    }

    function testMinting() public {
        beforeEach();
        rewardToken.mint(address(this), 100 * 10 ** 18);
        uint256 balance = rewardToken.balanceOf(address(this));
        require(balance == 100 * 10 ** 18, "Minting failed");
        emit TestPassed("testMinting");
    }

    function testAccountInitialization() public {
        beforeEach();
        governance.initializeAccount();
        (bool initialized, ) = governance.accounts(address(this));
        require(initialized == true, "Account initialization failed");
        emit TestPassed("testAccountInitialization");
    }

    function testProposalCreation() public {
        beforeEach();
        governance.initializeAccount();
        rewardToken.mint(address(this), 1000 * 10 ** 18);
        governance.createProposal("Test Proposal", 600);
        
        (uint256 id, address proposer, string memory description, uint256 voteCount, uint256 startTime, uint256 endTime, bool executed) = governance.proposals(0);
        require(proposer == address(this), "Proposal creation failed");
        require(keccak256(bytes(description)) == keccak256(bytes("Test Proposal")), "Proposal description mismatch");
        
        emit TestPassed("testProposalCreation");
    }

    function testVoting() public {
        beforeEach();
        governance.initializeAccount();
        rewardToken.mint(address(this), 1000 * 10 ** 18);
        governance.createProposal("Test Proposal", 600);
        governance.vote(0);
        
        (uint256 id, address proposer, string memory description, uint256 voteCount, uint256 startTime, uint256 endTime, bool executed) = governance.proposals(0);
        require(voteCount == 1000 * 10 ** 18, "Voting failed");
        
        emit TestPassed("testVoting");
    }

    function testLoyaltyPointsRedemption() public {
        beforeEach();
        governance.initializeAccount();
        rewardToken.mint(address(this), 1000 * 10 ** 18);
        governance.vote(0);
        governance.redeemLoyaltyPoints(1);
        uint256 balance = rewardToken.balanceOf(address(this));
        require(balance == 1001 * 10 ** 18, "Loyalty points redemption failed");
        
        emit TestPassed("testLoyaltyPointsRedemption");
    }
}
