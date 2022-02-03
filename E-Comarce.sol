// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ecomarce{
    struct ProductStructure{
        string name;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool deliverd;
    }
    uint count =1;
    ProductStructure[] public products;

    bool deleteContract=false; 
    modifier ifNotDeleted(){
        require(!deleteContract,"contract is deleted sorry!!!");
        _;
    }
    address payable public manager;
    constructor() {
        manager=payable(msg.sender);
    }



    event registered(string name,uint productId,uint price,address seller);
    event bought(uint productId,uint price,address buyer);
    event deliverd(uint productId);


    function resgister(string memory _name,string memory _desc,uint _price) public ifNotDeleted{
        ProductStructure memory product;
        product.name=_name;
        product.desc=_desc;
        product.price=_price*10**18;
        product.seller=payable(msg.sender);
        product.productId=count;
        products.push(product);
        count++;
        emit registered(product.name,product.productId,product.price,product.seller);
    }
    function buy(uint _productId) payable public ifNotDeleted{
        require(products[_productId-1].price==msg.value,"please send the correct amount of value");
        require(products[_productId-1].seller!=msg.sender,"seller can't buy the product");
        products[_productId-1].buyer=msg.sender;
        emit bought(products[_productId-1].productId,msg.value,msg.sender);
    }
    function deliver(uint _productId) payable public ifNotDeleted{
        require(products[_productId-1].buyer==msg.sender,"only buyer can confirm!!!");
        products[_productId-1].deliverd=true;
        products[_productId-1].seller.transfer(products[_productId-1].price);
        emit deliverd(_productId);
    }
    function deleteEverything() public ifNotDeleted{
        require(manager==msg.sender,"this function is only can be used by manager!!");
        manager.transfer(address(this).balance);
        deleteContract=true;
    }
    fallback() external payable{
        payable(msg.sender).transfer(msg.value);
    }
    receive() external payable{
        payable(msg.sender).transfer(msg.value);
    }
}