require("dotenv").config();

const { API_URL_RINKEBY, PRIVATE_KEY } = process.env;

const provider = new ethers.providers.JsonRpcProvider(API_URL_RINKEBY);
const signer = new ethers.Wallet(`0x${PRIVATE_KEY}`, provider);

const WETH = "0xc778417E063141139Fce010982780140Aa0cD5Ab";
const DAI = "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735";

const r = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

const IERC20_abi = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function balanceOf(address account) external view returns (uint)",
  "function transfer(address to, uint value) external returns (bool)",
];

const factory_abi = [
  "function getPair(address tokenA, address tokenB) external view returns (address pair)",
];

const router_abi = [
  "function getAmountsIn(uint amountOut, address[] memory path) public view returns (uint[] memory amounts)",
  "function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts)",
];

const dai_token = new ethers.Contract(DAI, IERC20_abi, signer);
const weth_token = new ethers.Contract(WETH, IERC20_abi, signer);
const router = new ethers.Contract(r, router_abi, signer);

const amount = ethers.utils.parseEther("2.0"); //WETH
const zero = ethers.utils.parseEther("0.0"); //zero
const lend = ethers.utils.parseEther("0.01"); //the token0 fee

const main = async () => {
  const gas_price = await provider.getGasPrice();

  const L = await ethers.getContractFactory("ok");
  const l = await L.deploy();
  await l.deployed();

  console.log(`deployed at ${l.address}`);

  console.log(" 🤑 🔥 🔥 🔥 🔥 🔥");
  console.log("follow the 🐇 & make the flash swap [WETH/DAI] 🚀");

  try {
    const tx = await l.start(DAI, WETH, zero, amount, {
      gasLimit: 300000,
      gasPrice: gas_price,
    });
    await tx.wait();
    console.log(tx);
  } catch (err) {
    console.log(`err =====> ${err}`);
  }
};

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
