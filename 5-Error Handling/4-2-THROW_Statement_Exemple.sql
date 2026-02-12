 
 declare @NewStockQty INT;

  SET @NewStockQty = 0;
  -- Start a TRY block
  BEGIN TRY

	-- Check if NewStockQty is negative
	IF @NewStockQty < 0
		THROW 51000,'Stock quantity cannot be negative.',1;

	BEGIN TRANSACTION;

	    -- Proceed with updating stock (example code)
        UPDATE Products 
        SET StockQuantity = @NewStockQty 
        WHERE ProductID = 1;

    COMMIT TRANSACTION;
  
  END TRY
  BEGIN CATCH

	IF XACT_STATE() <> 0
	  ROLLBACK TRANSACTION;

	-- Start a CATCH block to handle the error
	   INSERT INTO ErrorLog
    (
        ErrorNumber,
        ErrorMessage,
        ErrorSeverity,
        ErrorState,
        ErrorLine,
        ErrorProcedure
    )
    VALUES
    (
        ERROR_NUMBER(),
        ERROR_MESSAGE(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_LINE(),
        ERROR_PROCEDURE()
    );	

	SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    THROW;

  END CATCH;

  SELECT * FROM ErrorLog;
  SELECT * FROM Products;