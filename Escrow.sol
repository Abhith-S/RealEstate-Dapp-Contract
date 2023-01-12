//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//use an interface to get the functions that we need from the erc721 contract
interface IERC721{
     
    //function to transfer NFT
    function transferFrom(address _from,address _to,uint _id )external;
}


contract Escrow{

    //variables to store nftID and address
    address public nftAddress;
    uint public nftID;

    //create a constructor to initialize the nftID and nftAddress, we need it to access the NFT
    constructor(address _nftAddress, uint _nftID){
        nftAddress = _nftAddress;
        nftID = _nftID;
    }
    //function to transfer NFT from seller to buyer
    function finalizeSale()public {

        //use the function from interface for transfer
        //we need to pass the address of the contract
        //we currently don't have the seller and buyer so we just use placeholders there
        IERC721(nftAddress).transferFrom("seller", "buyer", nftID);

    }
}
