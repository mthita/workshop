//DEPLOYED AT ADDRESS : 0xEB537CaBb5bb8bcaE71108e2DdA1Ba9B8e576CAa

pragma solidity >=0.6.6 <0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract panSwap {
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    function startArbitage(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        address sourceRouter,
        address targetRouter
    ) external {
        address pair = IUniswapV2Factory(sourceRouter).getPair(token0, token1);
        require(pair != address(0), "!pair");

        IUniswapV2Pair(pair).swap(
            amount0,
            amount1,
            address(this),
            abi.encode(sourceRouter, targetRouter)
        );
    }

    function pancakeCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        address[] memory path = new address[](2);
        (address sourceRouter, address targetRouter) = abi.decode(
            _data,
            (address, address)
        );

        uint256 amount = _amount0 == 0 ? _amount1 : _amount0;

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

        require(
            msg.sender ==
                IUniswapV2Factory(sourceRouter).getPair(token0, token1),
            "!msg.sender"
        );
        require(_sender == address(this), "!_sender");

        require(_amount0 == 0 || _amount1 == 0, "Need at least on 0");

        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;

        IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);

        //here we approve the Router of the contract
        token.approve(address(targetRouter), amount);
        //calc the amount to reimbursed to the sourceRouter
        uint256 amountRequired = IUniswapV2Router02(sourceRouter).getAmountsIn(
            amount,
            path
        )[0];
        uint256 amountReceived = IUniswapV2Router02(targetRouter)
            .swapExactTokensForTokens(
                amount,
                amountRequired,
                path,
                address(this),
                block.timestamp
            )[1];

        require(amountReceived > amountRequired, "not enough tokens");
        IERC20 outputToken = IERC20(_amount0 == 0 ? token0 : token1);

        outputToken.transfer(msg.sender, amountRequired);
        outputToken.transfer(owner, amountReceived - amountRequired);
    }
}
