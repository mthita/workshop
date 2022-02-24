require("dotenv").config();

const { API_URL_ROBSTEN, PRIVATE_KEY } = process.env;

const provider = new ethers.providers.JsonRpcProvider(API_URL_ROBSTEN);
const signer = new ethers.Wallet(`0x${PRIVATE_KEY}`, provider);

const WETH = "0xc778417E063141139Fce010982780140Aa0cD5Ab";
const DAI = "0xaD6D458402F60fD3Bd25163575031ACDce07538D";

const uniRouter_address = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

const val = ethers.utils.parseEther("0.10");

const uni_abi = [
  "function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts)",
  "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)",
];

const IERC20_abi = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function balanceOf(address account) external view returns (uint)",
];

const main = async () => {
  const gas_price = await provider.getGasPrice();
  const [owner] = await ethers.getSigners();

  const uniRouter = new ethers.Contract(uniRouter_address, uni_abi, signer);
  const token = new ethers.Contract(DAI, IERC20_abi, signer);

  amountsOut0 = await uniRouter.getAmountsOut(val, [WETH, DAI]);

  console.log(
    `The balance in DAI in owner is ${ethers.utils.formatEther(
      await token.balanceOf(owner.address)
    )}`
  );
  console.log(
    `get the max amount of a pair [WETH, DAI] -> ${ethers.utils.formatEther(
      val
    )} and amountOutMin -> ${ethers.utils.formatEther(amountsOut0[1])}  DAI`
  );
  console.log(
    `Approve my uniRouter to spend the ${ethers.utils.formatEther(
      val
    )} from my wallet`
  );
  const ok = await token.approve(uniRouter.address, val);
  console.log("waiting approving...");
  await ok.wait();

  if (ok) {
    console.log("Approve ok!\nMake the swap WETH -> DAI");
    const tx = await uniRouter.swapExactTokensForTokens(
      val,
      amountsOut0[1],
      [WETH, DAI],
      owner.address,
      Date.now() + 1000 * 60,
      { gasLimit: 300000, gasPrice: gas_price }
    );
    await tx.wait();
  }

  console.log(`Success!`);
  console.log(
    `The new balance in DAI in owner is ${ethers.utils.formatEther(
      await token.balanceOf(owner.address)
    )}`
  );
};

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
