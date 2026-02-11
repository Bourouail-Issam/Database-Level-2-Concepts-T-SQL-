
BEGIN TRY

    BEGIN TRANSACTION;

    -- Insert a record into the Employees table
	INSERT INTO Employees3 (EmployeeID, Name ,Position) VALUES (1, 'John Doe', 'Sales Manager');
	 -- Attempt to insert a duplicate record which will cause an error
	INSERT INTO Employees3 (EmployeeID, Name, Position) VALUES (1, 'Jane Smith', 'Marketing Manager');
	
	COMMIT TRANSACTION;

END TRY

BEGIN CATCH

   ROLLBACK TRANSACTION;   
   INSERT INTO ErrorLog (ErrorNumber,ErrorMessage,ErrorSeverity,ErrorState,ErrorLine,ErrorProcedure) 
   VALUES
      (ERROR_NUMBER(),ERROR_MESSAGE(),ERROR_SEVERITY(),
	  ERROR_STATE(),ERROR_LINE(),ERROR_PROCEDURE());
	PRINT 'An error occurred while performing the operation, which was recorded in the system';

END CATCH;

SELECT * FROM ErrorLog;
SELECT * FROM Employees3;