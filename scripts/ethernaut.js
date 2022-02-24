main = async () => {

  const Ethernaut = await ethers.getContractFactory("ethernaut")

  const ethernaut = await Ethernaut.deploy()

  await ethernaut.deployed()

  console.log(`deploy at ${ethernaut.address}`)

}

main()
  .then( () => process.exit(0) )
  .catch( err => { console.log(err); process.exit(1) } )
