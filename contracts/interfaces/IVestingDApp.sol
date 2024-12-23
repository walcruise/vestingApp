// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVestingDApp {
    struct VestingSchedule {
        uint256 startTime;
        uint256 duration;
        uint256 amount;
        bool claimed;
    }

    struct Organization {
        string name;
        address token;
        bool isRegistered;
    }

    event OrganizationRegistered(address indexed org, string name, address token);
    event StakeholderWhitelisted(address indexed org, address indexed stakeholder);
    event VestingScheduleAdded(address indexed org, address indexed stakeholder, uint256 amount, uint256 startTime, uint256 duration);
    event TokensClaimed(address indexed org, address indexed stakeholder, uint256 amount);
    event TokensDeposited(address indexed org, uint256 amount);

    function registerOrganization(string memory _name, address _token) external;
    function depositTokens(uint256 amount) external;
    function whitelistStakeholder(address stakeholder) external;
    function addStakeholder(address stakeholder, uint256 amount, uint256 startTime, uint256 duration) external;
    function claimTokens(address org) external;
}