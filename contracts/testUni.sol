pragma solidity >=0.6.6 <0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract testOne {
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address private constant DAI = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;

    function testLoan(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(pair != address(0), "!pair");

        IUniswapV2Pair(pair).swap(
            amount0,
            amount1,
            address(this),
            abi.encode("flashloan")
        );
    }

    //end of the test function
    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        require(_amount0 == 0 || _amount1 == 0, "None is 0");

        //get the amount of the loan
        uint256 amount = _amount0 == 0 ? _amount1 : _amount0;
        require(_sender == address(this), "!sender");

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

        IERC20 repayToken = IERC20(_amount0 == 0 ? token1 : token0);

        uint256 fee = ((amount * 3) / 997) + 1;

        uint256 amountToRepay = amount + fee;
        //we will have a fee OOG error

        repayToken.transfer(msg.sender, amountToRepay);
    }
}
