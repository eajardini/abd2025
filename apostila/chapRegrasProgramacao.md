# REGRAS DE NEGÓCIO E PROGRAMAÇÃO DE SGBD

## Introdução

Nesse capítulo, iremos trabalhar com recurso utilizados tanto pelos administradores quanto pelos programadores.  
Ao longo desse material, serão abordados os seguintes assuntos:  

* Implementação de Regras de Negócio no momento de criação das tabelas (*Check*);  
* Sequências (Sequences);  
* Visões (View);  
* Procedimentos Armazenados (Stored Procedures);  
* Gatilhos (Triggers).

Antes de começarmos,** vamos criar um novo database** para os testes desse capítulo:
```sql
CREATE DATABASE chapregras;
```

## Implementando Regras de Negócio
As regras de negócio (regras aos quais os valores dos dados devem obedecer) podem serem implementadas no momento da criação das tabelas por meio das restrições check e unique.  

### Restrição Check  
A restrição CHECK no SQL é usada para impor uma condição específica em uma coluna de uma tabela. Ela garante que os valores inseridos ou atualizados naquela coluna atendam a determinados critérios, ajudando a manter a integridade dos dados.
A restrição CHECK é útil para evitar dados inválidos no banco de dados, reduzindo a necessidade de verificações adicionais na aplicação. 

📌 **Exemplo**: Condição check que garante idades positivas:    
```sql
CREATE TABLE Clientes (
    ID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Idade INT,
    CONSTRAINT ck_Idade CHECK (Idade > 0) -- Garante que apenas maiores de 18 anos sejam cadastrados
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

### Restrição Unique
Para garantir a unicidade de valores de campos que não são chave primária, no caso **chaves candidatas**, usamos a restrição unique.  
A restrição UNIQUE no SQL é usada para garantir que os valores de uma ou mais colunas em uma tabela sejam únicos, ou seja, não se repitam entre as linhas. Isso **ajuda a manter a integridade dos dados**, **evitando duplicações** indesejadas.  

📌 **Exemplo**: Na implementação da tabela Aluno, a chave primária deve ser RA e o campo CPF deve ser único:  
```sql
create table aluno(
    ra integer,
    nome varchar(40),
    cpf varchar(12),
    constraint pk_aluno primary key (ra),
    constraint un_cpf unique (cpf)
);
```

📌 **Exemplo**: Podemos garantir que a combinação de duas ou mais colunas seja única:  
```sql
CREATE TABLE Pedidos (
    ID INT PRIMARY KEY,
    ClienteID INT,
    ProdutoID INT,
    UNIQUE (ClienteID, ProdutoID)  -- Garante que o mesmo cliente não peça o mesmo produto duas vezes
);
```

### Exercícios
1. Crie o modelo físico das relações **correntista** = {cpf, nome, data_nasc, cidade, uf} e conta_corrente {num_conta, cpf_correntista (fk), saldo}. Garanta as seguintes regras de negócio:  
    (a) Uma conta corrente só pode ser aberta com saldo mínimo **inicial de R$ 500,00**.  
    (b) Os correntistas devem ser maiores que 18 anos. Para isso, você deve comparar a data de nascimento com a data atual. No Postgres, para saber a idade atual, use a função
   ```sql
   ((CURRENT_DATE - data_nasc)/365>=18) ou use a função (AGE(CURRENT_DATE, data_nasc) >= '18 Y’)).
   ```

## _Sequences_ (Sequências)
Uma **_Sequence_** (sequência) é um objeto de banco de dados criado pelo usuário que pode ser compartilhado por vários usuários para gerar números inteiros exclusivos de acordo com regras especificadas no momento que a sequência é criada.  

A **sequence** é gerada e incrementada por uma rotina interna do SGBD. Normalmente, as sequências são usadas para criar **um valor de chave primária** que deve ser exclusivo para cada linha de uma tabela. 

Vale a pena salientar que os números de sequências **são armazenados e gerados de modo independente das tabelas**. Portanto, o mesmo objeto sequência pode ser usado por várias tabelas e inclusive por vários usuários de banco de dados caso necessário. **Mas isso não é recomendado**.

Geralmente, convém atribuir à sequência um nome de acordo com o uso a que se destina; no entanto, ela poderá ser utilizada em qualquer lugar,  independente do nome.  

Sequências são **frequentemente** utilizados para **produzir valores únicos** em colunas definidas como **chaves primárias**.  

Neste caso, você pode enxergar essas sequências como campos do tipo _auto-incremento_.  

Cada sequência deve ter um nome que a identifique. O padrão para o nome pode ser _**sid_nome_da_tabela**_.  

### Como criar uma SEQUENCE?
Para criar uma SEQUENCE, usamos o comando CREATE SEQUENCE:  
```sql
CREATE SEQUENCE sid_minha_sequence
START WITH 1  -- Primeiro valor gerado (opcional)
INCREMENT BY 1  -- Incremento entre os valores (opcional)
MINVALUE 1  -- Valor mínimo permitido (opcional)
MAXVALUE 1000  -- Valor máximo permitido (opcional)
CYCLE;  -- Faz a sequência reiniciar após atingir o MAXVALUE (opcional)
```

**Onde**:  
**START WITH 1 ** → Começa a sequência a partir de 1.
**INCREMENT BY 1** → Incrementa o valor em 1 a cada chamada.
**MINVALUE 1** → O menor valor permitido é 1.
**MAXVALUE 1000** → O maior valor permitido é 1000 (opcional).
**CYCLE** → Quando atinge o MAXVALUE, ele reinicia para o MINVALUE.  

### Usando as SEQUENCES (NEXTVAL)

📌 **Exemplo**: **Criando e usando** uma sequencia para tabela Usuários:
```sql

create sequence sid_usuarios;

SELECT NEXTVAL('sid_usuarios');

CREATE TABLE Usuarios (
    ID INT PRIMARY KEY,
    Nome VARCHAR(100)
);

insert into usuarios
values (nextval('minha_sequence'), 'joao');
```

### Usando o SERIAL ou BIGSERIAL  
O tipo de dado SERIAL no PostgreSQL é usado para criar chaves primárias **auto-incrementáveis de forma automática**. Ele internamente cria uma SEQUENCE, que gera os valores sequenciais para a coluna.  


📌 **Exemplo**: **Criando e usando** uma sequencia para tabela Usuários:
```sql

CREATE TABLE diarios (
    diarioID SERIAL/BIGSERIAL PRIMARY KEY -- serial ou bigserial vai depender da quantidade de registros,
    descricao VARCHAR(100)
);

INSERT INTO diarios
values (default, 'Banco de Dados');
```

#### Como funciona o SERIAL internamente?
Quando usamos SERIAL, o PostgreSQL automaticamente faz três coisas:  

1. Cria uma SEQUENCE associada
2. Define a coluna como _DEFAULT nextval('sequence_name')_
3. Vincula a sequence à tabela

📌 **Exemplo**: Exemplo do que o **PostgreSQL cria internamente** ao usar SERIAL:
```sql
CREATE SEQUENCE usuarios_id_seq START WITH 1 INCREMENT BY 1;
ALTER TABLE Usuarios ALTER COLUMN ID SET DEFAULT nextval('usuarios_id_seq');
```

### CURRVAL
