USE AdventureWorks2022;
GO

CREATE OR ALTER FUNCTION OperationalReporting.ufn_GetFullName
(
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50)
)
RETURNS NVARCHAR(150)
AS
BEGIN

    DECLARE @FullName NVARCHAR(150);

    SET @FullName =
        CONCAT(
            ISNULL(@FirstName,''),
            CASE
                WHEN @FirstName IS NOT NULL
                 AND @LastName IS NOT NULL
                THEN ' '
                ELSE ''
            END,
            ISNULL(@LastName,'')
        );

    RETURN @FullName;

END;
GO