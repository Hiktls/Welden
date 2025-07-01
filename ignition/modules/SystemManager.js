// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
module.exports = buildModule("SystemManager", (m) => {
  const sys = m.contract("SystemManager",[USDT]);

  return { sys };
});
