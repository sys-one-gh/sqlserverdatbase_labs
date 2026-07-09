USE AdventureWorks2022;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Training')
BEGIN
    EXEC('CREATE SCHEMA Training;');
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = 'Training' AND t.name = 'ProductPriceAudit'
)
BEGIN
    CREATE TABLE Training.ProductPriceAudit (
        AuditID     INT IDENTITY PRIMARY KEY,
        ProductID   INT           NOT NULL,
        OldPrice    MONEY         NOT NULL CONSTRAINT CK_PPA_OldPrice CHECK (OldPrice >= 0),
        NewPrice    MONEY         NOT NULL CONSTRAINT CK_PPA_NewPrice CHECK (NewPrice >= 0),
        ChangedBy   NVARCHAR(100) NOT NULL,
        ChangeDate  DATETIME      NOT NULL CONSTRAINT DF_PPA_ChangeDate DEFAULT GETDATE(),
        CONSTRAINT FK_PPA_Product FOREIGN KEY (ProductID)
            REFERENCES Production.Product (ProductID)
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = 'Training' AND t.name = 'SchemaChangeLog'
)
BEGIN
    CREATE TABLE Training.SchemaChangeLog (
        LogID       INT IDENTITY PRIMARY KEY,
        EventType   NVARCHAR(100) NOT NULL
            CONSTRAINT CK_SCL_EventType CHECK (EventType IN ('CREATE_TABLE', 'ALTER_TABLE', 'DROP_TABLE')),
        ObjectName  NVARCHAR(100) NOT NULL,
        PerformedBy NVARCHAR(100) NOT NULL,
        EventDate   DATETIME      NOT NULL CONSTRAINT DF_SCL_EventDate DEFAULT GETDATE()
    );
END
GO

SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = 'Training';
GO



-- Task 2 --

USE AdventureWorks2022;
GO

CREATE OR ALTER TRIGGER trg_Product_PriceAudit
ON Production.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(ListPrice)
    BEGIN
        INSERT INTO Training.ProductPriceAudit (ProductID, OldPrice, NewPrice, ChangedBy)
        SELECT d.ProductID, d.ListPrice, i.ListPrice, SUSER_SNAME()
        FROM deleted d
        JOIN inserted i ON d.ProductID = i.ProductID
        WHERE d.ListPrice <> i.ListPrice;
    END
END;
GO

UPDATE Production.Product SET ListPrice = ListPrice * 1.05 WHERE ProductID = 707;
GO

SELECT * FROM Training.ProductPriceAudit;
GO

UPDATE Production.Product SET ListPrice = ListPrice * 1.05 WHERE ProductID = 707;
SELECT * FROM Training.ProductPriceAudit;




-- task 3 --


USE AdventureWorks2022;
GO

CREATE OR ALTER TRIGGER trg_Product_PreventDelete
ON Production.Product
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM deleted d
        JOIN Sales.SalesOrderDetail s ON s.ProductID = d.ProductID
    )
    BEGIN
        PRINT 'Cannot delete products linked to existing sales orders.';
    END

    DELETE p FROM Production.Product p JOIN deleted d ON p.ProductID = d.ProductID WHERE NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail s WHERE s.ProductID = d.ProductID);
END;
GO