// deploy/01_deploy_staker.js

const { ethers } = require("hardhat");
const { toWei } = require("../utils/format");
const { deployContract } = require("../utils/contracts");
const { verifyContract } = require("../utils/verify");
const { getExtraGasInfo } = require("../utils/misc");

async function main() {
  const { chainId } = await ethers.provider.getNetwork();
  const [owner] = await ethers.getSigners();

  const CONTRACT_NAME = "Staker";

  const exampleExternalContract = await ethers.getContractFactory(
    "ExampleExternalContract"
  );
  const externalContract = await exampleExternalContract.deploy();
  externalContract.deployed();
  console.log(externalContract.address);

  const args = [externalContract.address];
  const contract = await deployContract({
    signer: owner,
    contractName: CONTRACT_NAME,
    args: args,
  });

  try {
    if (chainId != 31337 && chainId != 1337) {
      const contractPath = `contracts/${CONTRACT_NAME}.sol:${CONTRACT_NAME}`;
      await verifyContract({
        contractPath: contractPath,
        contractAddress: contract.address,
        args: args,
      });
    }
  } catch (error) {
    console.log(error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
