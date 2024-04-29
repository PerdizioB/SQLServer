/*
Essa parte é para poder pegar o valor do custo da sub arvore
e calcular o custo de criação do indice usando o hipotético

*/
DBCC AUTOPILOT(0, 1, 391672443,7)
   GO 
SET AUTOPILOT ON 
GO 
SELECT
l_linestatus,
     l_returnflag,
       SUM (l_extendedprice) AS sumbaseprice,
       SUM (l_extendedprice * (1- l_discount)) AS sumdiscprice,
       SUM (l_quantity) AS sumqty,
       SUM (l_extendedprice*(1-l_discount)*(1+l_tax)) AS symcharge,
       AVG (l_quantity) AS avgqty,
       AVG (l_extendedprice) AS avgprice,
       AVG (l_discount) AS avgdisc,
       COUNT(*) AS countorder
FROM lineitem l
WHERE l_shipdate <= (DATEADD(DAY, -87, '1998-12-01'))
GROUP BY l_returnflag,
         l_linestatus
ORDER BY l_returnflag,
         l_linestatus
GO 
SET AUTOPILOT OFF 

GO
	
DECLARE @XML XML

SET @XML = (
SELECT CAST(BulkColumn AS XML)
FROM OPENROWSET(BULK N'C:\Users\Eduardo e Fernanda\plan.xml', SINGLE_BLOB) 
AS Arquivo)


DECLARE @valor varchar(30), @idIndex int, @nomeIndex varchar (100), @T varchar (100)

;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 

Select @valor=(

SELECT showPlanXML.value('(RelOp/@EstimatedTotalSubtreeCost)[1]', 'varchar(max)') AS SubtreeCost
FROM @XML.nodes('//BatchSequence/Batch/Statements/StmtSimple/QueryPlan') AS ShowPlanXML(ShowPlanXML) 
)



select @valor

Select @T=(

 SELECT showPlanXML.value('(StatisticsInfo/@Table)[1]', 'varchar(max)') AS T
FROM @XML.nodes('//BatchSequence/Batch/Statements/StmtSimple/QueryPlan/OptimizerStatsUsage/StatisticsInfo') AS ShowPlanXML(ShowPlanXML) 
)

select @T as t




SELECT @nomeIndex=(select   top 1 
name
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('lineitem')
AND type_desc <> 'HEAP')

SELECT @idIndex=(select   top 1 
index_id
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('lineitem')
AND type_desc <> 'HEAP')


exec dbo.GetHIndex  @valor, @idIndex, @nomeIndex

/*

SELECT *
FROM sys.dm_exec_cached_plans EX_CP
  CROSS APPLY sys.dm_exec_query_plan(EX_CP.plan_handle) EX_QP
  CROSS APPLY sys.dm_exec_sql_text(EX_CP.plan_handle) EX_SQLTXT

  */
  /*
  
DBCC AUTOPILOT(0, 1, 391672443,7)
   GO 
SET AUTOPILOT ON --frf
 go
SELECT
--ioio
l_linestatus,
     l_returnflag,
       SUM (l_extendedprice) AS sumbaseprice,
       SUM (l_extendedprice * (1- l_discount)) AS sumdiscprice,
       SUM (l_quantity) AS sumqty,
       SUM (l_extendedprice*(1-l_discount)*(1+l_tax)) AS symcharge,
       AVG (l_quantity) AS avgqty,
       AVG (l_extendedprice) AS avgprice,
       AVG (l_discount) AS avgdisc,
       COUNT(*) AS countorder
FROM lineitem l
WHERE l_shipdate <= (DATEADD(DAY, -87, '1998-12-01'))
GROUP BY l_returnflag,
         l_linestatus
ORDER BY l_returnflag,
         l_linestatus

GO 
SET AUTOPILOT OFF 
GO
*/