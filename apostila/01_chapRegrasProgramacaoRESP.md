
### Resposta dos exercícios sobre regras de negócios

Crie o modelo físico das relações correntista = {cpf, nome, data_nasc, cidade, uf} e conta_corrente {num_conta, cpf_correntista (fk), saldo}. Garanta as seguintes regras de negócio:  

**(a)** Os correntistas devem ser maiores que 18 anos. Para isso, você deve comparar a data de nascimento com a data atual.   
No Postgres, para saber a idade atual, use a **função** _(cast((current_date - data_nasc)/360 as integer) >= 18)_:  
```sql
create table correntista (
    cpf varchar(11),
    nome varchar(20),
    data_nasc date,
    cidade varchar(20),
    uf char(2),
    constraint pk_correntista primary key(cpf),
    constraint ck_idade check(cast((current_date - data_nasc)/360 as integer) >= 18));
	
insert into correntista
values ('123', 'joao', '30/12/2000','Votuporanga', 'SP');
```
**(b)** Uma conta corrente só pode ser aberta com saldo mínimo inicial de R$ 500,00.  
```sql
    create table conta_corrente (
    num_conta integer,
    cpf  varchar(11),
    saldo numeric(7,2),
    constraint pkcontacorrente primary key(num_conta),
    constraint fkcontacorrente foreign key(cpf) references correntista,
    constraint ck_saldo check(saldo >= 500));
	
	insert into conta_corrente
	values (1,'123', 40);
```

### Resposta exercícios sobre Sequences

**1.1. Crie sequências obra, maquina e usa.**

```sql
create table obra (
    id_obra bigint,
    codigo varchar(5),
    descricao varchar(10),
    constraint pk_obra primary key (id_obra),
    constraint un_obra_codigo unique (codigo)
);

create table maquina (
    id_maquina bigint,
    codigo varchar(5),
    marca varchar(10),
    CONSTRAINT pk_maquina primary key (id_maquina),
    CONSTRAINT un_maquina_codigo unique (codigo)
);

create table usa (
    id_usa bigint,
    id_obra bigint,
    id_maquina bigint,
    data_uso date,
    constraint pk_usa PRIMARY KEY (id_usa),
    constraint fk_usa_obra foreign key (id_obra)
                    REFERENCES obra,
    constraint maquina foreign key (id_maquina)
                    REFERENCES maquina
);


create SEQUENCE sid_obra;
create SEQUENCE sid_maquina;
create SEQUENCE sid_usa;
```

**1.2. Insira duas obras e duas máquinas usando as sequência criadas.**

```sql
-- Inserindo em Obra
insert into obra 
values (nextval('sid_obra'), 'o001', 'Obra 001')
returning id_obra;

insert into obra 
values (nextval('sid_obra'), 'o002', 'Obra 002')
returning id_obra;

insert into obra 
values (nextval('sid_obra'), 'o003', 'Obra 003'); -- Note que não usamos o returning


-- Inserindo em Máquina
insert into maquina
values (nextval('sid_maquina'), 'm001', 'Maqu 001');

insert into maquina
values (nextval('sid_maquina'), 'm002', 'Maqu 002');
```

**1.3. Atribua para cada obra as duas máquinas.** 

```sql
insert into usa 
values (nextval('sid_usa'), (select id_obra from obra 
                                   where codigo='o001'),
                            (select id_maquina from maquina 
                                   where codigo='m001'),
                            '25/07/2019');

insert into usa 
values (nextval('sid_usa'), (select id_obra from obra 
                                   where codigo='o001'),
                            (select id_maquina from maquina 
                                   where codigo='m002'),
                            '25/07/2019');

insert into usa 
values (nextval('sid_usa'), (select id_obra from obra 
                                   where codigo='o002'),
                            (select id_maquina from maquina 
                                   where codigo='m001'),
                            '21/06/2019');

insert into usa 
values (nextval('sid_usa'), (select id_obra from obra 
                                   where codigo='o002'),
                            (select id_maquina from maquina 
                                   where codigo='m002'),
                            '21/06/2019');

select * from usa;
```


### 📝 Exercícios sobre Álgebra Relacional
1) Monte uma consulta SQL para trazer os nomes dos clientes (tabela cliente) e dos vendedores (vendedor) e a respectiva quantidade de pedido (tabela pedido) que cada um realizou. Utilize o operador UNION para unir as duas consultas. Você tera que usar uma junção com pedido:

```sql
select nome_cliente, count(cli.codigo_cliente)
from cliente cli, pedido ped
where cli.codigo_cliente = ped.codigo_cliente
group by 1
UNION
select nome_vendedor, count(ven.codigo_vendedor)
from vendedor ven, pedido ped
where ven.codigo_vendedor = ped.codigo_vendedor
group by 1;
```
   
