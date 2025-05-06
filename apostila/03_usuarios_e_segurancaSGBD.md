# Segurança do SGBD PostgreSQL: Usuários e Direitos de Acesso

## INTRODUÇÃO  

Para os exemplos desse capítulo, deve ser ter o script que criam as tabelas do curso.
Uma das características que um SGBD deve possuir é o controle de acesso aos dados feito pelos usuário. O SGBD não pode deixar que usuários sem autorização acessem as informações de responsabilidade dele.  
Para garantir esta restrição, o PostgreSQL só permite o acesso aos dados, os usuários previamente cadastrados.   

O PostgreSQL possui um usuário que é criado no momento da instalação:  
 * *postgres*: usuário com direito de administrador. É o que possui maior poder no SGBD.

Para saber quais usuários o Postgres possui digite:
```sql
select usename,passwd from pg_shadow;
```

Note que as senhas dos usuários aparecem criptografas pelo padrão BCrypt. Além disso, é na tabela pg_shadow o SGBD Postgres armazena os usuários cadastrados nele.  
Se precisar saber quais usuários tem direito de DBA, faça a consulta:
```sql
select usename,usesuper from pg_shadow;
```

**Dica**: para criptografar um campo senha do tipo *varchar*, use a função **md5()**. Veja como fazemos para inserir e recuperar uma senha criptografada com MD5:  

- Inserindo:
  
```sql
  insert into vendedor values (320, 'Amarildo', 6700, 'A', md5('123456'));
```

- Recuperando:
  
```sql
select nome_vendedor, senha
from vendedor
where senha = md5('123456');
```

## MANIPULAÇÃO DE USUÁRIOS
No PostgreSQL, o conceito de usuário é incorporado ao de **Role**. *Role* (papel), grupos de usuários com determinadas permissões. Já os usuários são papéis com senha e que podem se conectar ao Postgre.  

Quando se cria um usuário, esta se criando um role. Nós podemos criar um usuário, alterar suas propriedades e removê-lo.

### Criação e visualização de Usuários

A sintaxe para se criar usuário é:  
```sql
CREATE USER usuário
WITH PASSWORD 'postdba';
```

O CREATE USER é um **aliás** para CREATE ROLE.

Assim, para criarmos um usuário de nome useraula01 procedemos:  
```sql
CREATE USER useraula01
WITH PASSWORD 'postdba';
```

**Para visualizar** os usuários (roles) cadastrados no sistema, usamos o comando:
```sql
\du
```

Outra maneira de visualizar os usuários cadastrados é executando a consulta:
```sql
select * from pg_user;
```

Para fazer login com o usuário *useraula01* com o psql, digitamos:  
```sql
psql -h 172.17.0.1 -U useraula01 -d postgres
```
**Atenção**: O usário vai conseguir entrar no *psql*, mas não visualizar o conteúdo das tabelas. 


Para sabermos qual **usuário está conectado** no psql, use o comando:
```sql
select current_user;
```


### Alteração De Usuário

Para alterar alguma propriedade do usuário, use o comando:  
```sql
ALTER USER nome_usuário
opções
```
#### Exemplos

* **Exemplo 01**: Para trocar a senha do usuário *useraula01*, com o usuário *postgres* digite:
```sql  
ALTER USER useraula01 WITH PASSWORD '123456';
```

* **Exemplo 02**: Para de bloquear um usuário e assim ele não poder entrar no SGBD:
```sql  
ALTER USER useraula01
WITH NOLOGIN;
```

* **Exemplo 03**: Para de desbloquear um usuário e permitir seu login no SGBD:
```sql 
ALTER USER useraula01
WITH LOGIN;
```

### Remoção De Usuário

Para remover um usuário cadastrado, faz-se:
```sql 
DROP USER usuario;
```

Deve-se observar que, quando um usuário possui objetos, deve-se eliminá-los ou atribuir sua propriedade (*owner*) a outro usuário e só depois remover o usuário desejado. Para alterar o proprietário de uma tabela faça:  
```sql 
ALTER TABLE tabelausuario OWNER TO postgres;
```

#### Exemplo
* **Exemplo 01**: Apagando o usuário *useraula01*:  
```sql  
DROP USER useraula01;
```

## PRIVILÉGIOS DE USUÁRIO

Ao ser criado, um usuário tem apenas direito de atuar dentro de um banco de dados como usuário comum. Ele não possui direito de DBA e nem de acessar objetos, como tabelas, visões, etc, de outros usuários. Para que
isso ocorra, ou seja, para que ele tenha o direito sobre objetos de outros usuários, é necessário atribuir concessões por meio do comando grant ao usuário recém criado.  
O comando **grant** permite a concessão de direitos a objetos de usuários contro a objetos do próprio servidor. Com esse comando, é possível que um determinado usuário conceda privilégio de acesso aos seus objetos a outro determinado usuário.  


