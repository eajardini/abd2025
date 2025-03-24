
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
   
### 📝 Exercícios sobre Visões
1. De acordo com o DER da **figura presente na seção de Exercícios de Sequências**, desenvolva as seguintes visões:  
    (a) Uma visão que mostre a descrição da obra, a máquina utilizada e a data do uso. Ordene pela descrição da obra.
    ```sql
        create or replace view v_obra_maquina
	as
	SELECT  obra.descricao, maquina.codigo, to_char(usa.data_uso, 'dd/MM/yyyy')
    	FROM public.maquina, public.obra, public.usa
	WHERE obra.id_obra = usa.id_obra
          AND usa.id_maquina = maquina.id_maquina
	ORDER BY maquina.codigo ASC;
    ```
    
    (b) Uma visão que mostre a descrição da obra e a quantidade de máquinas utilizadas.
    ```sql
	create or replace view v_obra_maquina2
    	as
    	SELECT obra.descricao, count (usa.id_maquina)
    	FROM  public.obra, public.usa
    	WHERE obra.id_obra = usa.id_obra
    	GROUP BY obra.descricao;
    ```
    (C) Uma visão que mostre o nome do cliente, prazo_entrega do pedido, a descricao do produto vendido, a quantidade e o valor_venda nos itens do pedido e o valor total por produto (item_pedido.valor_venda * item_pedido.quantidade):   
    ```sql
    create view bi_cliente_pedido
    as
    SELECT cliente.nome_cliente, pedido.prazo_entrega, produto.descricao,
           produto.valor_venda, item_pedido.quantidade,
           (produto.valor_venda * item_pedido.quantidade) "Valor Total"
    FROM cliente, pedido, produto, Item_pedido
    WHERE cliente.codigo_cliente = pedido.codigo_cliente
      AND pedido.num_pedido = item_pedido.num_pedido
      AND item_pedido.codigo_produto = produto.codigo_produto;
    ```

### 📝 A) Exercícios sobre Funções
1. Implemente um procedimento que receba 4 parâmetros. Os dois primeiros serão números que sofrerão uma das quatro operações básicas da matemática adição, subtração, multiplicação e divisão; o terceiro parâmetro será uma variável que armazenará o resultado da operação e por fim, o quarto parâmetro indicará qual  será a operação realizada. Após implementar, teste o procedimento e veja se está funcionando corretamente.
```sql
	create or replace function f_claculadora (num1Par numeric, num2Par numeric, respPar numeric, operacaoPar char) returns numeric
	as
	$$
	begin
	  if operacaoPar = '+' then
	    respPar = num1Par + num2Par;
	  elseif operacaoPar = '-' then
	    respPar = num1Par - num2Par;
	  elseif operacaoPar = '*' then
	    respPar = num1Par * num2Par;
	  elseif operacaoPar = '/' then
	    respPar = num1Par / num2Par;
	  else
	    respPar = 0;
	  end if;
	
	  return respPar;
	end;
	$$
	language plpgsql;
	uso: select f_claculadora(10, 5, 0, '+');
```
   
   
2. Projete uma função que informado o código do cliente por parâmetro, encontre o valor total das compras desse cliente. Como retorno, a função deve informar o nome do cliente concatenado com o valor da compra. Você deverá usar as tabelas cliente, pedido, item_pedido e produto.
```sql
	create or replace function f_TotalCliente (codigo_clientePar numeric) returns text
	as
	$$
	Declare
	  nome_clienteRetorno cliente.nome_cliente%type;
	  Valor_TotalRetorno numeric;
	
	begin
	  select cliente.nome_cliente, 
	         SUM(produto.valor_venda * item_pedido.quantidade) "Valor Total" 
	         INTO nome_clienteRetorno, Valor_TotalRetorno 
	  FROM 
	         public.cliente, public.pedido, public.produto, public.item_pedido
	  WHERE 
	         cliente.codigo_cliente = pedido.codigo_cliente AND
	         pedido.num_pedido = item_pedido.num_pedido AND
	         item_pedido.codigo_produto = produto.codigo_produto AND
	         cliente.codigo_cliente = codigo_clientePar
	  GROUP BY cliente.nome_cliente;
	
	  RETURN nome_clienteRetorno || ': ' || Valor_TotalRetorno;
	end;
	$$
	language plpgsql;
	uso: select f_TotalCliente(720);
```


### 📝 B) Exercícios sobre Funções
1) Desenvolva uma função que passado o *codigo do curso* (**tabela curso**), encontre as turmas e os alunos que estão matriculados no curso. Você terá que fazer a junção entre as tabelas curso, turma, aluno e histórico.
   O retorno deve ser uma **table** com os campos: nome do curso, código da turma e nome do aluno.
