main = async () => {

  const myContract = await ethers.getContractFactory("ethernaut")
  const mm = myContract.attach("0xCDdb8134541A5A92D0ce70af95AF2f27C631160B")

  //call the function
  //
  await mm.attack()

}

main()