### Concedendo Privilégios
Para conceder privilégios aos usuários, usa-se o comando grant da seguinte forma:  
```sql
GRANT privilegio [, PRIVILEGIO,...]
ON objeto
TO usuario
```

#### Exemplos
Para observarmos algumas das propriedades funcionais do comando grant, vamos considerar os seguintes exemplos descritos a seguir. Porém, antes, vamos criar um usuário denominado de usergrant para realizações de nossos testes:  
```sql
create user usergrant with password 'postdba';
```

Feito isso, abra dois psql. Com um, conecte-se com o usuário *postgres* e com outro, conecte-se o usuário *usergrant*.  

Com o usuário recém criado não possui um banco de dados próprio, vamos conectar ambos os usuário ao ABDS5.  

Dessa forma, na linha de comando para chamar o psql, digite:  
```sql
psql -h localhost -U postgres -d ABDS5
psql -h localhost -U usergrant -d ABDS5
```

* **Exemplo 01**: tentar acessar os dados da tabela de cliente:

Com o usúario *usergrant*, digite o comando:
```sql
select * from cliente;
```

Após o erro de falta de permissão, com o usuário *postgres*, conceda a permissão da seguinte forma:  

```sql
grant select on cliente to usergrant;
```

Com o usuário *usergrant*, digite, novamente:
```sql
select * from cliente;
```

* **Exemplo 02**: acessar e manipular **todos** os objetos de um banco de dados:

Com o usúario *usergrant*, digite o comando:  

```sql
select * from produto;
```

Após o erro de falta de permissão, com o usuário postgres e dentro do database que você irá conceder todos os direitos (neste exemplo, o comando a seguir deve ser executado dentro do database ABDS5)
conceda a permissão da seguinte forma:  

```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO usergrant;
```

Com o usuário usergrant, digite, novamente:  
```sql
select * from produto;
```

### Revogando privilégios

Uma concedido privilégios aos usuários, a maneira de tirá-los é através do comando revoke. Seu fomato é:

```sql
REVOKE privilegio
ON objeto
FROM usuario;
```

#### Exemplos
Ainda considerando o mesmo ambiente criado na seção anterior com o usuário *usergrant*, vamos realizar alguns exemplos com o comando revoke.  

* **Exemplo 01**: Para tirar o direito do usuário usergrant de acessar os dados da tabela cliente:
```sql  
revoke select on cliente from usergrant;
```

**Exemplo 02**: Para **tirar** o direito do usergrant de acessar **todos os objetos** do banco de dados ABDS5. Você deve  executar de dentro do database ABDS5:
```sql
revoke ALL PRIVILEGES ON ALL TABLES IN SCHEMA public from usergrant ;
```

## Exercícios

Trabalhando com usuário e privilégios

1. Para se criar um usuário no Postgre de nome userexe1, cuja senha seja '12345678', é necessário digitar qual comando? Em seguida faça login com o usuário no database postgres por meio do psql.  
2. Suponha que seja necessário bloquear o login do usuário userexe1, qual comando deveria ser dado para impedir que este usuário pudesse fazer login no Postgre? Tente fazer login com o usuário com o psql.  
3. Agora, desbloqueie o usuário userexe1 e tente novamente fazer login com ele por meio do psql.  
4. Você ficou ficou encarregado de criar o ambiente para a instalação de um software de controle de processos empresariais denominado SIGASYS cujo proprietário seja o usuário postgre. Assim, crie um banco de dados
denominado de SIGASYS e execute nele o script da base de dados da disciplina.  
5. Uma vez criado o ambiente no exercício anterior, você irá executar as seguintes tarefas:  
   a. Criar um usuário denominado *secretaria* que possui somente o direito de visualizar os dados das tabelas de CLIENTE e VENDEDORES. Ela não deverá poder criar, atualizar ou deletar nenhum objeto do banco.  
   b. Criar um usuário denominado *vendedor* que possui os direitos de atualizar, criar e visualizar os dados na tabela de CLIENTE; criar, atualizar, visualizar e apagar dados da tabela de PEDIDO, atualizar, criar e visualizar os dados na tabela de ITEM_PEDIDO e atualizar e visualizar dados da tabela PRODUTO.  
   c. Criar um usuário *gerente* podendo visualizar, inserir, atualizar e deletar dados das tabelas do banco de dados SIGASYS.  
6. Revogue os direitos do usuário *secretaria*.  
7. Crie um database de nome dbvendedor cujo proprietário seja o usuário vendedor já criado anteriormente. Após criar o database, entre nele com o usuário vendedor e crie uma tabela qualquer.  
8. Apague (drop) o usuário userexe1. Caso ele possua objetos, atribua a propriedade a outro usuário.

