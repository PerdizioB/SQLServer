/*
Subtree cost using hypothetical INDEX
- Read the xml
- Get the cost value of the subtree  
- Gets the name of the table that uses the index
- Get the name od the index and id
- Insert the information HYPCOST

*/

DECLARE @subTree varchar(100),
        @idIndex int,
        @nomeIndex varchar(100),
        @Table varchar(100);

DECLARE @XML XML
SET @XML =
(
    SELECT CAST(BulkColumn AS XML)
    FROM
        OPENROWSET(BULK N'C:\Users\Eduardo e Fernanda\plan.xml', SINGLE_BLOB)
        AS Arquivo
);


WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT @subTree =
(
    SELECT showPlanXML.value('(@EstimatedTotalSubtreeCost)[1]', 'varchar(max)') AS SubtreeCost
    FROM @XML.nodes('//BatchSequence/Batch/Statements/StmtSimple/QueryPlan/RelOp') AS ShowPlanXML(ShowPlanXML)
)
SELECT @subTree;

WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT @Table =
(
    SELECT showPlanXML.value('(OutputList/ColumnReference/@Table)[1]', 'varchar(max)') AS SubtreeCost
    FROM @XML.nodes('//BatchSequence/Batch/Statements/StmtSimple/QueryPlan/RelOp') AS ShowPlanXML(ShowPlanXML)
)
SELECT @nomeIndex =
(
    SELECT top 1
        name
    FROM sys.indexes
    WHERE OBJECT_ID = OBJECT_ID(@Table)
          AND type_desc <> 'HEAP'
          AND is_hypothetical = 1
)
SELECT @idIndex =
(
    SELECT top 1
        index_id
    FROM sys.indexes
    WHERE OBJECT_ID = OBJECT_ID(@Table)
          AND type_desc <> 'HEAP'
          AND is_hypothetical = 1
)
SELECT @idIndex /*create table HYPCOST ( SUBTREE_COST_HYP FLOAT, NAME_INDEX varchar(100),  ID_INDEX int)*/
INSERT INTO HYPCOST
(
    SUBTREE_COST_HYP,
    NAME_INDEX,
    ID_INDEX
)
VALUES
(@subTree, @nomeIndex, @idIndex) --select* from HYPCOST
/*
CREATE NONCLUSTERED INDEX IX_HypotheticalPrice ON dbo.lineitem (l_extendedprice)
WITH STATISTICS_ONLY = -1
*/