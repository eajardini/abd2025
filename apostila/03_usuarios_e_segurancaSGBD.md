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

Note que as senhas dos usuários aparecem criptografas pelo padrão MD5. Além disso, é na tabela pg_shadow o SGBD Postgres armazena os usuários cadastrados nele.  
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

Assim, para criarmos um usuário de nome pauloafonso procedemos:  
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

### Alteração De Usuário

Para alterar alguma propriedade do usuário, use o comando:  
```sql
ALTER USER nome_usuário
opções
```
#### Exemplos

* **Exemplo 01**: Para trocar a senha de um usuário  
```sql  
ALTER USER useraula01 WITH PASSWORD '123456';
```

* **Exemplo 02**: Para de bloquear um usuário e assim ele não poder entrar no SGBD:
```sql  
ALTER USER useraula01
WITH NOLOGIN;
```

