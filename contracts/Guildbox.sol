//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Guildbox is ERC721URIStorage, Ownable {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenids;
  
  constructor() ERC721("Guildbox", "GIL") {} 

  function mintNFT(address receiver, string memory tokenURI) external onlyOwner returns (uint256) {

    _tokenids.increment();
    
    uint256 newNftTokenId = _tokenids.current();
    _mint(receiver, newNftTokenId);
    _setTokenURI(newNftTokenId, tokenURI);

    return newNftTokenId;

  }

}
