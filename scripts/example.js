main = async () => {

  const A = await ethers.getContractFactory("A")
  const B = await ethers.getContractFactory("B")

  const a = await A.deploy()
  const b = await B.deploy()


  console.log(`deploy A at ${a.address}`)
  console.log(`deploy B at ${b.address}`)

}

main()
  .then( () => process.exit(0) )
  .catch( err => { console.log(err); process.exit(1) } )
