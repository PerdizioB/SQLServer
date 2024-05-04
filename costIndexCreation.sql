--Regra para saber o custo de criação do indice
/*
Composite Index:

Composite index
with 2 attributes of type float and type Integer.
Interger Data Type: 4 bytes
Float  Data Type: 17 bytes
Header: 20 bytes
 
Formula:

[17 (array pairs) * 1 (attribute) + 4 (array pairs) * 1 (attribute)]+[21 (occupied spaces)]+2 (special space estimate)=42
FillFactor: 70% (SQL)
Each Page: 8192*30% Bytes (But Fillfactor= 70%)= 5735
5735-20 (Header)= 5715 of space to occupy by the index.

5715/43=132 (pages)
6001215(Tuple) /132=45.463(paginas)

Parametros da proc: lineitem(tabela),coluna



*/


Create table #TB_MAX(

tamanho FLOAT

)


DECLARE
		@coluna varchar(50),
		@cur varchar(100),
		@aux varchar(100),
		@header int,
		@spaceIndex int,
		@page int,
		@tuple int,
		@tabela varchar(50),
	    @columnVal varchar(100)



set @spaceIndex=5715
set @tuple= (select count(*) from lineitem)
set @coluna  = 'l_extendedprice, L_PARTKEY'

DECLARE db_cursor CURSOR FOR


SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'lineitem' and column_name in ('l_extendedprice','L_PARTKEY')

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @cur


WHILE @@FETCH_STATUS = 0  
BEGIN  
declare 	@soma float

--Pego o tamanho do tipo
SELECT @soma=(select  max_length FROM sys.types where name= @cur)
FETCH NEXT FROM db_cursor INTO @cur 
INSERT INTO #TB_MAX values (@soma)


END

CLOSE db_cursor  
DEALLOCATE db_cursor 



select  @tuple/(select @spaceIndex/(SUM(tamanho)*2) as Tamanho from #TB_MAX)  as PaginasOcupadas


drop table #TB_MAX



