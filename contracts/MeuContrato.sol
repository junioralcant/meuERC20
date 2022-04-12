
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
}    

