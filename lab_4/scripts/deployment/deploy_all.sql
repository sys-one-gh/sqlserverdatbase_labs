USE AdventureWorks2022;
GO

PRINT 'Starting Deployment';
PRINT '===================';
GO

PRINT 'Creating Schema';
GO

:r ..\schema\create_schema.sql

PRINT 'Executing Variable Examples';
GO

:r ..\variables\variable_examples.sql

PRINT 'Creating Stored Procedures';
GO

:r ..\procedures\usp_GetEmployeesByJobTitle.sql
:r ..\procedures\usp_GetInventoryAnalysis.sql

PRINT 'Creating Functions';
GO

:r ..\functions\ufn_GetFullName.sql
:r ..\functions\ufn_GetProductsByColor.sql

PRINT 'Deployment Complete';
GO