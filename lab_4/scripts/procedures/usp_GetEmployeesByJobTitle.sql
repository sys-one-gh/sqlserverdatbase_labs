USE AdventureWorks2022;
GO

CREATE OR ALTER PROCEDURE OperationalReporting.usp_GetEmployeesByJobTitle
(
    @JobTitle NVARCHAR(100),
    @MinimumVacationHours INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @JobTitle IS NULL
       OR LTRIM(RTRIM(@JobTitle)) = ''
    BEGIN
        RAISERROR('Job Title cannot be empty.',16,1);
        RETURN;
    END

    IF @MinimumVacationHours < 0
    BEGIN
        RAISERROR('Vacation hours cannot be negative.',16,1);
        RETURN;
    END

    SELECT
        E.BusinessEntityID AS EmployeeID,
        CONCAT(P.FirstName,' ',P.LastName) AS EmployeeFullName,
        E.JobTitle,
        E.VacationHours
    FROM HumanResources.Employee E
    INNER JOIN Person.Person P
        ON E.BusinessEntityID = P.BusinessEntityID
    WHERE E.JobTitle = @JobTitle
        AND E.VacationHours >= @MinimumVacationHours
    ORDER BY E.VacationHours DESC;

END;
GO


EXEC OperationalReporting.usp_GetEmployeesByJobTitle
    @JobTitle = 'Production Technician - WC60',
    @MinimumVacationHours = 20;
GO