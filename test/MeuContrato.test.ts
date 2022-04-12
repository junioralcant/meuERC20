import { expect } from "chai";
import { ethers } from "hardhat";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import {MeuContrato, MeuContrato__factory} from "../typechain";

describe("MeuContrato", function () {
    // Recupera Address 
    let owner: SignerWithAddress;
    let address1: SignerWithAddress;
    let address2: SignerWithAddress;
    let contract: MeuContrato;

    before(async function () {
        [owner, address1, address2] = await ethers.getSigners();
    });

    beforeEach(async function () {
        let contractFactory = <MeuContrato__factory>await ethers.getContractFactory("MeuContrato");
        contract = await contractFactory.deploy();
        contract = await contract.deployed();
    });
    // Faz o teste e verifica se nome o simbolo e o tatal de tokens é igual ao oq colocamos no codigo do contrato
    it("Verifica o nome, simbolo e tatal suplay", async function () {
        // verifica o nome do contrato
        expect((await contract.name())).to.equal("MeuContrato");
        // verifica o simbolo do contrato
        expect((await contract.symbol())).to.equal("MCT");
        // verifica a quantidade de tokens
        expect( ethers.utils.formatEther(await contract.balanceOf(owner.address))).to.equal("1000000000.0");
    });

    it("Faz transferênca de tokens", async function () {
        // transfere tokens para o endereço1
        // essa função transfer é do contrato ERC20PresetFixedSupply que herda do ERC20
        await contract.transfer(address1.address, 2);
       
        // Conecta o Address1 do contrato
        contract = contract.connect(address1);

        // transfere tokens para o endereço do contrato
        await contract.transfer(contract.address, 2);
        
        // Conecta o dono do contrato
        contract = contract.connect(owner);

        // Retira tokens do endereço do contrato
        await contract.withdrawERC20(contract.address, owner.address, 2);

        expect(ethers.utils.formatEther(await contract.balanceOf(contract.address))).to.equal("0.0");

        // Chama a função que transfere todo o o ether
        await contract.withdraw();
    });
});