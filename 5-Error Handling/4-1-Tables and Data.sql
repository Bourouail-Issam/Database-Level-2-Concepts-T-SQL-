
use C21_DB1;

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    StockQuantity INT
);

Go

INSERT INTO Products (ProductID, StockQuantity) VALUES (1, 100);
INSERT INTO Products (ProductID, StockQuantity) VALUES (2, 50);
INSERT INTO Products (ProductID, StockQuantity) VALUES (3, 75);
