# Segurança do SGBD PostgreSQL: Usuários e Direitos de Acesso

## 3.1 INTRODUÇÃO  

Para os exemplos desse capítulo, deve ser ter o script que criam as tabelas do curso.
Uma das características que um SGBD deve possuir é o controle de acesso aos dados feito pelos usuário. O SGBD não pode deixar que usuários sem autorização acessem as informações de responsabilidade dele.  
Para garantir esta restrição, o PostgreSQL só permite o acesso aos dados, os usuários previamente cadastrados.   

O PostgreSQL possui um usuário que é criado no momento da instalação:  
 * *postgres*: usuário com direito de administrador. É o que possui maior poder no SGBD.  
