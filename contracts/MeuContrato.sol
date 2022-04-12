
// SPDX-License-Identifier: MIT

// Versão do solidity
pragma solidity ^0.8.0;
import "hardhat/console.sol";
// Importa o contrato ERC20PresetFixedSupply do openzeppelin
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
// Importa o contrato Ownable do openzeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// Cria o contrato e herda os contratos importados
contract MeuContrato is ERC20PresetFixedSupply, Ownable {
    // habilita address para usar funcoes do contrato Address
    using Address for address;
    // Cria o construtor e define nome, simbolo, total supply e dono dos tokens
    // 1000000000 * 10**decimals() é o calculo para define a quantidade de 1 bilhão de tokens
    constructor() ERC20PresetFixedSupply("MeuContrato", "MCT", 1000000000 * 10**decimals(), _msgSender()) {}

    // Função para retirar qualquer ERC20 do nosso contrato
    // mas apenas o Owner (dono do contrato pode usar essa função)
    // por conta do modificador onlyOwner()
    function withdrawERC20(
        address tokenAddress,
        address to,
        uint256 amount
    ) external virtual onlyOwner() {
        // Verifica se é uma ERC20
        require(tokenAddress.isContract(), "ERC20 token address must be a contract");

        IERC20 tokenContract = IERC20(tokenAddress);

        // Verifica se a quantidade de tokens eh igual ou maior que a quantidade a ser transferida
        require(
            tokenContract.balanceOf(address(this)) >= amount,
            "You are trying to withdraw more funds than available"
        );

        // Verifica se a transferência foi feita com sucesso
        require(tokenContract.transfer(to, amount), "Fail on transfer");
    }
    
    // Função que transfere ether do contrato para o Owner, o dono do contrato
    // mas apenas o Owner (dono do contrato pode usar essa função)
    // por conta do modificador onlyOwner()
    function withdraw() onlyOwner public {
        // Pega toda a quantidade ether disponível
        uint256 balance = address(this).balance;
        console.log(balance);
        // Transfere a quantidade recuperada para o owner
        Address.sendValue(payable(msg.sender), balance);
    }


    /* 
1 - Criar contrato ERC20 - Mais testes
        Passos:
            CRIANDO PROJETO COM HARDHAT
            1 Vamos criar um projeto usando o Hardhat, abra o terminal e use o comando 
                mkdir meu-erc20 para criar uma pastar e cd meu-erc20 para entrar nela.
            2 Execute o camando npx hardhat para criar o projeto. Selecione Create an advanced sample project that uses TypeScript
            (agora é esperar a instalação). Com a instalação finalizada, foi criado um projeto com tudo oque precisamos para trabalhar 
            no nosso contrato.
            3 Na pasta contracts ira ficar os nossos contratos Solidity e na pasta test os nossos testes (inclusive ele já cria um contrato
            simples e os testes).
            4 No arquivo package.json, em "scripts": {}, iremos criar dois comandos, "compile": "hardhat compile" para compilar os contratos e test": "hardhat test"
            para rodar os nossos testes.
                "scripts": {
                    "compile": "hardhat compile",
                    "test": "hardhat test"
                }
            5 Agora com o terminal a berto na pasta do projeto, podemos usar o camando npm run compile para compilar e o npm run test para rodar 
            os testes.

            CRIANDO CONTRATO ERC20
            1 Iremos usar a bliblioteca do OpenZeppelin para criar nosso contrato, no terminal use o comando npm install @openzeppelin/contracts para instalar
            a bliblioteca. Agora está tudo pronto para colocarmos a mão na massa. 
            2 Na pasta contracts crie um novo contrato, iremos criar com o nome MeuContrato.sol.
                // SPDX-License-Identifier: MIT

                // Versão do solidity
                pragma solidity ^0.8.0;

                // Importa o contrato ERC20PresetFixedSupply do openzeppelin
                import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

                contract MeuContrato is ERC20PresetFixedSupply {
                    // Cria o construtor e define nome, símbolo, total supply e dono dos tokens
                    // 1000000000 * 10**decimals() é o calculo para define a quantidade de 1 bilhão de tokens
                    constructor() ERC20PresetFixedSupply("MeuContrato", "MCT", 1000000000 * 10**decimals(), _msgSender()) {}
                } 
            3 Na pasta tests crie um arquivo com nome MeuContrato.test.ts. Mas antes disso rode o comando npm run compile para compilar o codigo que acabamos de fazer.
                import { expect } from "chai";
                import { ethers } from "hardhat";
                import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
                import {MeuContrato, MeuContrato__factory} from "../typechain";

                describe("MeuContrato", function () {
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
                    
                    // Faz o teste e verifica se nome o símbolo e o tatal de tokens é igual ao oq colocamos no codigo do contrato
                    it("Verifica o nome, símbolo e tatal suplay", async function () {
                        // verifica o nome do contrato
                        expect((await contract.name())).to.equal("MeuContrato");
                        // verifica o símbolo do contrato
                        expect((await contract.symbol())).to.equal("MCT");
                        // verifica a quantidade de tokens
                        expect( ethers.utils.formatEther(await contract.balanceOf(owner.address))).to.equal("1000000000.0");
                    });
                });

                4 Nesse momento já temos o nosso primeiro contrato criado, agora vamos dar uma encrementada nele e adicinar a função para retirar qualquer token ERC20
                que tenha sido transferido para endereço do nosso contrato.
                    // Função para retirar qualquer ERC20 do nosso contrato
                    // mas apenas o Owner (dono do contrato pode usar essa função)
                    // por conta do modificador onlyOwner()
                    function withdrawERC20(
                        address tokenAddress,
                        address to,
                        uint256 amount
                    ) external virtual onlyOwner() {
                        // Verifica se é um ERC20
                        require(tokenAddress.isContract(), "ERC20 token address must be a contract");

                        IERC20 tokenContract = IERC20(tokenAddress);

                        // Verifica se a quantidade de tokens eh igual ou maior que a quantidade a ser transferida
                        require(
                            tokenContract.balanceOf(address(this)) >= amount,
                            "You are trying to withdraw more funds than available"
                        );

                        // Verifica se a transferência foi feita com sucesso
                        require(tokenContract.transfer(to, amount), "Fail on transfer");
                    }

                5 Agora vamos fazer nossos testes. Novamente no arquivo MeuContrato.test.ts adicione o seguinte codigo abaixo do teste anterior.
                    it("Faz transferênca de tokens", async function () {
                        // transfere tokens para o endereço1
                        // essa função transfer é do contrato ERC20PresetFixedSupply que herda do ERC20
                        await contract.transfer(address1.address, 2);
                    
                        // Conecta o Address1 ao contrato
                        contract = contract.connect(address1);

                        // transfere tokens para o endereço do contrato
                        await contract.transfer(contract.address, 2);
                        
                        // Conecta o dono do contrato
                        contract = contract.connect(owner);

                        // Retira tokens do endereço do contrato
                        await contract.withdrawERC20(contract.address, owner.address, 2);

                        expect(ethers.utils.formatEther(await contract.balanceOf(contract.address))).to.equal("0.0");
                    });

                6 Vamos adicinar uma função chamada withdraw que transfere todo Ether que tem no endereço do nosso contrato para o dono do contrato.
                    // Função que transfere ether do contrato para o Owner, o dono do contrato
                    // mas apenas o Owner (dono do contrato pode usar essa função)
                    // por conta do modificador onlyOwner()
                    function withdraw() onlyOwner public {
                        // Pega toda a quantidade ether disponível
                        uint256 balance = address(this).balance;
                        console.log(balance);
                        // Transfere a quantidade recuperada para o owner
                        Address.sendValue(payable(msg.sender), balance);
                    }         

                7 Na última linha do teste anterior vamos adicionar o seguinte.
                    await contract.withdraw();
                
                8 Por fim, finalizamos o nosso contrato. Agora é só usar os comandos npm run compile para compilar os contratos e npm run test para rodar os testes. 
                Fique de olho pois esse é só o primeiro compitolo da nossa serie
*/          
}    

