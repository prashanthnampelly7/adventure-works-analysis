
-- Create Datebase
CREATE DATABASE AdventureWorks_Project;
USE AdventureWorks_Project;

-- 0. Union of Fact Internet sales and Fact internet sales new
CREATE TABLE sales_combined AS
SELECT * FROM Sales
UNION ALL
SELECT * FROM Sales_New;

-- 1.Lookup the productname from the Product sheet to Sales sheet.

SELECT 
    s.*,
    p.EnglishProductName AS ProductName
FROM 
(
    SELECT * FROM sales
    UNION ALL
    SELECT * FROM sales_new
) AS s
LEFT JOIN product p
ON s.ProductKey = p.ProductKey;

-- 2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.

SELECT 
    s.*,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    p.ListPrice AS UnitPrice
FROM sales s
LEFT JOIN dim_customer c 
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN product p 
    ON s.ProductKey = p.ProductKey;
    
    -- 3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)
/*    A.Year
      B.Monthno
      C.Monthfullname
      D.Quarter(Q1,Q2,Q3,Q4)
      E. YearMonth ( YYYY-MMM)
      F. Weekdayno
      G.Weekdayname
      H.FinancialMOnth
      I. Financial Quarter */

    SELECT
    t.OrderDateKey,
    t.OrderDate,
    YEAR(t.OrderDate) AS Year,
    MONTH(t.OrderDate) AS MonthNo,
    MONTHNAME(t.OrderDate) AS MonthFullName,
    CONCAT('Q', QUARTER(t.OrderDate)) AS QuarterName,
    DATE_FORMAT(t.OrderDate, '%Y-%b') AS YearMonth,
    DAYOFWEEK(t.OrderDate) AS WeekdayNo,
    DAYNAME(t.OrderDate) AS WeekdayName,
    CASE
        WHEN MONTH(t.OrderDate) >= 4 THEN MONTH(t.OrderDate) - 3
        ELSE MONTH(t.OrderDate) + 9
    END AS FinancialMonth,
    CASE
        WHEN MONTH(t.OrderDate) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(t.OrderDate) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(t.OrderDate) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS FinancialQuarter
FROM
(
    SELECT
        OrderDateKey,
        STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate
    FROM sales
) t;

-- 4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)

SELECT 
    OrderQuantity,
    UnitPrice,
    UnitPriceDiscountPct,
    (UnitPrice * OrderQuantity) * (1 - UnitPriceDiscountPct) AS SalesAmount
FROM sales;

-- 5.Calculate the Productioncost uning the columns(unit cost ,order quantity)

SELECT 
    OrderQuantity,
    ProductStandardCost AS UnitCost,
    
    (ProductStandardCost * OrderQuantity) AS ProductionCost
FROM sales;  



    
    