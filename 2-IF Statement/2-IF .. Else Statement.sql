
-- IF .. Else Statement in T-SQL

DECLARE @Year int;
SET @Year = 1995;

IF @Year >= 2000
   BEGIN
		PRINT '21st century'
	END
ELSE
	BEGIN
		PRINT '20th century or earlier'
	END