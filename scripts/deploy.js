const hre = require("hardhat");

async function main() {
  const Evm721StarterUSDCNFT = await hre.ethers.getContractFactory("Evm721StarterUSDC");
  const Evm721StarterUSDC = await Evm721StarterUSDCNFT.deploy("0x98339D8C260052B7ad81c28c16C0b98420f2B46a"); // goerli

  await Evm721StarterUSDC.deployed();

  console.log("Evm721StarterUSDC deployed to:", Evm721StarterUSDC.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
