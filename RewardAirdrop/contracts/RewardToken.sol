// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title RewardToken
 * @dev Implementation of the ERC20 Reward Token
 */
contract RewardToken is ERC20 {
    address public admin;

    /// @notice Emitted when tokens are minted
    event TokensMinted(address indexed to, uint256 amount);

    /// @dev Error for unauthorized mint attempt
    error UnauthorizedMint(address caller);

    /**
     * @dev Constructor that gives the deployer all of the existing tokens.
     * @param initialSupply Initial supply of tokens (in smallest units).
     */
    constructor(uint256 initialSupply) ERC20("RewardToken", "RWT") {
        admin = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    /**
     * @notice Mints new tokens.
     * @dev Only the admin can call this function.
     * @param to Address to which new tokens are minted.
     * @param amount Number of tokens to mint (in smallest units).
     */
    function mint(address to, uint256 amount) external {
        if (msg.sender != admin) revert UnauthorizedMint(msg.sender);
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
}
