# REGRAS DE NEGÓCIO E PROGRAMAÇÃO DE SGBD

## Introdução

Nesse capítulo, iremos trabalhar com recurso utilizados tanto pelos administradores quanto pelos programadores.  
Ao longo desse material, serão abordados os seguintes assuntos:  

* Implementação de Regras de Negócio no momento de criação das tabelas (*Check*);  
* Sequências (Sequences);  
* Visões (View);  
* Procedimentos Armazenados (Stored Procedures);  
* Gatilhos (Triggers).

## $\color{#FF0000}{Implementando Regras de Negócio}$  
As regras de negócio (regras aos quais os valores dos dados devem obedecer) podem serem implementadas no momento da criação das tabelas por meio das restrições check e unique.  

[some text](color: red)

### Restrição Check  
A restrição CHECK no SQL é usada para impor uma condição específica em uma coluna de uma tabela. Ela garante que os valores inseridos ou atualizados naquela coluna atendam a determinados critérios, ajudando a manter a integridade dos dados.  

📌 **Exemplo**: Condição check que garante idades positivas:    
```sql
CREATE TABLE Clientes (
    ID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Idade INT CHECK (Idade > 0) -- Garante que apenas maiores de 18 anos sejam cadastrados
);
```

📌 **Exemplo**: Impedindo que um salário seja **inferior** ou **superior** a um teto:  
```sql
CREATE TABLE Funcionarios (
    ID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Salario DECIMAL(10,2) CHECK (Salario BETWEEN 1000 AND 50000) -- Restringe o salário a um intervalo
);
```
