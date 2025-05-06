# Segurança do SGBD PostgreSQL: Usuários e Direitos de Acesso

## 3.1 INTRODUÇÃO  

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

