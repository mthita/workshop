const { expect } = require("chai")
require('dotenv').config()

const { API_URL_MUMBAI, PRIVATE_KEY } = process.env

const WMATIC = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889" //polygon WMATIC 

const Abi = [
  // Some details about the token
  "function name() view returns (string)",
  "function symbol() view returns (string)",

  // Get the account balance
  "function balanceOf(address) view returns (uint)",
  //
   "function approve(address spender, uint value) external returns (bool)",
  // Send some of your tokens to someone else
  "function transfer(address to, uint amount)",
  //
  "function transferFrom(address _from, address _to, uint _value) returns (bool success)",

  // An event triggered whenever anyone transfers to someone else
  "event Transfer(address indexed from, address indexed to, uint amount)"
]

describe("envs -> balance", () => {
  it("sould initialize the provider and signer addresses", async () => {
    const provider = new ethers.providers.JsonRpcProvider(API_URL_MUMBAI);
    expect(provider)
    const signer   = new ethers.Wallet(`0x${PRIVATE_KEY}`, provider) 
    expect(signer)
    console.log("Implement the IERC20")
    const token = new ethers.Contract(WMATIC, Abi, signer)
    expect(token)
  })
})  

const provider = new ethers.providers.JsonRpcProvider(API_URL_MUMBAI);
const signer   = new ethers.Wallet(`0x${PRIVATE_KEY}`, provider) 
const token    = new ethers.Contract(WMATIC, Abi, signer)

describe("deploy -> loan", () => {
  it("deploy avLoaner --> flashloan", async () => {
    const addressesProvider = "0x178113104fEcbcD7fF8669a0150721e231F0FD4B"  
    const [owner] = await ethers.getSigners();
    
    const L = await ethers.getContractFactory("avLoaner")
    expect(L)
    const l = await L.deploy(addressesProvider)
    expect(l)

    await l.deployed()

    expect(l.address)
    console.log(`deployed at address => [${l.address}]`)

    console.log("attach the instance of the contract")

    const con = await L.attach(l.address);
    expect(con)

    console.log("We need to fund the contract so dont reverted")
    //the fund needs to be in WMATIC 
    console.log("check the balance of the contract in WMATIC so we can pay the fees") 
    const bal = await token.balanceOf(l.address)
    if(bal == 0){
      const fund = ethers.utils.parseUnits("0.1", 18) 
      const funding = await token.transfer(l.address, fund)
      await funding.wait()
      expect(funding)
    }
    console.log(`the balance of the contract is ${await token.balanceOf(l.address)} WMATIC`)

  

    const loan = ethers.utils.parseUnits("50", 18)
    const tx = await con.testflashloan(loan)
    //await tx.wait()
    expect(tx)
    console.log(tx)
      /*
    for(const event of tx.events){
      console.log(JSON.stringify(event))
    }
    */
  })

})

