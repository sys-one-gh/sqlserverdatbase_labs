# Lab 4 – Introduction to T-SQL Scripting, Variables, Stored Procedures, Functions, and SQLCMD Automation

## Student Information

Name: Dhruv Patel

Student Number: __________

## Overview

This lab demonstrates:

- T-SQL variables
- Conditional business logic
- Stored procedures
- Scalar-valued functions
- Inline table-valued functions
- SQLCMD variables
- SQLCMD deployment automation
- Enterprise SQL Server script organization

Database Used:

AdventureWorks2022

## Folder Structure

```text
scripts/
    schema/
    variables/
    procedures/
    functions/
    deployment/
```

## Execution Instructions

### Step 1

Restore AdventureWorks2022 database.

### Step 2

Open SQL Server Management Studio.

### Step 3

Enable SQLCMD Mode.

Query → SQLCMD Mode

### Step 4

Open:

scripts/deployment/deploy_all.sql

### Step 5

Execute deployment script.

### Step 6

Validate objects:

```sql
EXEC OperationalReporting.usp_GetEmployeesByJobTitle
    @JobTitle = 'Production Technician - WC60',
    @MinimumVacationHours = 20;

EXEC OperationalReporting.usp_GetInventoryAnalysis
    @ReorderThreshold = 500;

SELECT OperationalReporting.ufn_GetFullName('John','Smith');

SELECT *
FROM OperationalReporting.ufn_GetProductsByColor('Red')
ORDER BY ProductName;
```

## Deliverables

- SQL Scripts
- SQLCMD Scripts
- Screenshots
- GitHub Repository Link
