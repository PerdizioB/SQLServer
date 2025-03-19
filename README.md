# SQLServer Performance with index and without index
This project is about performance with index and without index using SQL SERVER and SWRL Rules. 
Performance is essential in a database. Using indexes can bring great improvements to database performance, however, they consume a lot of space and this can affect the database. his project analyzes a query and verifies whether an index needs to be created and when it will be necessary to create this index. The hypothetical index was used for the analysis.
The SWRL rule will decide when and if the index creation will be necessary.

# SQL version
This project was made using SQL 2019.  For more details, see the official [SQL](https://learn.microsoft.com/en-us/sql/sql-server/?view=sql-server-ver16)
 documentation. 

 # Protégé Version
 This project was made using Protegé 3.4. You can install it from this [link]( https://protege.stanford.edu/download/protege/old-releases/Protege%203.x/3.4/full/)

 # Configuring Protégé
 To use the SWRL rules it is necessary to install the Ontop plugin in Protege . For more details, see the official [Ontop](https://ontop-vkg.org/tutorial/basic/setup.html) documentation.

 # Step by step
1. The query used for analysis [queryHypotheticalql.sql](https://github.com/PerdizioB/SQLServer/blob/main/QueryHypotheticalql.sql)
 "The query calculates the total revenue (considering the price after discount) generated from orders placed by customers in the "BUILDING" market segment, filtering orders and items based on specific dates. The result is presented with the highest revenue at the top, and in case of a tie, it is sorted by the order date"
2. [Script.sql](https://github.com/PerdizioB/SQLServer/blob/main/subtreeIndexCost.sql) get the cost of the subtree using the hypothetical index
Summary of What This Script Does:
- The script loads an XML query execution plan from a file.
- It extracts the estimated subtree cost from the plan, the table being used, and the hypothetical index (if any) associated with the table.
- It then inserts this information into a table (HYPCOST) for later analysis.
  
3. Procedure [dbo].[cosIndexCreation](https://github.com/PerdizioB/SQLServer/blob/main/costIndexCreation.sql) this procedure calculates the cost of creating an index.
 - Composite index with 2 attributes of type float and type Integer.
 - Interger Data Type: 4 bytes
 - Float  Data Type: 17 bytes
 - Header: 20 bytes (SQL) *96
<br> **Mathematical formula:**
<br>[ 4 (array pairs) * 1 (attribute)]+[4 (occupied spaces)]+2 (special space estimate)=10
<br>FillFactor: 70% (SQL)
<br>Each Page: 8192 bytes
<br>100%-30%=70%
<br>8192-30% (Fillfactor= 70%) = 2457
<br>2457-96 (Header)=2361 Space to occupy by the index.
<br>2361/10=136.1 (pages)
<br>6001215(Tuple) /136.1=45.463(pages)

Steps Performed in the Procedure:
Create Temporary Table: A temporary table #TB_MAX is created to store the size of each data type for the columns being indexed. The size is stored as a FLOAT.

Create table #TB_MAX(tamanho FLOAT)
Set Initial Values:

@spaceIndex: Set to 5715, representing the available space in bytes for the index after accounting for the page header.
@tuple: This is the number of rows in the table (using a SELECT COUNT(*) query on the lineitem table). The procedure assumes the table being indexed is lineitem, although it takes a parameter for other tables.

set @spaceIndex=5715
set @tuple= (select count(*) from lineitem)
Declare Cursor: A cursor (db_cursor) is declared to iterate over the data types of the columns specified in @coluna. It retrieves the DATA_TYPE from the INFORMATION_SCHEMA.COLUMNS system view.


DECLARE db_cursor CURSOR FOR
SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = @tabela and column_name in (@coluna)
Cursor Logic:

For each column being indexed, the procedure fetches the DATA_TYPE of the column.
It then retrieves the maximum length (max_length) of that data type from the sys.types system table, stores the result in a variable @soma, and inserts this value into the #TB_MAX temporary table.

SELECT @soma=(select  max_length FROM sys.types where name= @cursor)
INSERT INTO #TB_MAX values (@soma)
Index Space Calculation: After iterating through the columns, the procedure calculates the number of pages occupied by the index. The formula involves:

Summing the sizes of the data types (from the #TB_MAX table).
Dividing the total space available for the index by the sum of the data type sizes, then multiplying by 2 (for reasons likely related to how the index data is stored).
Finally, dividing the total number of rows (@tuple) by the result of the previous division to determine the number of pages needed to store the index.

select  @tuple/(select @spaceIndex/(SUM(tamanho)*2) as Tamanho from #TB_MAX)  as PaginasOcupadas
Drop Temporary Table: After the calculation, the temporary table #TB_MAX is dropped to clean up.


drop table #TB_MAX
Formulae Used:
For composite indexes (indexes on multiple columns):

The formula takes into account the sizes of the different column data types (like Integer and Float) and calculates the space they will occupy on a page.
The Fill Factor (70% in this case) defines how much of a page is allowed to be filled before a new page is used.
Available space for the index is reduced by the page header (20 bytes), and calculations proceed based on that available space.
For simple indexes (indexes on a single column):

A simpler calculation is used based on the single column's data type size (like 4 bytes for Integer), and the space available on the page after accounting for headers and fill factor.
Purpose:
The procedure provides an estimate of how many pages will be required to store the index based on:

The size of the data types for the columns being indexed.
The number of rows in the table.
The space available on each page after accounting for headers and the fill factor.
This is helpful for database administrators to understand the impact of creating an index in terms of disk space and efficiency, especially for large tables.
 
 
