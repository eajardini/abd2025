# REGRAS DE NEGÓCIO E PROGRAMAÇÃO DE SGBD

## Introdução

Nesse capítulo, iremos trabalhar com recurso utilizados tanto pelos administradores quanto pelos programadores.  
Ao longo desse material, serão abordados os seguintes assuntos:  

* Implementação de Regras de Negócio no momento de criação das tabelas (*Check*);  
* Sequências (Sequences);  
* Visões (View);  
* Procedimentos Armazenados (Stored Procedures);  
* Gatilhos (Triggers).

## Implementando Regras de Negócio
As regras de negócio (regras aos quais os valores dos dados devem obedecer) podem serem implementadas no momento da criação das tabelas por meio das restrições check e unique.  

### Restrição Check

**Exemplo**: Um empréstimos só pode ser realizado se for maior do que 10.000,00:
```sql
create table emprestimo(
nome_age_emp varchar(15) not null,
numero_emp varchar(10) not null,
valor_emp numeric(10,2),
constraint pk_emprestimo primary key (numero_emp),
constraint ck_valor check (**valor_emp > 10000**));
```

