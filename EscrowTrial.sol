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
    bool public inspectionPassed = false;
    mapping(address => bool) public approveSale;

    //recieve to make contract recieve funds
    receive() external payable{}

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

    //modifier for operations only buyer can perform
    modifier onlyBuyer(){
        require(msg.sender == buyer, "Only buyer can do this");
        _;
    }

    //modifier for operations only buyer can perform
    modifier onlyInspector(){
        require(msg.sender == inspector, "Only inspector can do this");
        _;
    }

    //function to change inspectionPassed
    function setInspectionPassed(bool _inspectionPassed)public{
        inspectionPassed = _inspectionPassed;
    }

    //fucntion to deposit earnest
    function depositEarnest()public payable onlyBuyer{
        require(msg.value >= escrowAmount,"amount is less than escrow amount");
    }

    //get balance
    function getBalance()public view returns(uint){
        return address(this).balance;
    }

    //function to approve sale by actors
    function approvePropertySale()public {
        approveSale[msg.sender] = true;
    }

    //function to transfer NFT from seller to buyer
    function finalizeSale()public {

        //must pass inspection
        require(inspectionPassed,"inspection not passed");

        //must be appproved by seller,lender,buyer
        require(approveSale[buyer],"Buyer must approve sale");
        require(approveSale[seller],"Seller must approve sale");
        require(approveSale[lender],"Lender must approve sale");

        //there must be enough funds to do sale
        require(address(this).balance >= purchasePrice, "Not enough funds in the contract");
        
        //transfer funds to seller
        (bool success, ) = payable(seller).call{value : address(this).balance}("");
        require(success,"Funds not transferred to seller");
        
        //use the function from interface for transfer
        //we need to pass the address of the contract
        IERC721(nftAddress).transferFrom(seller, buyer, nftID);

    }
}
