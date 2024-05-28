export const rpcUrlsMap: any = {
  // ganache: {
  //   url: "http://127.0.0.1:8545",
  // },
  // ethMain:{
  //   url: 'https://cloudflare-eth.com'
  // },
  // baseMain: {
  //   url: "https://mainnet.base.org",
  // },
  lineaMain: {
    url: "https://rpc.linea.build",
  },
  arbitrumOne: {
    url: "https://arb1.arbitrum.io/rpc",
  },
  bscMain: {
    url: "https://rpc.ankr.com/bsc",
  },
  polygon: {
    url: "https://polygon-rpc.com",
  },
};

export const customChains = [
  // {
  //   network: "ganache",
  //   chainId: 1337,
  //   urls: {
  //     apiURL: "http://localhost:180/api",
  //     browserURL: "http://localhost:180",
  //   },
  // },
  // {
  //   network: "ethMain",
  //   chainId: 1,
  //   urls: {
  //     apiURL:'https://api.etherscan.io/api',
  //     browserURL:'https://etherscan.io',
  //   },
  // },
  // {
  //   network: "baseMain",
  //   chainId: 8453,
  //   urls: {
  //     apiURL: "https://api.basescan.org/api",
  //     browserURL: "https://basescan.org",
  //   },
  // },
  {
    network: "lineaMain",
    chainId: 59_144,
    urls: {
      apiURL: "https://api.lineascan.build/api",
      browserURL: "https://lineascan.build",
    },
  },

  {
    network: "arbitrumOne",
    chainId: 42_161,
    urls: {
      apiURL: "https://api.arbiscan.io/api",
      browserURL: "https://arbiscan.io",
    },
  },

  {
    network: "bscMain",
    chainId: 56,
    urls: {
      apiURL: "https://api.bscscan.com/api",
      browserURL: "https://bscscan.com",
    },
  },
  {
    network: "polygon",
    chainId: 137,
    urls: {
      apiURL: "https://api.polygonscan.com/api",
      browserURL: "https://polygonscan.com",
    },
  },
];

export const networksList = Object.keys(rpcUrlsMap);
export const rpcUrlsList = Object.keys(rpcUrlsMap).map((key) =>
  rpcUrlsMap[key].url
);
