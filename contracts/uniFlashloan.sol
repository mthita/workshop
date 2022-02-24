//THE CONTRACT IS FOR BORROW UNI AND SELL SUSHI
pragma solidity ^0.6.0;

import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

contract ok {
    address private immutable owner;

    address private constant factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant router =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private constant s = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    address private constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    IUniswapV2Router02 public souter;

    IERC20 wtoken = IERC20(WETH);

    event Log(string message, uint256 val);

    constructor() public {
        owner = msg.sender;
        souter = IUniswapV2Router02(s);
    }

    function start(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) external {
        //we will have the pair of WETH/DAI
        //path[0] = WETH path[1] = DAI
        address pair = IUniswapV2Factory(factory).getPair(token0, token1);

        require(pair != address(0), "!pair");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        bytes memory _data = abi.encode("flashloan");

        IUniswapV2Pair(pair).swap(amount0, amount1, address(this), _data);
    }

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        address[] memory path = new address[](2);

        uint256 amount = _amount0 == 0 ? _amount1 : _amount0;

        //the path is the array of prices to catch pricing info
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

        //uni -> sushi arbitrage
        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;

        require(
            msg.sender == IUniswapV2Factory(factory).getPair(token0, token1),
            "uniV2call msg.sender != pair"
        );
        require(_amount0 == 0 || _amount1 == 0, "cant be both 0");

        IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);
        //DAI
        token.approve(address(souter), amount);

        //calc the amountRequired to repay -- WETH --
        uint256 amountRequired = IUniswapV2Router02(router).getAmountsIn(
            amount,
            path
        )[0];

        require(amountRequired != 0, "!amountRequired");

        uint256 amountReceived = IUniswapV2Router02(souter)
            .swapExactTokensForTokens(
                amount,
                amountRequired,
                path,
                msg.sender,
                block.timestamp
            )[1];

        require(amountReceived != 0, "!amountReceived");

        //pointer to output token from sushi
        IERC20 outputToken = IERC20(_amount0 == 0 ? token0 : token1);

        require(outputToken == wtoken, "outputToken != WETH");
        //repay with other PAIR
        //maybe we need balance of the token0 for the fees
        require(amountReceived > amountRequired, "not enough tokens to trade");

        outputToken.transfer(msg.sender, amountRequired);
        outputToken.transfer(owner, amountReceived - amountRequired);

        emit Log("amount", amount);
        emit Log("amount0", _amount0);
        emit Log("amount1", _amount1);
        emit Log("amount to repay", amountRequired);
    }
}
