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

# cosIndexCreation Stored Procedure

## Overview

The `cosIndexCreation` stored procedure calculates the estimated cost of creating an index on a table in SQL Server. It supports both simple and composite indexes and determines the number of pages that the index will occupy based on the data type of the columns, fill factor, and the number of tuples (rows) in the table.

This procedure is useful for database administrators who need to estimate the disk space requirements before creating indexes on large tables.

## Procedure Logic

- **Input Parameters**:
  - `@coluna`: The column(s) on which the index is to be created. This can be a single column or a composite index with multiple columns.
  - `@tabela`: The name of the table where the index will be created.

- **Steps**:
  - Creates a temporary table to store the size of each column's data type.
  - Iterates over each column specified in the `@coluna` parameter to calculate the data type size using a cursor.
  - Computes the number of pages required to store the index, taking into account SQL Server's page size (8192 bytes), the fill factor (70%), and available space after accounting for page headers.
  - Provides an estimate of the number of pages the index will occupy.

## Formulae for Estimation

- **Composite Index**:
  - Data types are considered (e.g., `Integer` = 4 bytes, `Float` = 17 bytes).
  - Fill Factor: 70%.
  - Page size: 8192 bytes with headers subtracted (96 bytes).
  - Formula used: 
    ```
    [data_type_size * column_count + occupied_spaces] / fill_factor
    ```

- **Simple Index**:
  - Similar to composite indexes but applied to a single column with simpler calculations.

## Example Usage

To execute the procedure and calculate the index creation cost for a column in a table, use the following command in SQL Server:

```sql
EXEC [dbo].[cosIndexCreation] 'l_extendedprice', 'lineitem';
