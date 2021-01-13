var BirdOracle = artifacts.require("../contracts/BirdOracle.sol");

module.exports = function (deployer, network) {
  deployer.deploy(BirdOracle);
};