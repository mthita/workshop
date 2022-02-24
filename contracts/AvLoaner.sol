// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "../aave/V2/contracts/FlashLoanReceiverBase.sol";
import { ILendingPool, ILendingPoolAddressesProvider, IERC20 } from "../aave/V2/contracts/Interfaces.sol";
import { SafeMath } from "../aave/V2/contracts/Libraries.sol";


contract avLoaner is FlashLoanReceiverBase {

  event Log(string, uint256);

  constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) public {} 

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params 
  ) 
  external override returns (bool) {

    // Approve the LendingPool contract allowance to *pull* the owed amount
    for(uint256 i = 0; i < assets.length; i++){

      emit Log("borrowed", amounts[i]);
      emit Log("fee", premiums[i]);

      uint256 totalDepth = amounts[i].add(premiums[i]);
      IERC20(assets[i]).approve(address(LENDING_POOL), totalDepth);
    }
    //repay aave
    return true;
    
  } 
  //the function that we call and make the loan
  function testflashloan(uint256 _amount) external {

    address WMATIC  = address(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889); //polygon WMATIC 
    address receiver = address(this);

    address[] memory assets = new address[](1);
    assets[0] = WMATIC; 
    uint256[] memory amounts = new uint256[](1);
    amounts[0] = _amount;
    
    //for the modes we have for flash loan set to 0
    uint256[] memory modes = new uint256[](1);
    modes[0] = 0;

    address onBehalfOf = address(this);

    bytes memory params = ""; //if we want to pass some extra data withs params abi.encode()

    uint16 referralCode = 0;

    LENDING_POOL.flashLoan(
      receiver,
      assets,
      amounts,
      modes,
      onBehalfOf,
      params,
      referralCode
    );
  }
  
}


