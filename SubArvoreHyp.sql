/*
Custo da sub arvore 
usando o hipotético

*/

DBCC AUTOPILOT (5, 5, 0, 0, 0)

DBCC AUTOPILOT(6, 1, 359672329,6)
   GO 
SET AUTOPILOT ON 
GO 
SELECT 
     l_orderkey,
     SUM(l_extendedprice * (1 - l_discount)) AS revenue,
     o_orderdate,
     o_shippriority
 FROM  customer, orders, lineitem
WHERE c_mktsegment = 'BUILDING'
  AND c_custkey = o_custkey
  AND l_orderkey = o_orderkey
  AND o_orderdate < (DATEADD(DAY, 5, '1995-12-01'))
  AND l_shipdate < (DATEADD(DAY, 3, '1995-12-01'))
GROUP BY l_orderkey, o_orderdate, o_shippriority
ORDER BY revenue DESC,  o_orderdate
	
GO                                                                                                                           
SET AUTOPILOT OFF 

GO
	
DECLARE @XML XML

SET @XML = (
SELECT CAST(BulkColumn AS XML)
FROM OPENROWSET(BULK N'C:\Users\Eduardo e Fernanda\plan.xml', SINGLE_BLOB) 
AS Arquivo)


DECLARE @subTree varchar (100), @idIndex int, @nomeIndex varchar (100), @Table varchar(100)

;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 

Select @subTree=(


SELECT showPlanXML.value('(@EstimatedTotalSubtreeCost)[1]', 'varchar(max)') AS SubtreeCost
FROM @XML.nodes('//BatchSequence/Batch/Statements/StmtSimple/QueryPlan/RelOp') AS ShowPlanXML(ShowPlanXML) 
)

 
 select @subTree 
 
;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 

Select @Table=(

SELECT showPlanXML.value('(OutputList/ColumnReference/@Table)[1]', 'varchar(max)') AS SubtreeCost
FROM @XML.nodes('//BatchSequence/Batch/Statements/StmtSimple/QueryPlan/RelOp') AS ShowPlanXML(ShowPlanXML) 
)

select @table
 
select @Table
 

SELECT @nomeIndex=(select   top 1 
name
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID(@Table)
AND type_desc <> 'HEAP'
and is_hypothetical=1)

select @nomeIndex

SELECT @idIndex=(select   top 1 
index_id
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID(@Table)
AND type_desc <> 'HEAP'
and is_hypothetical=1)

select @idIndex

/*create table HYPCOST ( SUBTREE_COST_HYP FLOAT, NAME_INDEX varchar(100),  ID_INDEX int)*/

INSERT INTO HYPCOST(SUBTREE_COST_HYP,NAME_INDEX,ID_INDEX) 
VALUES (@subTree, @nomeIndex,@idIndex)

--select* from HYPCOST

/*
CREATE NONCLUSTERED INDEX IX_HypotheticalPrice ON dbo.lineitem (l_extendedprice) 
WITH STATISTICS_ONLY = -1
*/