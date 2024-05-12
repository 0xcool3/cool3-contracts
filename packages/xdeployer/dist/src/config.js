"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.xdeployConfigExtender = void 0;
const constants_1 = require("./constants");
const xdeployConfigExtender = (config, userConfig) => {
    const defaultConfig = {
        contract: undefined,
        constructorArgsPath: undefined,
        salt: undefined,
        signer: undefined,
        networks: [],
        rpcUrls: [],
        gasLimit: constants_1.GASLIMIT,
    };
    if (userConfig.xdeploy) {
        const customConfig = userConfig.xdeploy;
        config.xdeploy = {
            ...defaultConfig,
            ...customConfig,
        };
    }
    else {
        config.xdeploy = defaultConfig;
    }
};
exports.xdeployConfigExtender = xdeployConfigExtender;
//# sourceMappingURL=config.js.map