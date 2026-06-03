# SQL Server Developer - Lab 4
**Course:** SQL Server Developer  
**Lab Title:** Introduction to T-SQL Scripting, Variables, Stored Procedures, Functions, and SQLCMD Automation  

**Student Name:** [Enter Your Name]  
**Student Number:** [Enter Your Student Number]  

## Lab Overview
This repository contains a suite of reusable T-SQL scripting solutions for an enterprise Microsoft SQL Server environment (AdventureWorks2022). It includes dynamic parameterization using variables, business logic using IF...ELSE, stored procedures, inline table-valued functions, scalar functions, and a master SQLCMD deployment script. All objects are safely deployed to a dedicated `OperationalReporting` schema.

## Execution Instructions

**Prerequisites:**
1. Ensure Microsoft SQL Server Developer Edition and SSMS are installed.
2. The `AdventureWorks2022` database must be restored to your local instance.

**Deployment:**
1. Open SQL Server Management Studio (SSMS).
2. Connect to your local SQL Server instance.
3. Open the master deployment script located at `scripts/deployment/deploy_all.sql`.
4. **CRITICAL:** Enable SQLCMD mode by navigating to the top menu: `Query` > `SQLCMD Mode`.
5. Execute the script. 
*(Note: If you run into pathing errors, ensure your SSMS working directory matches the root of this repository, or update the relative paths in `deploy_all.sql` to absolute paths).*

**Validating Reporting Functions (Task 8):**
Once deployed, open a standard query window and run the following to validate the functions:
```sql
USE AdventureWorks2022;
GO
-- Test Scalar Function
SELECT OperationalReporting.ufn_GetFullName('John', 'Smith') AS FullName;

-- Test Inline Table-Valued Function
SELECT * FROM OperationalReporting.ufn_GetProductsByColor('Red');