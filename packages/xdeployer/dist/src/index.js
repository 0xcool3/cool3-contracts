"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
/* eslint-disable @typescript-eslint/no-explicit-any */
const config_1 = require("hardhat/config");
const config_2 = require("./config");
const networks_1 = require("./networks");
const constants_1 = require("./constants");
const colour_codes_1 = require("./colour-codes");
require("./type-extensions");
const CreateX_json_1 = __importDefault(require("./abi/CreateX.json"));
const plugins_1 = require("hardhat/plugins");
require("@nomicfoundation/hardhat-ethers");
const fs = __importStar(require("fs"));
const path_1 = __importDefault(require("path"));
(0, config_1.extendConfig)(config_2.xdeployConfigExtender);
(0, config_1.task)("xdeploy", "Deploys the contract across all predefined networks").setAction(async (_, hre) => {
    await hre.run(constants_1.TASK_VERIFY_NETWORK_ARGUMENTS);
    await hre.run(constants_1.TASK_VERIFY_SUPPORTED_NETWORKS);
    await hre.run(constants_1.TASK_VERIFY_EQUAL_ARGS_NETWORKS);
    await hre.run(constants_1.TASK_VERIFY_SALT);
    await hre.run(constants_1.TASK_VERIFY_SIGNER);
    await hre.run(constants_1.TASK_VERIFY_CONTRACT);
    await hre.run(constants_1.TASK_VERIFY_GASLIMIT);
    await hre.run("compile");
    if (hre.config.xdeploy.rpcUrls && hre.config.xdeploy.networks) {
        const providers = [];
        const wallets = [];
        const signers = [];
        const create2Deployer = [];
        const createReceipt = [];
        const result = [];
        const dir = "./deployments";
        let initcode;
        let computedContractAddress;
        let chainId;
        let idx;
        console.log("\nThe deployment is starting... Please bear with me, this may take a minute or two. Anyway, WAGMI!");
        if (hre.config.xdeploy.constructorArgsPath && hre.config.xdeploy.contract) {
            const args = await Promise.resolve(`${path_1.default.normalize(path_1.default.join(hre.config.paths.root, hre.config.xdeploy.constructorArgsPath))}`).then(s => __importStar(require(s)));
            const contract = await hre.ethers.getContractFactory(hre.config.xdeploy.contract);
            const ext = hre.config.xdeploy.constructorArgsPath.split(".").pop();
            if (ext === "ts") {
                initcode = await contract.getDeployTransaction(...args.data);
            }
            else if (ext === "js") {
                initcode = await contract.getDeployTransaction(...args.default);
            }
        }
        else if (!hre.config.xdeploy.constructorArgsPath &&
            hre.config.xdeploy.contract) {
            const contract = await hre.ethers.getContractFactory(hre.config.xdeploy.contract);
            initcode = await contract.getDeployTransaction();
        }
        for (let i = 0; i < hre.config.xdeploy.rpcUrls.length; i++) {
            providers[i] = new hre.ethers.JsonRpcProvider(hre.config.xdeploy.rpcUrls[i]);
            wallets[i] = new hre.ethers.Wallet(hre.config.xdeploy.signer, providers[i]);
            signers[i] = wallets[i].connect(providers[i]);
            if (hre.config.xdeploy.networks[i] !== "hardhat" &&
                hre.config.xdeploy.networks[i] !== "localhost") {
                create2Deployer[i] = new hre.ethers.Contract(constants_1.CREATE2_DEPLOYER_ADDRESS, CreateX_json_1.default, signers[i]);
                if (hre.config.xdeploy.salt) {
                    try {
                        let counter = 0;
                        computedContractAddress = await create2Deployer[i].computeCreate2Address(hre.ethers.keccak256(hre.ethers.id(hre.config.xdeploy.salt)), hre.ethers.keccak256(initcode.data));
                        if (counter === 0) {
                            console.log(`\nYour deployment parameters will lead to the following contract address: ${colour_codes_1.GREEN}${computedContractAddress}${colour_codes_1.RESET}\n` +
                                `\n${colour_codes_1.YELLOW}=> If this does not match your expectation, given a previous deployment, you have either changed the value of${colour_codes_1.RESET}\n` +
                                `${colour_codes_1.YELLOW}the salt parameter or the bytecode of the contract!${colour_codes_1.RESET}\n`);
                        }
                        ++counter;
                    }
                    catch (err) {
                        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `The contract address could not be computed. Please check your contract name and constructor arguments.`);
                    }
                    if ((await providers[i].getCode(computedContractAddress)) !== "0x") {
                        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `The address of the contract you want to deploy already has existing bytecode on ${hre.config.xdeploy.networks[i]}.
              It is very likely that you have deployed this contract before with the same salt parameter value.
              Please try using a different salt value.`);
                    }
                    try {
                        createReceipt[i] = await create2Deployer[i].deployCreate2(hre.ethers.id(hre.config.xdeploy.salt), initcode.data, { gasLimit: hre.config.xdeploy.gasLimit });
                        chainId = createReceipt[i].chainId;
                        idx = networks_1.networks.indexOf(hre.config.xdeploy.networks[i]);
                        createReceipt[i] = await createReceipt[i].wait();
                        result[i] = {
                            network: hre.config.xdeploy.networks[i],
                            chainId: chainId.toString(),
                            contract: hre.config.xdeploy.contract,
                            txHash: createReceipt[i].hash,
                            txHashLink: hre.config.xdeploy.networks[i].slice(0, 8) == "filecoin"
                                ? `${networks_1.explorers[idx]}message/${createReceipt[i].hash}`
                                : hre.config.xdeploy.networks[i].slice(0, 16) ==
                                    "seiArcticTestnet"
                                    ? `${networks_1.explorers[idx]}transactions/${createReceipt[i].hash}`
                                    : `${networks_1.explorers[idx]}tx/${createReceipt[i].hash}`,
                            address: computedContractAddress,
                            addressLink: hre.config.xdeploy.networks[i].slice(0, 16) ==
                                "seiArcticTestnet"
                                ? `${networks_1.explorers[idx]}account/${computedContractAddress}`
                                : `${networks_1.explorers[idx]}address/${computedContractAddress}`,
                            receipt: createReceipt[i].toJSON(),
                            deployed: true,
                            error: undefined,
                        };
                        if (!fs.existsSync(dir)) {
                            fs.mkdirSync(dir);
                        }
                        const saveDir = path_1.default.normalize(path_1.default.join(hre.config.paths.root, "deployments", `${hre.config.xdeploy.contract}_${hre.config.xdeploy.networks[i]}_deployment.json`));
                        fs.writeFileSync(saveDir, JSON.stringify(result[i]));
                        console.log(`\n${colour_codes_1.GREEN}----------------------------------------------------------${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.GREEN}><><><><           XDEPLOY DEPLOYMENT ${i + 1}           ><><><><${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.GREEN}----------------------------------------------------------${colour_codes_1.RESET}\n\n` +
                            `Deployment status: ${colour_codes_1.GREEN}successful${colour_codes_1.RESET}\n\n` +
                            `Network: ${colour_codes_1.GREEN}${result[i].network}${colour_codes_1.RESET}\n\n` +
                            `Chain ID: ${colour_codes_1.GREEN}${result[i].chainId}${colour_codes_1.RESET}\n\n` +
                            `Contract name: ${colour_codes_1.GREEN}${result[i].contract}${colour_codes_1.RESET}\n\n` +
                            `Contract creation transaction hash: ${colour_codes_1.GREEN}${result[i].txHashLink}${colour_codes_1.RESET}\n\n` +
                            `Contract address: ${colour_codes_1.GREEN}${result[i].addressLink}${colour_codes_1.RESET}\n\n` +
                            `Transaction details written to: ${colour_codes_1.GREEN}${saveDir}${colour_codes_1.RESET}\n`);
                    }
                    catch (err) {
                        result[i] = {
                            network: hre.config.xdeploy.networks[i],
                            chainId: undefined,
                            contract: hre.config.xdeploy.contract,
                            txHash: undefined,
                            txHashLink: undefined,
                            address: computedContractAddress,
                            addressLink: undefined,
                            receipt: undefined,
                            deployed: false,
                            error: err,
                        };
                        if (!fs.existsSync(dir)) {
                            fs.mkdirSync(dir);
                        }
                        const saveDir = path_1.default.normalize(path_1.default.join(hre.config.paths.root, "deployments", `${hre.config.xdeploy.contract}_${hre.config.xdeploy.networks[i]}_deployment_debug.json`));
                        fs.writeFileSync(saveDir, JSON.stringify(result[i]));
                        console.log(`\n${colour_codes_1.RED}----------------------------------------------------------${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.RED}><><><><           XDEPLOY DEPLOYMENT ${i + 1}           ><><><><${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.RED}----------------------------------------------------------${colour_codes_1.RESET}\n\n` +
                            `Deployment status: ${colour_codes_1.RED}failed${colour_codes_1.RESET}\n\n` +
                            `Network: ${colour_codes_1.RED}${result[i].network}${colour_codes_1.RESET}\n\n` +
                            `Contract name: ${colour_codes_1.RED}${result[i].contract}${colour_codes_1.RESET}\n\n` +
                            `Error details written to: ${colour_codes_1.RED}${saveDir}${colour_codes_1.RESET}\n\n` +
                            `${colour_codes_1.RED}=> Debugging hint: Many deployment errors are due to a too low gasLimit or a reused salt parameter value.${colour_codes_1.RESET}\n`);
                    }
                }
            }
            else if (hre.config.xdeploy.networks[i] === "hardhat" ||
                hre.config.xdeploy.networks[i] === "localhost") {
                let hhcreate2Deployer = await hre.ethers.getContractFactory("Create2DeployerLocal");
                if (hre.config.xdeploy.networks[i] === "localhost") {
                    hhcreate2Deployer = await hre.ethers.getContractFactory("Create2DeployerLocal", signers[i]);
                }
                create2Deployer[i] = await hhcreate2Deployer.deploy();
                if (hre.config.xdeploy.salt) {
                    try {
                        let counter = 0;
                        computedContractAddress = await create2Deployer[i].computeCreate2Address(hre.ethers.keccak256(hre.ethers.id(hre.config.xdeploy.salt)), hre.ethers.keccak256(initcode.data));
                        if (counter === 0) {
                            console.log(`\nYour deployment parameters will lead to the following contract address: ${colour_codes_1.GREEN}${computedContractAddress}${colour_codes_1.RESET}\n` +
                                `\n${colour_codes_1.YELLOW}=> If this does not match your expectation, given a previous deployment, you have either changed the value of${colour_codes_1.RESET}\n` +
                                `${colour_codes_1.YELLOW}the salt parameter or the bytecode of the contract!${colour_codes_1.RESET}\n`);
                        }
                        ++counter;
                    }
                    catch (err) {
                        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `The contract address could not be computed. Please check your contract name and constructor arguments.`);
                    }
                    try {
                        createReceipt[i] = await create2Deployer[i].deployCreate2(hre.ethers.id(hre.config.xdeploy.salt), initcode.data, { gasLimit: hre.config.xdeploy.gasLimit });
                        chainId = createReceipt[i].chainId;
                        idx = networks_1.networks.indexOf(hre.config.xdeploy.networks[i]);
                        createReceipt[i] = await createReceipt[i].wait();
                        result[i] = {
                            network: hre.config.xdeploy.networks[i],
                            chainId: chainId.toString(),
                            contract: hre.config.xdeploy.contract,
                            txHash: createReceipt[i].hash,
                            txHashLink: networks_1.explorers[idx],
                            address: computedContractAddress,
                            addressLink: networks_1.explorers[idx],
                            receipt: createReceipt[i].toJSON(),
                            deployed: true,
                            error: undefined,
                        };
                        if (!fs.existsSync(dir)) {
                            fs.mkdirSync(dir);
                        }
                        const saveDir = path_1.default.normalize(path_1.default.join(hre.config.paths.root, "deployments", `${hre.config.xdeploy.contract}_${hre.config.xdeploy.networks[i]}_deployment.json`));
                        fs.writeFileSync(saveDir, JSON.stringify(result[i]));
                        console.log(`\n${colour_codes_1.GREEN}----------------------------------------------------------${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.GREEN}><><><><           XDEPLOY DEPLOYMENT ${i + 1}           ><><><><${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.GREEN}----------------------------------------------------------${colour_codes_1.RESET}\n\n` +
                            `Deployment status: ${colour_codes_1.GREEN}successful${colour_codes_1.RESET}\n\n` +
                            `Network: ${colour_codes_1.GREEN}${result[i].network}${colour_codes_1.RESET}\n\n` +
                            `Chain ID: ${colour_codes_1.GREEN}${result[i].chainId}${colour_codes_1.RESET}\n\n` +
                            `Contract name: ${colour_codes_1.GREEN}${result[i].contract}${colour_codes_1.RESET}\n\n` +
                            `Contract creation transaction: ${colour_codes_1.GREEN}${result[i].txHash}${colour_codes_1.RESET}\n\n` +
                            `Contract address: ${colour_codes_1.GREEN}${result[i].address}${colour_codes_1.RESET}\n\n` +
                            `Transaction details written to: ${colour_codes_1.GREEN}${saveDir}${colour_codes_1.RESET}\n`);
                    }
                    catch (err) {
                        result[i] = {
                            network: hre.config.xdeploy.networks[i],
                            chainId: undefined,
                            contract: hre.config.xdeploy.contract,
                            txHash: undefined,
                            txHashLink: undefined,
                            address: computedContractAddress,
                            addressLink: undefined,
                            receipt: undefined,
                            deployed: false,
                            error: err,
                        };
                        if (!fs.existsSync(dir)) {
                            fs.mkdirSync(dir);
                        }
                        const saveDir = path_1.default.normalize(path_1.default.join(hre.config.paths.root, "deployments", `${hre.config.xdeploy.contract}_${hre.config.xdeploy.networks[i]}_deployment_debug.json`));
                        fs.writeFileSync(saveDir, JSON.stringify(result[i]));
                        console.log(`\n${colour_codes_1.RED}----------------------------------------------------------${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.RED}><><><><           XDEPLOY DEPLOYMENT ${i + 1}           ><><><><${colour_codes_1.RESET}\n` +
                            `${colour_codes_1.RED}----------------------------------------------------------${colour_codes_1.RESET}\n\n` +
                            `Deployment status: ${colour_codes_1.RED}failed${colour_codes_1.RESET}\n\n` +
                            `Network: ${colour_codes_1.RED}${result[i].network}${colour_codes_1.RESET}\n\n` +
                            `Contract name: ${colour_codes_1.RED}${result[i].contract}${colour_codes_1.RESET}\n\n` +
                            `Error details written to: ${colour_codes_1.RED}${saveDir}${colour_codes_1.RESET}\n\n` +
                            `${colour_codes_1.RED}=> Debugging hint: Many deployment errors are due to a too low gasLimit or a reused salt parameter value.${colour_codes_1.RESET}\n`);
                    }
                }
            }
        }
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_NETWORK_ARGUMENTS).setAction(async (_, hre) => {
    if (!hre.config.xdeploy.networks ||
        hre.config.xdeploy.networks.length === 0) {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `Please provide at least one deployment network via the hardhat config.
        E.g.: { [...], xdeploy: { networks: ["sepolia", "holesky"] }, [...] }
        The current supported networks are ${networks_1.networks}.`);
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_SUPPORTED_NETWORKS).setAction(async (_, hre) => {
    const unsupported = hre?.config?.xdeploy?.networks?.filter((v) => !networks_1.networks.includes(v));
    if (unsupported && unsupported.length > 0) {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `You have tried to configure a network that this plugin does not yet support,
      or you have misspelled the network name. The currently supported networks are
      ${networks_1.networks}.`);
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_EQUAL_ARGS_NETWORKS).setAction(async (_, hre) => {
    if (hre.config.xdeploy.networks &&
        hre.config.xdeploy.rpcUrls &&
        hre.config.xdeploy.rpcUrls.length !== hre.config.xdeploy.networks.length) {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `The parameters "network" and "rpcUrls" do not have the same length.
      Please ensure that both parameters have the same length, i.e. for each
      network there is a corresponding rpcUrls entry.`);
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_SALT).setAction(async (_, hre) => {
    if (!hre.config.xdeploy.salt || hre.config.xdeploy.salt === "") {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `Please provide an arbitrary value as salt.
      E.g.: { [...], xdeploy: { salt: "WAGMI" }, [...] }.`);
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_SIGNER).setAction(async (_, hre) => {
    if (!hre.config.xdeploy.signer || hre.config.xdeploy.signer === "") {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `Please provide a signer private key. We recommend using Hardhat configuration variables.
      See https://hardhat.org/hardhat-runner/docs/guides/configuration-variables.
      E.g.: { [...], xdeploy: { signer: vars.get("PRIVATE_KEY", "") }, [...] }.`);
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_CONTRACT).setAction(async (_, hre) => {
    if (!hre.config.xdeploy.contract || hre.config.xdeploy.contract === "") {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `Please specify the contract name of the smart contract to be deployed.
      E.g.: { [...], xdeploy: { contract: "ERC20" }, [...] }.`);
    }
});
(0, config_1.subtask)(constants_1.TASK_VERIFY_GASLIMIT).setAction(async (_, hre) => {
    if (hre.config.xdeploy.gasLimit &&
        hre.config.xdeploy.gasLimit > 15 * 10 ** 9) {
        throw new plugins_1.NomicLabsHardhatPluginError(constants_1.PLUGIN_NAME, `Please specify a lower gasLimit. Each block has currently 
      a target size of 15 million gas.`);
    }
});
//# sourceMappingURL=index.js.map