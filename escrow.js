//tests for Escrow contract

//get expect from "chai" assertion library
const {expect}  = require("chai");

//get ethers from hardhat
const {ethers} = require("hardhat");

//1 eth is 10^18 wei so instead of always specifying that big amount we can create a function with tools using hardhat
//here tokens will be equal to  1 ether value
const tokens = (n) => {
    return ethers.utils.parseUints(n.toString(),"ether")
}

const ether = tokens

//describe block inside we write tests , describe("contract name", () => {})
describe("RealEstate", ()=>{

    //get the variables outside so we can reuse it
    let realEstate,escrow,seller,deployer,buyer,lender,inspector;
    let purchasePrice = ether(100);
    let escrowAmount = ether(20);

    //nftID wills start with 1, so first minted NFT will have ID 
    let nftID = 1;

    //Do this before executing each test ie 'let' block
    beforeEach(async() => {
    
    //get the accounts, these are signers and not account addresses
    account = await ethers.getSigners();
    deployer = account[0];
    seller = deployer;
    buyer = account[1];
    inspector = account[2];
    lender = account[3];

    //Load contracts
    RealEstate = await ethers.getContractFactory("RealEstate");
    Escrow = await ethers.getContractFactory("Escrow");

    //deploy contracts
    realEstate = await RealEstate.deploy();

    //while deploying we need to pass the nftAddress, nftID, seller, buyer, lender, inspector purchasePrice, escrowAmount as constructor parameters
    //realEstate contracts address is the nft address
    escrow = await Escrow.deploy( 
    realEstate.address, 
    nftID,
    purchasePrice,
    escrowAmount,
    seller.address, 
    buyer.address,
    inspector.address,
    lender.address);

    //before a transfer to buyer can happen the seller needs to approve it
    //the '.connect()' helps to specify whitch account are we using
    transaction = await realEstate.connect(seller).approve(escrow.address,nftID);
    await transaction.wait();

    })

    describe("deployment", async()=>{

        //chech if seller has an NFT, ie is seller the owner of NFT created in RealEstate contract
        it("checks if seller has the NFT", async()=>{

            //the ownerOf() is from ERC721 contract
            expect(await realEstate.ownerOf(nftID)).to.equal(seller.address);
        })
    })
    
    describe("Selling real estate", async() =>{

        it("executes a succesfull transactio", async()=>{

            //seller should be nft owner before transaction
            expect(await realEstate.ownerOf(nftID)).to.equal(seller.address);

            //buyer deposits earnest amount, passed in as value to payable function
            transaction = await escrow.connect(buyer).depositEarnest({value: escrowAmount});
            await transaction.wait();

            //check escrow balance
            let balance = await escrow.getBalance();
            //convert the wei to ether and display
            console.log("escrow balance", ethers.utils.formatEther(balance));

            //transfer nft & finalize sale
            transaction = await escrow.connect(buyer).finalizeSale();
            await transaction.wait();

            //buyer should be nft owner after transfer
            expect(await realEstate.ownerOf(nftID)).to.equal(buyer.address);
        })
    })

})
