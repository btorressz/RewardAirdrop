// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./RewardToken.sol";
/**
 * @title Governance
 * @dev Implements governance mechanism using ERC20 tokens.
 */
contract Governance {
    using Counters for Counters.Counter;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 voteCount;
        uint256 startTime;
        uint256 endTime;
        bool executed;
    }

    struct Account {
        bool initialized;
        uint256 loyaltyPoints;
    }

    RewardToken public rewardToken;
    address public admin;
    Counters.Counter private _proposalIdCounter;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public votes;
    mapping(address => Account) public accounts;

    /// @notice Emitted when a proposal is created
    event ProposalCreated(uint256 id, address proposer, string description, uint256 startTime, uint256 endTime);

    /// @notice Emitted when a vote is cast
    event Voted(uint256 proposalId, address voter, uint256 weight);

    /// @notice Emitted when a proposal is executed
    event Executed(uint256 proposalId, bool success);

    /// @notice Emitted when loyalty points are redeemed
    event LoyaltyPointsRedeemed(address indexed user, uint256 points, uint256 tokens);

    /// @dev Error for unauthorized actions
    error Unauthorized(address caller);
    
    /// @dev Error for uninitialized accounts
    error UninitializedAccount(address account);

    /**
     * @dev Sets the token contract address.
     * @param _rewardToken Address of the ERC20 token contract used for governance.
     */
    constructor(address _rewardToken) {
        rewardToken = RewardToken(_rewardToken);
        admin = msg.sender;
    }

    /**
     * @notice Initializes an account.
     * @dev Must be called before the user can participate in governance or earn loyalty points.
     */
    function initializeAccount() external {
        accounts[msg.sender].initialized = true;
    }

    /**
     * @notice Creates a new proposal.
     * @dev Anyone holding tokens can create a proposal.
     * @param description Description of the proposal.
     * @param duration Duration of the voting period in seconds.
     */
    function createProposal(string calldata description, uint256 duration) external {
        if (!accounts[msg.sender].initialized) revert UninitializedAccount(msg.sender);

        uint256 proposalId = _proposalIdCounter.current();
        _proposalIdCounter.increment();

        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            description: description,
            voteCount: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            executed: false
        });

        emit ProposalCreated(proposalId, msg.sender, description, block.timestamp, block.timestamp + duration);
    }

    /**
     * @notice Votes on a proposal.
     * @dev One token equals one vote.
     * @param proposalId Id of the proposal to vote on.
     */
    function vote(uint256 proposalId) external {
        if (!accounts[msg.sender].initialized) revert UninitializedAccount(msg.sender);

        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting has not started");
        require(block.timestamp <= proposal.endTime, "Voting has ended");
        require(!votes[proposalId][msg.sender], "Already voted");

        uint256 voterBalance = rewardToken.balanceOf(msg.sender);
        require(voterBalance > 0, "No voting power");

        proposal.voteCount += voterBalance;
        votes[proposalId][msg.sender] = true;

        // Reward loyalty points for voting
        accounts[msg.sender].loyaltyPoints += 1;

        emit Voted(proposalId, msg.sender, voterBalance);
    }

    /**
     * @notice Executes a proposal.
     * @dev Only the admin can execute a proposal and only if the voting period has ended.
     * @param proposalId Id of the proposal to execute.
     */
    function executeProposal(uint256 proposalId) external {
        if (msg.sender != admin) revert Unauthorized(msg.sender);

        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting period has not ended");
        require(!proposal.executed, "Proposal already executed");

        // Implement the logic to execute the proposal
        // For simplicity, we'll assume all proposals pass if they reach this point.
        proposal.executed = true;

        emit Executed(proposalId, true);
    }

    /**
     * @notice Redeems loyalty points for tokens.
     * @dev Only users with initialized accounts can redeem points.
     * @param points Number of loyalty points to redeem.
     */
    function redeemLoyaltyPoints(uint256 points) external {
        if (!accounts[msg.sender].initialized) revert UninitializedAccount(msg.sender);
        require(accounts[msg.sender].loyaltyPoints >= points, "Insufficient loyalty points");

        // Define the conversion rate: 1 point = 1 token (for simplicity)
        uint256 tokens = points * 10**18;

        // Burn loyalty points
        accounts[msg.sender].loyaltyPoints -= points;

        // Mint tokens to the user
        rewardToken.mint(msg.sender, tokens);

        emit LoyaltyPointsRedeemed(msg.sender, points, tokens);
    }
}
