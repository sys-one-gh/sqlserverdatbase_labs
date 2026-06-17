IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'RetailAnalytics')
BEGIN
    CREATE SCHEMA RetailAnalytics;
END
GO

IF OBJECT_ID('RetailAnalytics.ufn_CalculateMarkedUpPrice','FN') IS NOT NULL
    DROP FUNCTION RetailAnalytics.ufn_CalculateMarkedUpPrice;
GO
CREATE FUNCTION RetailAnalytics.ufn_CalculateMarkedUpPrice
(
    @ListPrice DECIMAL(19,4),
    @MarkupPercent DECIMAL(5,2)
)
RETURNS DECIMAL(19,4)
AS
BEGIN
    RETURN ROUND(@ListPrice * (1 + @MarkupPercent / 100.0), 4);
END
GO

IF OBJECT_ID('RetailAnalytics.usp_SimulateProductMarkup','P') IS NOT NULL
    DROP PROCEDURE RetailAnalytics.usp_SimulateProductMarkup;
GO
CREATE PROCEDURE RetailAnalytics.usp_SimulateProductMarkup
    @ProductID INT,
    @MarkupPercent DECIMAL(5,2),
    @ReturnCode INT OUTPUT,
    @ReturnMessage NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductName NVARCHAR(200);
    DECLARE @ListPrice DECIMAL(19,4);
    DECLARE @SimulatedNewPrice DECIMAL(19,4);

    IF @ProductID IS NULL
    BEGIN
        SET @ReturnCode = -1;
        SET @ReturnMessage = 'ProductID is NULL';
        RETURN;
    END

    IF @MarkupPercent IS NULL
    BEGIN
        SET @ReturnCode = -2;
        SET @ReturnMessage = 'Markup percent is NULL';
        RETURN;
    END

    IF @MarkupPercent < 0
    BEGIN
        SET @ReturnCode = -3;
        SET @ReturnMessage = 'Markup percent is invalid';
        RETURN;
    END

    IF @MarkupPercent > 25
    BEGIN
        SET @ReturnCode = -4;
        SET @ReturnMessage = 'Markup percent rejected';
        RETURN;
    END

    SELECT @ProductName = Name, @ListPrice = ListPrice
    FROM Production.Product
    WHERE ProductID = @ProductID;

    IF @ProductName IS NULL
    BEGIN
        SET @ReturnCode = -5;
        SET @ReturnMessage = 'Product not found';
        RETURN;
    END

    IF @ListPrice IS NULL OR @ListPrice <= 0
    BEGIN
        SET @ReturnCode = -6;
        SET @ReturnMessage = 'Product has zero ListPrice';
        RETURN;
    END

    SET @SimulatedNewPrice = RetailAnalytics.ufn_CalculateMarkedUpPrice(@ListPrice, @MarkupPercent);
    SET @ReturnCode = 0;
    SET @ReturnMessage = 'Processed successfully';

    SELECT @ProductID AS ProductID,
           @ProductName AS ProductName,
           @ListPrice AS CurrentListPrice,
           @MarkupPercent AS MarkupPercent,
           @SimulatedNewPrice AS SimulatedNewPrice,
           @SimulatedNewPrice - @ListPrice AS PriceChangeAmount,
           'Accepted' AS ProcessingStatus,
           @ReturnMessage AS ProcessingMessage;
END
GO
