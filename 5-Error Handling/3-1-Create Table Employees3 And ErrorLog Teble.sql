-- Assume we have a table called 'Employees' with a unique constraint on 'EmployeeID'
CREATE TABLE Employees3 (
    EmployeeID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Position NVARCHAR(100)
);

CREATE TABLE ErrorLog (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorNumber INT,
    ErrorMessage NVARCHAR(4000),
    ErrorSeverity  INT,
    ErrorState INT,
    ErrorLine INT,
    ErrorProcedure NVARCHAR(200), ErrorDate DATETIME DEFAULT GETDATE()
);