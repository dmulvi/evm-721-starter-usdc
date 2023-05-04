const hre = require("hardhat");
const fs = require("fs");

async function main() {
    // Read the contract address from the JSON file
    // const contractAddressJson = fs.readFileSync("contract_address.json");
    // const contractAddress = JSON.parse(contractAddressJson).address;
    const contractAddress = "0x6f96abdC01e8a28ef3C504af70B638b5E3Ca3dCA";

    // Connect to the deployed contract
    const YourContract = await hre.ethers.getContractFactory("Evm721StarterUSDC");
    const yourContract = YourContract.attach(contractAddress);

    // Call the setUsdcAddress function
    const usdcAddress = "0xFEca406dA9727A25E71e732F9961F680059eF1F9";
    const tx = await yourContract.setUsdcAddress(usdcAddress);

    // Wait for the transaction to be mined
    await tx.wait();

    console.log("USDC address set successfully");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
