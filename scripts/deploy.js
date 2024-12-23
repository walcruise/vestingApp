const hre = require("hardhat");

async function main() {
  // Deploy contract
  const VestingDApp = await hre.ethers.getContractFactory("VestingDApp");
  const vestingDApp = await VestingDApp.deploy();
  await vestingDApp.deployed();

  console.log("VestingDApp deployed to:", vestingDApp.address);

  // Wait for block confirmations
  await vestingDApp.deployTransaction.wait(5);

  // Verify contract
  await hre.run("verify:verify", {
    address: vestingDApp.address,
    constructorArguments: [],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });