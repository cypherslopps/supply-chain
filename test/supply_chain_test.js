const SupplyChainTest = artifacts.require("SupplyChainTest");

contract("supply_chain_test", (accounts) => {
  let supplyChain;
  const supplier = accounts[0];
  const distributor = accounts[1];

  beforeEach(async () => {
    supplyChain = await SupplyChainTest.new(
      supplier,
      distributor
    );
  });
});
