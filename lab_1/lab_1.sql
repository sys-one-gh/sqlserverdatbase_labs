USE AdventureWorks2022;
GO

IF OBJECT_ID('EntryTest.OrderItemMini', 'U') IS NOT NULL
    DROP TABLE EntryTest.OrderItemMini;
GO

IF OBJECT_ID('EntryTest.OrderMini', 'U') IS NOT NULL
    DROP TABLE EntryTest.OrderMini;
GO

IF OBJECT_ID('EntryTest.CustomerMini', 'U') IS NOT NULL
    DROP TABLE EntryTest.CustomerMini;
GO

IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'EntryTest'
)
BEGIN
    EXEC('CREATE SCHEMA EntryTest');
END
GO

CREATE TABLE EntryTest.CustomerMini
(
    CustomerMiniID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL UNIQUE,
    AccountNumber NVARCHAR(20) NOT NULL,
    CustomerType NCHAR(1) NOT NULL
        CHECK (CustomerType IN ('I','S')),
    CreatedAt DATETIME2(0) NOT NULL
        DEFAULT SYSDATETIME()
);
GO

CREATE TABLE EntryTest.OrderMini
(
    OrderMiniID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID INT NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    SubTotal MONEY NOT NULL
        CHECK (SubTotal >= 0),
    TaxAmt MONEY NOT NULL
        CHECK (TaxAmt >= 0),
    Freight MONEY NOT NULL
        CHECK (Freight >= 0),
    TotalDue MONEY NOT NULL
        CHECK (TotalDue >= 0)
);
GO

CREATE TABLE EntryTest.OrderItemMini
(
    OrderItemMiniID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID INT NOT NULL,
    SalesOrderDetailID INT NOT NULL,
    ProductID INT NOT NULL,
    OrderQty SMALLINT NOT NULL
        CHECK (OrderQty > 0),
    UnitPrice MONEY NOT NULL
        CHECK (UnitPrice >= 0),
    UnitPriceDiscount MONEY NOT NULL
        DEFAULT(0)
        CHECK (UnitPriceDiscount BETWEEN 0 AND 1),
    LineTotal MONEY NOT NULL
        CHECK (LineTotal >= 0),

    CONSTRAINT UQ_OrderItemMini
        UNIQUE (SalesOrderID, SalesOrderDetailID),

    CONSTRAINT FK_OrderItemMini_OrderMini
        FOREIGN KEY (SalesOrderID)
        REFERENCES EntryTest.OrderMini(SalesOrderID)
);
GO

INSERT INTO EntryTest.CustomerMini
(
    CustomerID,
    AccountNumber,
    CustomerType
)
SELECT TOP 50
    CustomerID,
    AccountNumber,
    'I' AS CustomerType
FROM Sales.Customer
ORDER BY CustomerID ASC;
GO

INSERT INTO EntryTest.OrderMini
(
    SalesOrderID,
    CustomerID,
    OrderDate,
    SubTotal,
    TaxAmt,
    Freight,
    TotalDue
)
SELECT TOP 200
    SalesOrderID,
    CustomerID,
    CAST(OrderDate AS DATE),
    SubTotal,
    TaxAmt,
    Freight,
    TotalDue
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC,
         SalesOrderID DESC;
GO

INSERT INTO EntryTest.OrderItemMini
(
    SalesOrderID,
    SalesOrderDetailID,
    ProductID,
    OrderQty,
    UnitPrice,
    UnitPriceDiscount,
    LineTotal
)
SELECT
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    sod.ProductID,
    sod.OrderQty,
    sod.UnitPrice,
    sod.UnitPriceDiscount,
    sod.LineTotal
FROM Sales.SalesOrderDetail sod
INNER JOIN EntryTest.OrderMini om
    ON sod.SalesOrderID = om.SalesOrderID;
GO

MERGE EntryTest.CustomerMini AS target
USING
(
    SELECT
        CustomerID,
        AccountNumber,
        'I' AS CustomerType
    FROM Sales.Customer
    WHERE CustomerID <= 60
) AS source

ON target.CustomerID = source.CustomerID

WHEN MATCHED THEN
    UPDATE SET
        target.AccountNumber = source.AccountNumber,
        target.CustomerType = source.CustomerType

WHEN NOT MATCHED THEN
    INSERT
    (
        CustomerID,
        AccountNumber,
        CustomerType
    )
    VALUES
    (
        source.CustomerID,
        source.AccountNumber,
        source.CustomerType
    );
GO

SELECT NameValue
FROM
(
    SELECT TOP 10
        FirstName AS NameValue
    FROM Person.Person
    ORDER BY BusinessEntityID

    UNION

    SELECT TOP 10
        LastName AS NameValue
    FROM Person.Person
    ORDER BY BusinessEntityID
) AS CombinedNames
ORDER BY NameValue ASC;
GO

SELECT
    'FinishedGoods' AS ListType,
    ProductID,
    Name
FROM
(
    SELECT TOP 10
        ProductID,
        Name
    FROM Production.Product
    WHERE FinishedGoodsFlag = 1
    ORDER BY ProductID ASC
) AS FG

UNION ALL

SELECT
    'NotFinished' AS ListType,
    ProductID,
    Name
FROM
(
    SELECT TOP 10
        ProductID,
        Name
    FROM Production.Product
    WHERE FinishedGoodsFlag = 0
    ORDER BY ProductID ASC
) AS NFG;
GO

SELECT
    om.SalesOrderID,
    om.OrderDate,
    cm.CustomerID,
    cm.AccountNumber,
    om.TotalDue
FROM EntryTest.OrderMini om
INNER JOIN EntryTest.CustomerMini cm
    ON om.CustomerID = cm.CustomerID
ORDER BY om.OrderDate DESC;
GO

SELECT
    cm.CustomerID,
    cm.AccountNumber,
    om.SalesOrderID,
    om.OrderDate
FROM EntryTest.CustomerMini cm
LEFT JOIN EntryTest.OrderMini om
    ON cm.CustomerID = om.CustomerID
ORDER BY cm.CustomerID ASC;
GO

SELECT
    cm.CustomerID,
    COUNT(om.SalesOrderID) AS OrderCount,
    SUM(om.TotalDue) AS TotalSpent
FROM EntryTest.CustomerMini cm
LEFT JOIN EntryTest.OrderMini om
    ON cm.CustomerID = om.CustomerID
GROUP BY cm.CustomerID
ORDER BY cm.CustomerID;
GO