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
  networks: rpcUrlsMap,
  xdeploy: {
    contract: "COOL3",
    salt: "cool3.eth",
    signer: vars.get("PRIVATE_KEY", ""),
    networks: networksList,
    rpcUrls: rpcUrlsList,
    gasLimit: 1_500_000, // optional; default value is `1.5e6`
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
