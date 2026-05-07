-- ============================================================
-- Table : Accounts
-- Description: Stores account balances for all registered users
-- ============================================================
CREATE TABLE Accounts (
    AccountID INT            PRIMARY KEY,
    Balance   DECIMAL(10, 2) NOT NULL DEFAULT 0
);

-- ============================================================
-- Table : Transactions
-- Description: Audit log of all fund transfers between accounts
-- ============================================================
CREATE TABLE Transactions (
    TransactionID   INT            PRIMARY KEY IDENTITY(1,1),
    FromAccountID   INT            NOT NULL,
    ToAccountID     INT            NOT NULL,
    TransferAmount  DECIMAL(10, 2) NOT NULL,
    TransactionDate DATETIME       NOT NULL
);

-- ============================================================
-- Procedure   : usp_TransferFunds
-- Description : Transfers a specified amount between two accounts
--               with full validation and atomic transaction handling
-- Parameters  :
--   @TransferAmount    - The amount to transfer (must be > 0)
--   @SenderAccountID   - The account ID to debit
--   @ReceiverAccountID - The account ID to credit
-- Returns     : 1 = Success | 0 = Failure
-- ============================================================
CREATE PROCEDURE usp_TransferFunds
    @TransferAmount    DECIMAL(10, 2),
    @SenderAccountID   INT,
    @ReceiverAccountID INT
AS
BEGIN
    SET NOCOUNT   ON;
    SET XACT_ABORT ON;

    -- --------------------------------------------------------
    -- Section 1: Input Validation
    -- All checks run before any data modification
    -- --------------------------------------------------------
    BEGIN TRY

        IF @TransferAmount IS NULL OR @TransferAmount <= 0
            THROW 51001, '[usp_TransferFunds] Validation failed: Transfer amount must be greater than zero.', 1;

        IF @SenderAccountID = @ReceiverAccountID
            THROW 51002, '[usp_TransferFunds] Validation failed: Sender and Receiver cannot be the same account.', 1;

        IF NOT EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @SenderAccountID)
            THROW 51003, '[usp_TransferFunds] Validation failed: Sender account does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @ReceiverAccountID)
            THROW 51004, '[usp_TransferFunds] Validation failed: Receiver account does not exist.', 1;

        -- --------------------------------------------------------
        -- Section 2: Atomic Fund Transfer
        -- Debit and credit execute as a single unit of work
        -- --------------------------------------------------------
        BEGIN TRANSACTION;

            -- Debit sender — balance check is atomic within the UPDATE
            -- to prevent race conditions in concurrent transactions
            UPDATE Accounts
            SET    Balance = Balance - @TransferAmount
            WHERE  AccountID = @SenderAccountID
              AND  Balance   >= @TransferAmount;

            IF @@ROWCOUNT = 0
                THROW 51005, '[usp_TransferFunds] Transfer failed: Insufficient funds in sender account.', 1;

            -- Credit receiver account with the transferred amount
            UPDATE Accounts
            SET    Balance = Balance + @TransferAmount
            WHERE  AccountID = @ReceiverAccountID;

            IF @@ROWCOUNT = 0
                THROW 51006, '[usp_TransferFunds] Transfer failed: Could not credit receiver account.', 1;

            -- --------------------------------------------------------
            -- Section 3: Audit Log
            -- Record every successful transfer for traceability
            -- --------------------------------------------------------
            INSERT INTO Transactions
                (FromAccountID, ToAccountID, TransferAmount, TransactionDate)
            VALUES
                (@SenderAccountID, @ReceiverAccountID, @TransferAmount, GETDATE());

        COMMIT;
        RETURN 1; -- Success

    END TRY
    BEGIN CATCH

        -- Rollback only if a transaction is still open
        IF @@TRANCOUNT > 0
            ROLLBACK;

        -- Surface the original error for caller or logging
        PRINT ERROR_MESSAGE();
        RETURN 0; -- Failure

    END CATCH
END;

-- ============================================================
-- Usage Example: Execute fund transfer between two accounts
-- ============================================================
DECLARE @Result INT;

EXEC @Result = usp_TransferFunds
    @TransferAmount    = 300,
    @SenderAccountID   = 2,
    @ReceiverAccountID = 1;

IF @Result = 1
    PRINT 'Transfer completed successfully.'
ELSE
    PRINT 'Transfer failed. Please check the error details above.'