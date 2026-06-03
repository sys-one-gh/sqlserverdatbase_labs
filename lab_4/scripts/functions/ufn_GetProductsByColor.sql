USE AdventureWorks2022;
GO

CREATE OR ALTER FUNCTION OperationalReporting.ufn_GetProductsByColor
(
    @ProductColor NVARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ProductID,
        Name AS ProductName,
        Color,
        ListPrice
    FROM Production.Product
    WHERE Color IS NOT NULL
        AND Color = @ProductColor
);
GO


SELECT OperationalReporting.ufn_GetFullName
(
    'John',
    'Smith'
) AS FullName;
GO

SELECT *
FROM OperationalReporting.ufn_GetProductsByColor('Red')
ORDER BY ProductName;
GO