require("dotenv").config({ path: "~/proj/smart_contracts/hardhat_platform/.env" })

const API_URL = process.env.API_URL
const PUBLIC_KEY = process.env.PUBLIC_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY

const { createAlchemyWeb3 } = require("@alch/alchemy-web3")
const web3 = createAlchemyWeb3(API_URL)

//we need to add contract abi json file
//
const contract = require("../artifacts/contracts/Guildbox.sol/Guildbox.json")
//console.log(JSON.stringify(contract.abi))

//we need to create an instance of the deployed contract
const contractaddress = "0x93693d4aa0b6a0fdd2f2b85d93d11964c5a91cf6"
const nftContract = new web3.eth.Contract(contract.abi, contractaddress)

//we need to make a function that it will make the tx from our public address
//to the contact
//
module.exports.mintNFT = async (tokenURI) => {
  //here we get the tx nonce
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest")
  //hre we make the actual tx
  //
  const tx  =  {
      "from"  : PUBLIC_KEY,
      "to"    : contractaddress,
      "nonce" : nonce,
      "gas"   : 500000,
      "data"  : nftContract.methods.mintNFT(PUBLIC_KEY, tokenURI).encodeABI()
  }
  //for the tx to send we need to sign the tx with our pk

  const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY)

  //trigger the function signPromise
  signPromise
    .then(signedTx => {
      web3.eth.sendSignedTransaction(signedTx.rawTransaction, (err, hash) => {
        if(!err) {
          console.log("The hash of the tx is : ", hash)
        }
        else {
          console.log(`we have an error ==> ${err}`)
        }
      })
    }).catch(err => { console.log("Promise failed: ", err) })
  
}
//end of the mint function
//enter a pinata hash so we can run the mintNFT
//mintNFT("https://gateway.pinata.cloud/ipfs/QmXVoKkXUuP1HiUfsna7C8MiFZzYx1q6x2ZtxkUKhd8pAN")
//



