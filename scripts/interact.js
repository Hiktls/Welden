// scripts/interact.js

const hre = require("hardhat");

async function main() {
  const SystemManager = await hre.ethers.getContractFactory("SystemManager");
  const systemManager = await SystemManager.deploy("0xdAC17F958D2ee523a2206206994597C13D831ec7");
  
  console.log("Contract deployed at:",await systemManager.getAddress());

  // call a function manually:
  const ownerRestriction = await systemManager.restrictions(await (await hre.ethers.provider.getSigner()).getAddress());
  console.log("Deployer restriction level:", ownerRestriction.toString());

}

async function getMarkets() {
    const sys = await (await hre.ethers.getContractFactory("SystemManager")).deploy("0xdAC17F958D2ee523a2206206994597C13D831ec7");
    const options = ["Yes", "No"];

    await sys.addMarket("Test Market","desc",options);
    // Get markets
    const markets = await sys.listMarkets();
    console.log(markets)

}


main().catch(err => {
    console.error(err)
})

