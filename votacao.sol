// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

//estrutura de dados para guardar conjunto de propriedades struct, 
    //apos coloca as propriedades (string) e uint para contabilizar as votações
    //uint maxdate para dar o time stamp da votação
    //estruturas das votações
struct Voting {
    string option1;
    uint votes1;
    string option2;
    uint votes2;
    uint maxDate;
}

//Verificar se essa que ja mandou o voto ja nao votou anteriormente, quem votou em quem, auditoria
    //uint choice guarda a escolha 1 ou 2
    //uint date guarda a data para auditoria evitando fraude
struct Vote {
    uint choice;
    uint date;

}

//nome do contrato, endereço da carteira da pessoa que vai logar, 
    //ou seja primeiro o tipo de dado do contrato (adress) owner a variavel pra guardar o endereço.
contract wEBBB3 {
    address owner;
    uint public currentVoting = 0;
    //uint public votação atual iniciando em 0
    Voting[] public votings;
    //armazenamento das votações variavel array voting []

    mapping(uint => mapping(address => Vote)) public votes;
    //mapeamento de chave valor

    //constructor função recebe as informações de quem fez o deploy
        //tode envio pra blockchai gera recebimento msg
        //sender traz o endereço de quem enviou a msg  
    constructor(){
        owner = msg.sender;
    }

    //função para pegar os dados da votação atual, publica, de leitura (view) não cobra taxa, pois é uma call
        //para retornar o dado returns(tipo de dado) memory pois é grande (complexo)
    function getCurrentVoting() public view returns (Voting memory) {
        return votings[currentVoting];
    }

    //função de adicionar nova votação, nome da função, parenteses pra delimitar, opçoes e tempo para votar
    //string tem que colocar memory para alocar na memoria por ser grande
    function addVoting(string memory option1, string memory option2, uint timeToVote) public{
        require(msg.sender == owner, "Invalid sender");
        // para segurançã função require, se quem ta chamando for = owner ok, se não for envia mensagem de erro.

        if(currentVoting !=0) currentVoting++;
        //para incrementar segunda votação se for diferente de zero incrementa em um com ++

        Voting memory newVoting;
        newVoting.option1 = option1; // cadastro de nova votação option1 recebe option1 que veio do parâmetro
        newVoting.option2 = option2;
        newVoting.maxDate = timeToVote + block.timestamp; // data limite block variavel global para informações do bloco
        votings.push(newVoting); //array voting chamar a função puch para adicionar novo elemento no array, 
        //assim a votação é registrada quando a função assVoting for chamada.
    }

    //função para adicionar um voto ela espera a escolha da pessoa (uint choice) publica
        //validação tem que ser valida require tem que ser =  1 ou = 2 caso contrário mensagem
        //ver se tem votação em aberto se não tem não tem como adicionar votação só pode em adicionar em votações abertas
    function addVote(uint choice)public {
        require(choice == 1 || choice == 2, "Invalid choice");
        require(getCurrentVoting().maxDate > block.timestamp, "No open voting");
        require(votes[currentVoting][msg.sender].date == 0, "you already voted on this voting");
        
        votes[currentVoting][msg.sender].choice = choice;    
        votes[currentVoting][msg.sender].date = block.timestamp;

        if(choice ==1)
            votings[currentVoting].votes1++;
        else
         votings[currentVoting].votes2++;    

        }
}
