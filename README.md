# SQLServer Performance with Index and Without Index

This project analyzes database performance with and without indexes using **SQL Server** and **SWRL Rules**.  
While indexes improve query performance, they consume storage and may affect the database. This project evaluates when creating an index is necessary using hypothetical indexes and SWRL rules.

---

## Technologies Used

- **SQL Server 2019** — official docs: [here](https://learn.microsoft.com/en-us/sql/sql-server/?view=sql-server-ver16)
- **Protégé 3.4** — download: [here](https://protege.stanford.edu/download/protege/old-releases/Protege%203.x/3.4/full/)
- **Ontop plugin** for SWRL rules — setup: [here](https://ontop-vkg.org/tutorial/basic/setup.html)

---

## Project Components

1. **Query Analysis**  
   Calculates total revenue (after discounts) for orders in the "BUILDING" market segment filtered by date.  
   [QueryHypotheticalql.sql](https://github.com/PerdizioB/SQLServer/blob/main/QueryHypotheticalql.sql)

2. **Hypothetical Index Cost Script**  
   Extracts estimated subtree cost from query plans related to hypothetical indexes.  
   [subtreeIndexCost.sql](https://github.com/PerdizioB/SQLServer/blob/main/subtreeIndexCost.sql)

3. **Index Creation Cost Procedure**  
   Calculates estimated disk space cost of creating an index, supporting composite indexes.  
   [costIndexCreation.sql](https://github.com/PerdizioB/SQLServer/blob/main/costIndexCreation.sql)

---

## cosIndexCreation Stored Procedure

### Purpose

Estimates disk space (in pages) needed for an index on specified columns of a table, considering SQL Server's page size, fill factor, and data types.

### Parameters

- `@coluna`: Columns for the index (single or composite)
- `@tabela`: Table name

### Usage Example

```sql
EXEC [dbo].[cosIndexCreation] 'l_extendedprice', 'lineitem';
