import { expect } from "chai";
import { ethers } from "hardhat";

describe("Minter", async () => {
  const deployContract = async (): Promise<any> => {
    // deploy the contract
    const Minter = await ethers.getContractFactory("Minter");
    const minter = await Minter.deploy();
    // console.log("Contract Address:", minter.address);
    // create a new accounts
    const [account1, account2] = await ethers.getSigners();
    return { minter, account1, account2 };
  }

  it("Should mint a new token", async () => {
    const { minter, account1 } = await deployContract();
    // safeMint a token for account1
    const safeMint = await minter.safeMint(account1.address, 'name');
    // console.log(safeMint);
    // expect tokenURI for index 0 to have email as : test@email.com
    const tokenURIString: string = await minter.tokenURI(0);
    // remove data:application/json;base64, prefix from tokenURIString
    const tokenURIBase64 = tokenURIString.substring(tokenURIString.indexOf(',') + 1);
    // decode tokenURIBase64 from base64 to JSON object
    const tokenURI = JSON.parse(atob(tokenURIBase64));
    expect(tokenURI.name).to.equal('name');
    console.log(tokenURI.image);
  });

  it("Should be able to transfer and change name", async () => {
    const { minter, account1, account2 } = await deployContract();
    // safeMint a token for account1
    const safeMint = await minter.safeMint(account1.address, 'name');
    // transfer token to account2
    const transfer = await minter.transferFrom(account1.address, account2.address, 0);
    // changeName for account2
    const changeName = await minter.changeName(0, 'new name');
    const tokenURIString: string = await minter.tokenURI(0);
    // remove data:application/json;base64, prefix from tokenURIString
    const tokenURIBase64 = tokenURIString.substring(tokenURIString.indexOf(',') + 1);
    // decode tokenURIBase64 from base64 to JSON object
    const tokenURI = JSON.parse(atob(tokenURIBase64));
    expect(tokenURI.name).to.equal('new name');
    console.log(tokenURI.image);
  });

  it("Should allow one address to mint only one token", async () => {
    const { minter, account1 } = await deployContract();
    // safeMint a token for account1
    const safeMint = await minter.safeMint(account1.address, 'name');
    // safeMint a token for account1
    await expect(minter.safeMint(account1.address, 'name2')).to.be.revertedWith(
      "Only one token per address is allowed"
    );
  });
});