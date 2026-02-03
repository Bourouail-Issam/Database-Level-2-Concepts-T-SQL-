--IF Statement in T-SQL

DECLARE @A int;
DECLARE @B int;

SET @A = 7;
SET @B = 10;

-- Operators in T-SQL : you can use (>,<,=,!=,>=,<=)
IF @B > @A 
   BEGIN
        PRINT'Yes B is greater than a'
	END