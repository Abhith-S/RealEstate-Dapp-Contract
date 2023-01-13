//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//use an interface to get the functions that we need from the erc721 contract
interface IERC721{
     
    //function to transfer NFT
    function transferFrom(address _from,address _to,uint _id )external;
}


contract Escrow{

    //variables to store nftID , address, seller, buyer, lender, inspector purchasePrice, escrowAmount
    address public nftAddress;
    uint public nftID;
    uint public purchasePrice;
    uint public escrowAmount;
    address payable public  seller;
    address payable public  buyer;
    address public inspector;
    address public lender;

    //create a constructor to initialize the nftID, nftAddress,seller, buyer, lender, inspector purchasePrice, escrowAmount we need it to access the NFT
    constructor(address _nftAddress, 
        uint _nftID,
        uint _purchasePrice,
        uint _escrowAmount,
        address payable _seller, 
        address payable _buyer,
        address _inspector,
        address _lender
    )
        {
        nftAddress = _nftAddress;
        nftID = _nftID;
        purchasePrice = _purchasePrice;
        escrowAmount = _escrowAmount;
        seller = _seller;
        buyer = _buyer;
        inspector = _inspector;
        lender = _lender;
    }

    //fucntion to deposit earnest
    function depositEarnest()public payable{
     require(msg.value >= escrowAmount,"Amount is less than escrow amount");
    }

    //get balance
    function getBalance()public view returns(uint){
        return address(this).balance;
    }

    //function to transfer NFT from seller to buyer
    function finalizeSale()public {

        //use the function from interface for transfer
        //we need to pass the address of the contract
        IERC721(nftAddress).transferFrom(seller, buyer, nftID);

    }
}
