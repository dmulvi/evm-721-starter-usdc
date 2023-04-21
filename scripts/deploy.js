const hre = require("hardhat");

async function main() {
    const Evm721StarterUSDCNFT = await hre.ethers.getContractFactory("Evm721StarterUSDC");
    const Evm721StarterUSDC = await Evm721StarterUSDCNFT.deploy(
        "0xFEca406dA9727A25E71e732F9961F680059eF1F9",
        "0xDa30ee0788276c093e686780C25f6C9431027234"
    );

    await Evm721StarterUSDC.deployed();

    console.log("Evm721StarterUSDC deployed to:", Evm721StarterUSDC.address);

    await new Promise(resolve => setTimeout(resolve, 10000));
    await hre.run("verify:verify", {
        address: Evm721StarterUSDC.address,
        constructorArguments: [
            "0xFEca406dA9727A25E71e732F9961F680059eF1F9",
            "0xDa30ee0788276c093e686780C25f6C9431027234"
        ]
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
