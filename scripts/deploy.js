const riteABI = require('../artifacts/contracts/RiteOfMoloch.sol/RiteOfMoloch.json')
// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
      "gets automatically created and destroyed every time. Use the Hardhat" +
      " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Factory = await ethers.getContractFactory("RiteOfMolochFactory");
  const factory = await Factory.deploy();
  await factory.deployed();

  console.log("Factory address:", factory.address);

  //Random data
  const initData = {
    membershipCriteria: "0x7bde8f8a3d59b42d0d8fab3a46e9f42e8e3c2de8",
    stakingAsset: "0x18e9262e68cc6c6004db93105cc7c001bb103e49",
    treasury: "0x7bde8f8a3d59b42d0d8fab3a46e9f42e8e3c2de8",
    threshold: 10,
    assetAmount: ethers.utils.parseEther('10'),
    duration: 10,
    name: "RiteOfMolochSBT",
    symbol: "SBTMoloch",
    baseUri: ""
  }

  const tx = await factory.createCohort(initData, 1);
  const receipt = await tx.wait()

  const riteAddress = receipt.events.filter(e => e.event == 'NewRiteOfMoloch')[0].args[0];

  console.log('RiteOfMoloch address', riteAddress);

  riteOfMoloch = new ethers.Contract(
    riteAddress,
    riteABI.abi,
    ethers.provider
  )

  //Checks to see if contract is deployed correcty. Treasury address should == 0x7bde8f8a3d59b42d0d8fab3a46e9f42e8e3c2de8
  const treasuryAddress = await riteOfMoloch.treasury();
  console.log('Treasury Address', treasuryAddress);
}

function saveFrontendFiles(token) {
  const fs = require("fs");
  const contractsDir = __dirname + "/../frontend/src/contracts";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + "/contract-address.json",
    JSON.stringify({ Token: token.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("Token");

  fs.writeFileSync(
    contractsDir + "/Token.json",
    JSON.stringify(TokenArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
