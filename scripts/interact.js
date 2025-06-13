// scripts/interact.js

const hre = require("hardhat");

async function main() {
  const SystemManager = await hre.ethers.getContractFactory("SystemManager");
  const systemManager = await SystemManager.deploy();
  
  console.log("Contract deployed at:",await systemManager.getAddress());

  // call a function manually:
  const ownerRestriction = await systemManager.restrictions(await (await hre.ethers.provider.getSigner()).getAddress());
  console.log("Deployer restriction level:", ownerRestriction.toString());

  // Add a market:
  const options = ["Yes", "No"];
  await systemManager.addMarket("Test Market", "Description", options);
  const market = await systemManager.markets(0);
  console.log("Market name:",await market.marketName);

  
}

async function getMarkets() {
    const sys = await (await hre.ethers.getContractFactory("SystemManager")).deploy();
    const options = ["Yes", "No"];

    await sys.addMarket("Test Market","desc",options);
    // Get markets
    const markets = await sys.listMarkets();
    console.log(markets)

}


getMarkets().catch(err => {
    console.error(err)
})

