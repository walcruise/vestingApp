pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingDApp is Ownable {
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

    mapping(address => Organization) public organizations;
    mapping(address => mapping(address => VestingSchedule)) public vestingSchedules;
    mapping(address => address[]) public stakeholders; // List of stakeholders per organization
    mapping(address => mapping(address => bool)) public whitelisted;
    mapping(address => uint256) public organizationBalances;

    event OrganizationRegistered(address indexed org, string name, address token);
    event StakeholderWhitelisted(address indexed org, address indexed stakeholder);
    event VestingScheduleAdded(address indexed org, address indexed stakeholder, uint256 amount, uint256 startTime, uint256 duration);
    event TokensClaimed(address indexed org, address indexed stakeholder, uint256 amount);
    event TokensDeposited(address indexed org, uint256 amount);

    constructor() Ownable() {}

    modifier onlyRegisteredOrg() {
        require(organizations[msg.sender].isRegistered, "Not a registered organization");
        _;
    }

    function registerOrganization(string memory _name, address _token) external {
        require(!organizations[msg.sender].isRegistered, "Already registered");
        require(_token != address(0), "Invalid token address");

        organizations[msg.sender] = Organization({
            name: _name,
            token: _token,
            isRegistered: true
        });

        emit OrganizationRegistered(msg.sender, _name, _token);
    }

    function depositTokens(uint256 amount) external onlyRegisteredOrg {
        require(amount > 0, "Amount must be greater than 0");

        IERC20 token = IERC20(organizations[msg.sender].token);
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        organizationBalances[msg.sender] += amount;
        emit TokensDeposited(msg.sender, amount);
    }

    function whitelistStakeholder(address stakeholder) external onlyRegisteredOrg {
        require(stakeholder != address(0), "Invalid stakeholder address");

        whitelisted[msg.sender][stakeholder] = true;
        emit StakeholderWhitelisted(msg.sender, stakeholder);
    }

    function addStakeholder(
        address stakeholder,
        uint256 amount,
        uint256 startTime,
        uint256 duration
    ) external onlyRegisteredOrg {
        require(whitelisted[msg.sender][stakeholder], "Stakeholder not whitelisted");
        require(vestingSchedules[msg.sender][stakeholder].amount == 0, "Vesting schedule already exists");
        require(amount > 0, "Amount must be greater than 0");
        require(startTime >= block.timestamp, "Start time must be in the future");
        require(duration > 0, "Duration must be greater than 0");
        require(organizationBalances[msg.sender] >= amount, "Insufficient token balance");

        vestingSchedules[msg.sender][stakeholder] = VestingSchedule({
            startTime: startTime,
            duration: duration,
            amount: amount,
            claimed: false
        });

        stakeholders[msg.sender].push(stakeholder); // Add stakeholder to the list
        organizationBalances[msg.sender] -= amount;
        emit VestingScheduleAdded(msg.sender, stakeholder, amount, startTime, duration);
    }

    function claimTokens(address org) external {
        require(organizations[org].isRegistered, "Organization not registered");
        
        VestingSchedule storage schedule = vestingSchedules[org][msg.sender];

        require(schedule.amount > 0, "No vesting schedule");
        require(!schedule.claimed, "Already claimed");
        require(block.timestamp >= schedule.startTime + schedule.duration, "Vesting period not ended");

        schedule.claimed = true;

        IERC20 token = IERC20(organizations[org].token);
        require(token.transfer(msg.sender, schedule.amount), "Token transfer failed");

        emit TokensClaimed(org, msg.sender, schedule.amount);
    }

    function getAllVestingSchedules(address org) external view returns (VestingSchedule[] memory schedules, address[] memory stakeholderAddresses) {
        require(organizations[org].isRegistered, "Organization not registered");
        
        uint256 count = stakeholders[org].length;
        schedules = new VestingSchedule[](count);
        stakeholderAddresses = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            address stakeholder = stakeholders[org][i];
            schedules[i] = vestingSchedules[org][stakeholder];
            stakeholderAddresses[i] = stakeholder;
        }

        return (schedules, stakeholderAddresses);
    }
}
