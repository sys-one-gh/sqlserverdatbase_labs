USE AdventureWorks2022;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'OperationalReporting'
)
BEGIN
    EXEC('CREATE SCHEMA OperationalReporting');
    PRINT 'OperationalReporting schema created.';
END
ELSE
BEGIN
    PRINT 'OperationalReporting schema already exists.';
END;
GO