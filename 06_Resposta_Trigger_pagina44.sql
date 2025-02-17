--Exercício sobre Trigger

create or replace 
 function f_BaixaEstoque() returns TRIGGER
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
         raise 'Quantidade insuficiente de produto'
            using ERRCODE = 'ER003';        
    end if;

    return new;
end;
$$
LANGUAGE plpgsql;

create trigger tr_baixa_estoque
before insert
on item_pedido for each row
execute procedure f_BaixaEstoque();

INSERT INTO item_pedido
    values (121, 25, 5, (select valor_venda
                            from produto
                           where codigo_produto = 25), 
                           (select valor_custo
                            from produto
                           where codigo_produto = 25) );

    select * from produto;
    select * from item_pedido;
