require("dotenv").config({ path: "~/proj/smart_contracts/hardhat_platform/.env" })

const API_URL = process.env.API_URL
const API_KEY = process.env.API_KEY
const PUBLIC_KEY = process.env.PUBLIC_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY

const contract = require("../artifacts/contracts/hello_world.sol/hello_world.json")
const contractAddress = "0x45dd6337583106020f4b56dA39f309d7bc0a0FAC"

const provider = new ethers.providers.AlchemyProvider(network="rinkeby", API_KEY)
const signer = new ethers.Wallet(PRIVATE_KEY, provider)
const hello_world_contract = new ethers.Contract(contractAddress, contract.abi, signer) 

main = async () => {
  const message = await hello_world_contract.message()
  console.log(message)

  console.log(`update message`)
  const tx = await hello_world_contract.replaceMessage("this is the new message")
  tx.wait()

  const new_message = await hello_world_contract.message()
  console.log(`the new message is ${new_message}`)
}

main()
