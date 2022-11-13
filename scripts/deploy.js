// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const chain_contract = await hre.ethers.getContractFactory("BullBear");
  const Chain_contract = await chain_contract.deploy(10,"0xB223B311ccbe30595Ad650f6453035caAF42bf3E","0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D");
  await Chain_contract.deployed();
  console.log("Chain_contract deployed to", Chain_contract.address);

// testing the mock aggregator
  // const mock_contract = await hre.ethers.getContractFactory("MockV3Aggregator");
  // const Mock_contract = await mock_contract.deploy(10,3034715771688);
  // await Mock_contract.deployed();
  // console.log("Mock_contract deployed to", Mock_contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
