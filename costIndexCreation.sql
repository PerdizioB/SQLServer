--Regra para saber o custo de criação do indice
/* 
- --------------------------------------------
				COMPOSITE  INDEX
- --------------------------------------------
Composite index
with 2 attributes of type float and type Integer.
Interger Data Type: 4 bytes
Float  Data Type: 17 bytes
Header: 20 bytes (SQL) *96

- --------------------------------------------
				FORMULA  INDEX
 - --------------------------------------------

[17 (array pairs) * 1 (attribute) + 4 (array pairs) * 1 (attribute)]+[21 (occupied spaces)]+2 (special space estimate)=42
FillFactor: 70% (SQL)
Each Page: 8192*30% Bytes (But Fillfactor= 70%)= 5735 --30 em espaço vazio
5735-20 (Header)= 5715 of space to occupy by the index.
 
 - --------------------------------------------
				Simple  INDEX
 - --------------------------------------------

with 1 attribute of type Integer.
Interger Data Type: 4 bytes
Header: 96 bytes (SQL) 96 Cada pagina começa com um cabeçalho de 96 paginas

Formula:

[ 4 (array pairs) * 1 (attribute)]+[4 (occupied spaces)]+2 (special space estimate)=10
FillFactor: 70% (SQL)
Each Page: 8192 bytes
100%-30%=70%
8192-30% (Fillfactor= 70%) = 2457
2457-96 (Header)=2361 Space to occupy by the index.

select count(*) from lineitem
2361/10=136.1 (pages)
6001215(Tuple- registro na tabela) /136.1=45.463(paginas)

Parametros da proc: lineitem(tabela),coluna


exec  [dbo].[cosIndexCreation] 'l_extendedprice', 'lineitem'

--Quando for composto terá que usar cursor

*/

ALTER PROCEDURE [dbo].[cosIndexCreation]


@coluna varchar(100),
@tabela varchar(100)

AS
BEGIN



Create table #TB_MAX(

tamanho FLOAT

)


DECLARE
		--@coluna varchar(50),
		@cursor varchar(100),
		@aux varchar(100),
		@header int,
		@spaceIndex int,
		@page int,
		@tuple int,
		--@tabela varchar(50),
	    @columnVal varchar(100)



set @spaceIndex=5715
set @tuple= (select count(*) from lineitem)
--set @coluna  = 'l_extendedprice, L_PARTKEY'

DECLARE db_cursor CURSOR FOR


SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = @tabela and column_name in (@coluna)

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @cursor


WHILE @@FETCH_STATUS = 0  
BEGIN  
declare 	@soma float

--Pego o tamanho do tipo
SELECT @soma=(select  max_length FROM sys.types where name= @cursor)
FETCH NEXT FROM db_cursor INTO @cursor 
INSERT INTO #TB_MAX values (@soma)


END

CLOSE db_cursor  
DEALLOCATE db_cursor 



select  @tuple/(select @spaceIndex/(SUM(tamanho)*2) as Tamanho from #TB_MAX)  as PaginasOcupadas


drop table #TB_MAX



END