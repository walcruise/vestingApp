const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VestingDApp", function () {
  let vestingDApp;
  let owner;
  let org;
  let stakeholder;
  let token;

  beforeEach(async function () {
    // Get signers
    [owner, org, stakeholder] = await ethers.getSigners();

    // Deploy mock ERC20 token
    const MockToken = await ethers.getContractFactory("MockERC20");
    token = await MockToken.deploy("Mock Token", "MTK");
    await token.deployed();

    // Deploy VestingDApp
    const VestingDApp = await ethers.getContractFactory("VestingDApp");
    vestingDApp = await VestingDApp.deploy();
    await vestingDApp.deployed();
  });

  describe("Organization Registration", function () {
    it("Should register an organization", async function () {
      await vestingDApp.connect(org).registerOrganization("Test Org", token.address);
      const orgData = await vestingDApp.organizations(org.address);
      expect(orgData.name).to.equal("Test Org");
      expect(orgData.token).to.equal(token.address);
      expect(orgData.isRegistered).to.be.true;
    });
  });
});