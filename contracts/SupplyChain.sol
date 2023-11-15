// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract SupplyChain {
  // APP LOGIC
  // Supplier will be able to add product (Add product)
  // Distributor will be able to view available products (Displays all products of the supplier)
  // Distributor will also be able to view a description of a single product (Get a single product by the ID)   
  // Distributor can deposit money to account (Add balance to account)
  // Distribtor can request for a product (Purchase a product)

  address payable public supplier;
  address owner;
  address public distributor;
  uint public nextProductId;

  struct Product {
    uint256 id; 
    string name;
    uint256 stock;
    uint256 price;
  }

  mapping(address => Product[]) private supplierProducts;
  mapping(address => uint256) private distributorBalance;

  event AddProduct(address indexed owner, string indexed productName);
  event PurchaseProduct(address indexed owner, address indexed distributor, uint amount, string indexed productName, uint productStock);
  event Withdraw(uint256 balance);

  constructor(
    address _distributor, 
    address payable _supplier
  ) {
    supplier = _supplier;
    distributor = _distributor;
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner, "This is not a supplier");
    _;
  }

  modifier onlyDistributor {
    require(msg.sender != supplier, "Only the Distributor can invoke this function");
    _;
  }

  function setSupplier(address payable _supplier) public {
    supplier = _supplier;
  }

  function depositAmount(address _distributor, uint256 amount) public {
    distributorBalance[_distributor] = amount;
  }

  function getDistributorBalance(address _distributor) public view returns(uint) {
    return distributorBalance[_distributor];
  }

  function myProductCount() public view returns(uint256) {
    return supplierProducts[msg.sender].length;
  }

  function getProduct(uint id) public view returns(Product memory product) {
    require(supplierProducts[msg.sender][id].id == id, "Product does not exist");
    return supplierProducts[msg.sender][id];
  }

  function addProduct(
    uint256 id,
    string memory name,
    uint256 stock,
    uint256 price
  ) public {
    require(nextProductId == id);

    Product memory product = Product({
        id: id,
        name: name,
        stock: stock,
        price: price
    });

    supplierProducts[msg.sender].push(product);
    nextProductId++;
    emit AddProduct(msg.sender, name);
  }

  function getSupplierProducts() public view returns(
    uint256[] memory ids,
    string[] memory names,
    uint256[] memory stocks,
    uint256[] memory prices
  ) {
    uint count = myProductCount();
    ids = new uint256[](count);
    names = new string[](count);
    stocks = new uint256[](count);
    prices = new uint256[](count);

    for(uint256 i = 0; i < count; i++) {
      Product storage products = supplierProducts[msg.sender][i];
      ids[i] = products.id; 
      names[i] = products.name;
      stocks[i] = products.stock;
      prices[i] = products.price;
    }

    return (
      ids,
      names,
      stocks,
      prices
    );
  } 

  function purchaseProduct(
    address _distributor,
    uint productId,
    uint productStockToPurchase
  ) public payable {
    require(getProduct(productId).stock >= productStockToPurchase);
    require(getDistributorBalance(_distributor) >= msg.value);

    distributorBalance[_distributor] -= msg.value;
    supplierProducts[msg.sender][productId].stock -= productStockToPurchase;
    string memory productName = supplierProducts[msg.sender][productId].name;

    emit PurchaseProduct(msg.sender, _distributor, msg.value, productName, productStockToPurchase);
  }

  function withdraw() public {
    uint256 balance = address(this).balance;
    supplier.transfer(balance);
    emit Withdraw(balance);
  }

  // function supplierBalance() public view returns(uint) {
  //   return address(supplier).balance;
  // }
}