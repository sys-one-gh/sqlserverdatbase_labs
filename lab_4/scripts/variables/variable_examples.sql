USE AdventureWorks2022;
GO

DECLARE @JobTitle NVARCHAR(50);
DECLARE @MinimumVacationHours INT;
DECLARE @ProductSafetyStockLevel INT;

SET @JobTitle = 'Production Technician - WC60';
SET @MinimumVacationHours = 20;
SET @ProductSafetyStockLevel = 500;

PRINT 'Employee Report';
PRINT '----------------';

SELECT
    E.BusinessEntityID AS EmployeeID,
    P.FirstName,
    P.LastName,
    E.JobTitle,
    E.VacationHours
FROM HumanResources.Employee E
INNER JOIN Person.Person P
    ON E.BusinessEntityID = P.BusinessEntityID
WHERE E.JobTitle = @JobTitle
    AND E.VacationHours > @MinimumVacationHours;

PRINT 'Product Report';
PRINT '----------------';

SELECT
    ProductID,
    Name,
    SafetyStockLevel,
    ReorderPoint
FROM Production.Product
WHERE SafetyStockLevel > @ProductSafetyStockLevel;
GO

DECLARE @SalesAmount DECIMAL(12,2);

SET @SalesAmount = 6500;

IF @SalesAmount < 1000
BEGIN
    PRINT 'Low Sales';
END
ELSE IF @SalesAmount BETWEEN 1000 AND 5000
BEGIN
    PRINT 'Medium Sales';
END
ELSE
BEGIN
    PRINT 'High Sales';
END;
GO