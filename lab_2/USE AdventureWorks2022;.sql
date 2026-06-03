USE AdventureWorks2022;
GO

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

CREATE TABLE WarehouseInspection (
    InspectionID INT IDENTITY(1,1) NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    InspectionDate DATETIME2 NOT NULL,
    InspectionStatus VARCHAR(30) NOT NULL,
    InspectionScore DECIMAL(5,2) NULL,
    Notes NVARCHAR(500) NULL,
    CreatedDate DATETIME2 NOT NULL 
        CONSTRAINT DF_WarehouseInspection_CreatedDate DEFAULT SYSDATETIME(),

    
    CONSTRAINT PK_WarehouseInspection 
        PRIMARY KEY (InspectionID),

    
    CONSTRAINT FK_WarehouseInspection_Product 
        FOREIGN KEY (ProductID) 
        REFERENCES Production.Product(ProductID),
        
    CONSTRAINT FK_WarehouseInspection_Employee 
        FOREIGN KEY (EmployeeID) 
        REFERENCES HumanResources.Employee(BusinessEntityID),

   
    CONSTRAINT CHK_WarehouseInspection_Status 
        CHECK (InspectionStatus IN ('Passed', 'Failed', 'Pending')),

    CONSTRAINT CHK_WarehouseInspection_Score 
        CHECK (InspectionScore >= 0 AND InspectionScore <= 100)
);
GO