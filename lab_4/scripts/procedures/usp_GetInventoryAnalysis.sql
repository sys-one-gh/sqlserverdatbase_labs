USE AdventureWorks2022;
GO

CREATE OR ALTER PROCEDURE OperationalReporting.usp_GetInventoryAnalysis
(
    @ReorderThreshold INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @ReorderThreshold < 0
    BEGIN
        RAISERROR('Threshold cannot be negative.',16,1);
        RETURN;
    END

    SELECT
        ProductID,
        Name AS ProductName,
        SafetyStockLevel,
        ReorderPoint
    FROM Production.Product
    WHERE ReorderPoint > @ReorderThreshold
    ORDER BY ReorderPoint DESC;

END;
GO


EXEC OperationalReporting.usp_GetInventoryAnalysis
    @ReorderThreshold = 500;
GO