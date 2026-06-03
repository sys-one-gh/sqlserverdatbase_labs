USE AdventureWorks2022;
GO

-- ==============================================================================
-- Task 1: Create Dedicated Operational Reporting Schema
-- Description: Validates existence and creates the OperationalReporting schema.
-- ==============================================================================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'OperationalReporting')
BEGIN
    -- Dynamic SQL is used here because CREATE SCHEMA must be the only statement in a batch
    EXEC('CREATE SCHEMA [OperationalReporting]');
    PRINT 'Schema [OperationalReporting] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [OperationalReporting] already exists.';
END
GO



USE AdventureWorks2022;
GO

-- ==============================================================================
-- Task 2: Implement T-SQL Variables and Dynamic Reporting Filters
-- ==============================================================================
PRINT '--- Executing Task 2: Employee and Product Filter Reporting ---';

DECLARE @JobTitle NVARCHAR(50);
DECLARE @MinVacationHours INT;
DECLARE @SafetyStockLevel INT;

SET @JobTitle = 'Design Engineer';
SET @MinVacationHours = 40;
SET @SafetyStockLevel = 800;

-- Retrieve matching employees
SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.JobTitle,
    e.VacationHours
FROM HumanResources.Employee e
INNER JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.JobTitle = @JobTitle 
  AND e.VacationHours > @MinVacationHours;

-- Retrieve matching products
SELECT 
    ProductID,
    Name,
    SafetyStockLevel
FROM Production.Product
WHERE SafetyStockLevel > @SafetyStockLevel;
GO

-- ==============================================================================
-- Task 3: Implement Conditional Business Logic Using IF...ELSE
-- ==============================================================================
PRINT '--- Executing Task 3: Sales Classification Logic ---';

DECLARE @SalesAmount MONEY;
SET @SalesAmount = 2500.00; -- Change value to test different paths

PRINT 'Sales Amount Evaluated: $' + CONVERT(VARCHAR, @SalesAmount);

IF @SalesAmount < 1000
BEGIN
    PRINT 'Classification: Low Sales';
END
ELSE IF @SalesAmount >= 1000 AND @SalesAmount <= 5000
BEGIN
    PRINT 'Classification: Medium Sales';
END
ELSE
BEGIN
    PRINT 'Classification: High Sales';
END
GO



USE AdventureWorks2022;
GO

-- ==============================================================================
-- Task 4: Create Employee Operational Reporting Stored Procedure
-- ==============================================================================
CREATE OR ALTER PROCEDURE OperationalReporting.usp_GetEmployeesByJobTitle
    @JobTitle NVARCHAR(50),
    @MinVacationHours INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Parameter Validation
    IF @JobTitle IS NULL OR @MinVacationHours IS NULL
    BEGIN
        PRINT 'Error: @JobTitle and @MinVacationHours must not be NULL.';
        RETURN -1;
    END

    -- Retrieve and join employee data
    SELECT 
        e.BusinessEntityID AS EmployeeID,
        -- Note: We will use the function created in Task 6 for full names in standard practice, 
        -- but doing manual concatenation here to keep the SP isolated as requested.
        p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName AS EmployeeFullName,
        e.JobTitle,
        e.VacationHours
    FROM HumanResources.Employee e
    INNER JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE e.JobTitle = @JobTitle
      AND e.VacationHours >= @MinVacationHours
    ORDER BY e.VacationHours DESC;
END
GO



USE AdventureWorks2022;
GO

-- ==============================================================================
-- Task 5: Create Inventory Analysis Stored Procedure
-- ==============================================================================
CREATE OR ALTER PROCEDURE OperationalReporting.usp_GetInventoryAnalysis
    @ReorderThreshold INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Parameter Validation
    IF @ReorderThreshold IS NULL
    BEGIN
        PRINT 'Error: @ReorderThreshold must not be NULL.';
        RETURN -1;
    END

    -- Retrieve products exceeding the reorder threshold
    SELECT 
        ProductID,
        Name AS ProductName,
        SafetyStockLevel,
        ReorderPoint
    FROM Production.Product
    WHERE ReorderPoint > @ReorderThreshold
    ORDER BY ReorderPoint DESC;
END
GO


USE AdventureWorks2022;
GO

-- ==============================================================================
-- Task 6: Create Scalar-Valued Function
-- ==============================================================================
CREATE OR ALTER FUNCTION OperationalReporting.ufn_GetFullName
(
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50)
)
RETURNS NVARCHAR(105)
AS
BEGIN
    DECLARE @FullName NVARCHAR(105);
    
    -- Handle NULL values cleanly
    SET @FullName = LTRIM(RTRIM(ISNULL(@FirstName, '') + ' ' + ISNULL(@LastName, '')));
    
    RETURN @FullName;
END
GO


USE AdventureWorks2022;
GO

-- ==============================================================================
-- Task 7: Create Inline Table-Valued Reporting Function
-- Note: Sorting inside a TVF requires TOP. We use TOP 100 PERCENT to allow ORDER BY.
-- ==============================================================================
CREATE OR ALTER FUNCTION OperationalReporting.ufn_GetProductsByColor
(
    @ProductColor NVARCHAR(15)
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (100) PERCENT
        ProductID,
        Name AS ProductName,
        Color,
        ListPrice
    FROM Production.Product
    WHERE Color = @ProductColor
      AND Color IS NOT NULL
    ORDER BY Name ASC
);
GO



-- ==============================================================================
-- Task 9: Implement SQLCMD Variables and Parameterized Deployment Execution
-- ==============================================================================
:setvar ProductColor "Red"
:setvar MinPrice 1000

USE AdventureWorks2022;
GO

PRINT '--- Executing SQLCMD Parameterized Query ---';
PRINT 'Searching for Color: $(ProductColor) with Minimum Price: $$(MinPrice)';

-- Retrieve products matching SQLCMD variables
SELECT 
    ProductID,
    Name,
    Color,
    ListPrice
FROM Production.Product
WHERE Color = '$(ProductColor)'
  AND ListPrice > $(MinPrice)
ORDER BY ListPrice DESC;
GO



-- ==============================================================================
-- Task 10: SQLCMD Deployment Automation Script
-- Description: Master script to automate deployment of all reporting components.
-- ==============================================================================

PRINT '==================================================';
PRINT 'STARTING DEPLOYMENT: Operational Reporting Objects';
PRINT '==================================================';

-- 1. Deploy Schema
PRINT 'Deploying Schema...';
:r ".\scripts\schema\create_schema.sql"

-- 2. Deploy Functions (Deploying first so procedures or views can use them if needed)
PRINT 'Deploying Functions...';
:r ".\scripts\functions\ufn_GetFullName.sql"
:r ".\scripts\functions\ufn_GetProductsByColor.sql"

-- 3. Deploy Stored Procedures
PRINT 'Deploying Stored Procedures...';
:r ".\scripts\procedures\usp_GetEmployeesByJobTitle.sql"
:r ".\scripts\procedures\usp_GetInventoryAnalysis.sql"

-- 4. Execute Variable and SQLCMD Examples (Optional: usually run as tests)
PRINT 'Executing Variable Examples...';
:r ".\scripts\variables\variable_examples.sql"

PRINT 'Executing SQLCMD Parameterized Script...';
:r ".\scripts\variables\sqlcmd_examples.sql"

PRINT '==================================================';
PRINT 'DEPLOYMENT COMPLETE.';
PRINT '==================================================';
GO