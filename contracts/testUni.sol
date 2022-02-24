pragma solidity >=0.6.6 <0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract testFlashloan {
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    event Log(string message, uint256 val);

    function testLoan(
        address token0,
        address token1,
        uint256 _amount0,
        uint256 _amount1
    ) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(pair != address(0), "!pair");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        IUniswapV2Pair(pair).swap(
            _amount0,
            _amount1,
            address(this),
            bytes("flashloan")
        );
    }

    //end of the test function

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        address[] memory path = new address[](2);
        require(_amount0 == 0 || _amount1 == 0, "None is 0");

        uint256 amount = _amount0 == 0 ? _amount1 : _amount0;

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(pair != address(0), "!pair");
        require(_sender == address(this), "!sender");

        //need the pair WETH/DAI so we will take the getAmountsOut
        //path[0] = DAI
        //path[1] = WETH

        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;

        IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);

        //need to calc the fee
        uint256 fee = IUniswapV2Router02(ROUTER).getAmountsIn(amount, path)[0];

        uint256 amountToRepay = amount + fee;

        emit Log("amount", amount);
        emit Log("amount0", _amount0);
        emit Log("amount1", _amount1);
        emit Log("fee", fee);
        emit Log("amount to repay", amountToRepay);

        IERC20(token).transfer(msg.sender, amountToRepay);
    }
}