```sql
CREATE OR REPLACE FUNCTION f_AlunosCurso (curcodPar curso.cur_cod%TYPE
)  
RETURNS TABLE(nomeCursoPars VARCHAR, codigoTurmaPars int,  nomeAlunoPars VARCHAR)  
AS $$    
BEGIN 
    FOR nomeCursoPars, codigoTurmaPars, nomeAlunoPars IN  
        select cur_nome, tur_codtur, alu_nome
        from curso c, turma t, aluno a, historico h 
        where c.cur_cod = t.tur_codigocurso
          and t.tur_codtur = h.hist_codigoturma
          and h.hist_matriculaaluno = a.alu_matricula
          and c.cur_cod = curcodPar
    LOOP        
        RETURN NEXT;  
    END LOOP; 


    -- Se nenhum registro for encontrado, levanta um erro
    IF NOT FOUND THEN  
        RAISE EXCEPTION 'O curso % não foi encontrado', curcodPar  
        USING ERRCODE = 'ERR01';  
    END IF;  
END;  
$$ LANGUAGE plpgsql;

uso: select * from f_AlunosCurso(1);

```

### 📝 Exercícios sobre Trigger

1. Desenvolva um gatilho para monitorar a alteração dos endereços dos clientes. Toda vez que um cliente tiver seu endereço alterado por meio de um comando UPDATE, a alteração deve ser registrada por meio de um INSERT em uma tabela de log.
Assim, na função do Trigger deve haver um comando INSERT e o evento do Trigger deve ser BEFORE UPDATE.
```sql
CREATE OR REPLACE FUNCTION log_alteracoes_clientes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_clientes (id, codigo_cliente, endereco_antigo,endereco_novo, data_modificacao)
    VALUES (default, OLD.codigo_cliente,OLD.endereco, NEW.endereco, NOW());

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trg_log_clientes
AFTER UPDATE ON cliente
FOR EACH ROW
EXECUTE FUNCTION log_alteracoes_clientes();


Executando:
update cliente
set endereco = 'Nova rua'
where codigo_cliente = 720;


Verificando:
select * from log_clientes;
```

2. Desenvolva um trigger que evite a venda de um produto cujo estoque seja menor que a quantidade vendida. Porém, caso haja estoque, deverá ser dado baixa no item no estoque. O trigger deverá ser criado sob a **tabela item_pedido**. Toda vez que um registro for inserido nela, antes da inserção (BEFORE), o trigger
deverá verificar se existe estoque suficiente na tabela produto. Você deverá criar uma variável na função que receberá a quantidade atual em estoque (tabela produto) por meio de um **select into**. Em seguinda, deverá ser comparada a quantidade a ser vendida (variável NEW) com a quantidade em estoque (obtida pelo *select into*). Caso aquela seja menor ou igual a quantidade em estoque, será efetuada a baixa no estoque, caso contrário será gerado um erro com o comando Raise Exception impossibilitando a operação.

```sql

-- Criando a função

create or replace   function f_BaixaEstoque() returns TRIGGER
as $$
declare 
	qtdeEstoque produto.quantidade%type;

begin
    select quantidade into qtdeEstoque
	from produto
	where codigo_produto = new.codigo_produto;

    if (qtdeEstoque >= new.quantidade) THEN
        update produto
        set quantidade = quantidade - new.quantidade
        where codigo_produto = new.codigo_produto;
    ELSE
         raise EXCEPTION 'Quantidade insuficiente de produto' using ERRCODE = 'ER003';        
    end if;

    return new;
end;
$$
LANGUAGE plpgsql;


-- Criando o trigger

create trigger tr_baixa_estoque
before insert
on item_pedido for each row
execute procedure f_BaixaEstoque();

--Realizando testes

INSERT INTO item_pedido
    values (121, 25, 5, (select valor_venda
                            from produto
                           where codigo_produto = 25), 
                           (select valor_custo
                            from produto
                           where codigo_produto = 25) );


-- Verificando as alterações

select * from produto;
select * from item_pedido;

```

3. (ENADE) Em um Banco de Dados PostgreSQL, Joana precisa criar uma trigger para inserir dados na tabela de auditoria chamada AGENTE_AUDIT todas as vezes que um registro da tabela AGENTE for efetivamente excluído. Para isso, considerando que a função "agente_removido()" já esteja implementada, Joana utilizará
o comando:  
Resposta: Letra D
