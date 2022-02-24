main = async () => {

  const Guildbox = await ethers.getContractFactory("Guildbox")

  const guildbox = await Guildbox.deploy()

  console.log("Contract deployed at address: ", guildbox.address)

}

main()
  .then( () => process.exit(0) )
  .catch( err => { console.log(err); process.exit(1) } )
