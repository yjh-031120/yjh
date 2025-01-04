const hre = require("hardhat");

async function main() {
  // 获取合约工厂
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // 部署 MyNFT 合约
  const NFT = await hre.ethers.getContractFactory("MyNFT");
  const nft = await NFT.deploy();
  console.log("MyNFT contract deployed to:", nft.address);

  // 如果有 Market 合约，也可以在这里部署
  const Market = await hre.ethers.getContractFactory("Market");
  const market = await Market.deploy(nft.address);
  console.log("Market contract deployed to:", market.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
