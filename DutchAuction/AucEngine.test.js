const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("AucEngine", function () {

  let owner
  let seller
  let buyer
  let auct

  beforeEach(async function() {
    [owner, seller, buyer] = await ethers.getSigners()
    const AucEngine = await ethers.getContractFactory("AucEngine", owner)
    auct = await AucEngine.deploy()
    await auct.deployed()
  })

  it("should be deployed", async function() {
    expect(auct.address).to.be.properAddress
  })

  it("sets right owner", async function() {
    const currentOwner = await auct.owner()
    expect(currentOwner).to.eq(owner.address)
  })

  async function getTimestamp(blockNumber) {
    return(await ethers.provider.getBlock(blockNumber)).timestamp 
  }

  describe("createAuction", function () {
    it("creates auction correctly", async function() {
      const duration = 60
      const tx = await auct.createAuction(ethers.utils.parseEther("0.001"), 3, "notebook", duration)
      const cAuction = await auct.auctions(0)
      expect(cAuction.item).to.eq("notebook")
      const timeStamp = await getTimestamp(tx.blockNumber) //we can get all the info about tx with console.log(tx)
      expect(cAuction.endsAt).to.eq(timeStamp + duration)
    })
  })

  function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms)) //we use this function to wait for a certain time in the test
  }

  describe("buy", function () {
    it("allows to buy", async function() {
      await auct.connect(seller).createAuction(ethers.utils.parseEther("0.001"), 3, "notebook", 60)
      this.timeout(5000) //5 seconds (indicates how long this test can work)
      await delay(1000)
      const buyTx = await auct.connect(buyer).buy(0, {value: ethers.utils.parseEther("0.001")})
      const cAuction = await auct.auctions(0)
      const finalPrice = cAuction.finalPrice
      await expect(() => buyTx).to.changeEtherBalance(seller, finalPrice - Math.floor((finalPrice * 10) / 100))
      await expect(buyTx).to.emit(auct, "AuctionEnded").withArgs(0, finalPrice, buyer.address)
    })

    it("can't buy again", async function() {
      await auct.connect(seller).createAuction(ethers.utils.parseEther("0.001"), 3, "notebook", 60)
      this.timeout(5000) //5 seconds (indicates how long this test can work)
      await delay(1000)
      await auct.connect(buyer).buy(0, {value: ethers.utils.parseEther("0.001")})
      await expect(auct.connect(buyer).buy(0, {value: ethers.utils.parseEther("0.001")}))
        .to.be.revertedWith("stopped!");
    })
  }) 
})