import "xdeployer";
import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-verify";
import {
  customChains,
  networksList,
  rpcUrlsList,
  rpcUrlsMap,
} from "./network.config";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  // settings: {
  //   optimizer: {
  //     enabled: true,
  //     runs: 1000,
  //   },
  // },
  networks: rpcUrlsMap,
  xdeploy: {
    contract: "COOL3",
    salt: "cool3.eth",
    signer: vars.get("PRIVATE_KEY", ""),
    networks: networksList,
    rpcUrls: rpcUrlsList,
    gasLimit: 5_500_000,  
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: vars.get("API_KEY", ""),
    customChains,
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
