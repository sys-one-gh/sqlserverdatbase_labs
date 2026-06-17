USE AdventureWorks2022;
GO

DECLARE @TestProductID INT;
SELECT TOP (1) @TestProductID = ProductID
FROM Production.Product
WHERE ListPrice > 0
ORDER BY ProductID;

DECLARE @rc INT;
DECLARE @msg NVARCHAR(4000);

EXEC RetailAnalytics.usp_SimulateProductMarkup @TestProductID, 10, @rc OUTPUT, @msg OUTPUT;
EXEC RetailAnalytics.usp_SimulateProductMarkup @TestProductID, -5, @rc OUTPUT, @msg OUTPUT;
EXEC RetailAnalytics.usp_SimulateProductMarkup @TestProductID, 30, @rc OUTPUT, @msg OUTPUT;
EXEC RetailAnalytics.usp_SimulateProductMarkup @TestProductID, 25, @rc OUTPUT, @msg OUTPUT;
EXEC RetailAnalytics.usp_SimulateProductMarkup @TestProductID, 0, @rc OUTPUT, @msg OUTPUT;
EXEC RetailAnalytics.usp_SimulateProductMarkup 9999999, 10, @rc OUTPUT, @msg OUTPUT;
EXEC RetailAnalytics.usp_SimulateProductMarkup @TestProductID, 15, @rc OUTPUT, @msg OUTPUT;

