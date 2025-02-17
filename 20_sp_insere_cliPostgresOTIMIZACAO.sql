
CREATE TABLE CLIENTE_IND
(
  NOME_CLI	VARCHAR(20) NOT NULL,
  RUA_CLI	VARCHAR(40),
  CIDADE_CLI	VARCHAR(30),
  OBS1	CHAR(255),
  OBS2	CHAR(255),
CONSTRAINT PK_CLIENTE_IND PRIMARY KEY (NOME_CLI)
);

create index idx_cidade on cliente_ind(cidade_cli);


-- Cria a função para inserir os registros no banco de dados
CREATE or replace function f_insere_CLIENTE_IND() returns VOID
as
$$
DECLARE
  vnome_cli   VARCHAR(20);
  vrua_cli    varchar(40); 
  vcidade_cli varchar(30);
  vobs1	      char(255);
  vobs2	      char(255); 
  ii	      integer;
BEGIN     
   FOR ii IN 1..200000  LOOP    
      vnome_cli := 'nome' || ii;
      vrua_cli := 'rua' || ii;
      IF (ii < 50)  THEN
         vcidade_cli := 'Votuporanga';
		ELSE
		   vcidade_cli := 'Sao Paulo';
      END IF;
 	  
 	  IF (ii <=20000)
     THEN     
        vrua_cli := null;
     END IF;
      
      vobs1 := '12345678901234567890123456789012345678901234567890';
      vobs2  := '12345678901234567890123456789012345678901234567890';
   
     insert into cliente_ind
        values (vnome_cli, vrua_cli, vcidade_cli, vobs1, vobs2);

   END LOOP; --FOR
END;
$$
LANGUAGE plpgsql;

--Chama a função
select * from  f_insere_CLIENTE_IND();
