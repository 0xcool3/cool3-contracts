export const rpcUrlsMap: any = {
  // ganache: {
  //   url: "http://127.0.0.1:8545",
  // },
  baseMain: {
    url: "https://mainnet.base.org",
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
  {
    network: "baseMain",
    chainId: 1337,
    urls: {
      apiURL: "https://api.basescan.org/api",
      browserURL: "https://basescan.org",
    },
  },
];

export const networksList = Object.keys(rpcUrlsMap);
export const rpcUrlsList = Object.keys(rpcUrlsMap).map((key) =>
  rpcUrlsMap[key].url
);
