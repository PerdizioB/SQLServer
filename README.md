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
3. [Script.sql](https://github.com/PerdizioB/SQLServer/blob/main/subtreeIndexCost.sql) get the cost of the subtree using the hypothetical index
- Read the xml
- Get the cost value of the subtree  
- Gets the name of the table that uses the index
- Get the index name and index id
- Insert the information HYPCOST
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


 
 
