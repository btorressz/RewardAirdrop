# RewardAirdrop

NOTE: This project is still in development. I am open to feedback.

## Contracts

### RewardToken.sol

This contract implements an ERC20 token that is used to reward users for their loyalty and participation in governance.

#### Key Features:
- **Minting**: Allows the admin to mint new tokens.
- **Initial Supply**: Sets the initial supply of tokens upon deployment.

### Governance.sol

This contract implements a governance mechanism that allows token holders to create and vote on proposals.

#### Key Features:
- **Account Initialization**: Users must initialize their accounts before participating.
- **Proposal Creation**: Token holders can create proposals.
- **Voting**: Token holders can vote on proposals, with each token representing one vote.
- **Loyalty Points**: Users earn loyalty points for voting, which can be redeemed for tokens.

## Test

### TestRewardAirdrop.sol

This test contract contains several test cases to validate the functionality of the `RewardToken` and `Governance` contracts.

#### Test Cases:
- **testInitialSupply**: Checks the initial supply of the token.
- **testMinting**: Verifies that minting new tokens works correctly.
- **testAccountInitialization**: Ensures account initialization works.
- **testProposalCreation**: Checks if creating a proposal works as expected.
- **testVoting**: Verifies the voting process.
- **testLoyaltyPointsRedemption**: Tests the loyalty points redemption process.

## Setup and Usage

### Prerequisites

- [Remix IDE](https://remix.ethereum.org/)
- Solidity Compiler version `0.8.18`


