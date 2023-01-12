//tests for Escrow contract

//get expect from "chai" assertion library
const {expect}  = require("chai");

//get ethers from hardhat
const {ethers} = require("hardhat");


//describe block inside we write tests , describe("contract name", () => {})
describe("RealEstate", ()=>{

    //get the variables outside so we can reuse it
    let realEstate,escrow,seller,deployer;

    //nftID wills start with 1, so first minted NFT will have ID 
    let nftID = 1;

    //Do this before executing each test ie 'let' block
    beforeEach(async() => {
    
    //get the accounts, these are signers and not account addresses
    account = await ethers.getSigners();
    deployer = account[0];
    seller = deployer;

    //Load contracts
    RealEstate = await ethers.getContractFactory("RealEstate");
    Escrow = await ethers.getContractFactory("Escrow");

    //deploy contracts
    realEstate = await RealEstate.deploy();

    //while deploying we need to pass the nftAddress and nftID as constructor parameters
    //realEstate contracts address is the nft address
    escrow = await Escrow.deploy( realEstate.address, nftID);

    })

    describe("deployment", async()=>{

        //chech if seller has an NFT, ie is seller the owner of NFT created in RealEstate contract
        it("checks if seller has the NFT", async()=>{

            //the ownerOf() is from ERC721 contract
            expect(realEstate.ownerOf(nftID)).to.equal(seller.address);
        })
    })
    

})
