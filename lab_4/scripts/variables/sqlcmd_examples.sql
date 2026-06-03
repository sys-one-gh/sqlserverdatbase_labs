:setvar ProductColor Red
:setvar MinPrice 1000

USE AdventureWorks2022;
GO

PRINT 'SQLCMD Product Report';
PRINT '---------------------';

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