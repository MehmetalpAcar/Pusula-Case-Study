--NOT: Case ingilizce oldu�undan dolay� tablolar� ve s�tunlar� �ngilizce dilinde olu�turdum.

--1.Ad�m: Ma�aza veri taban�n� 'Create Database' komutu ile olu�turuyorum.
CREATE DATABASE ShopDB
GO

--2.Ad�m: Olu�turdu�um veri taban�na ba�lan�yorum.
USE ShopDB
GO

--3.Ad�m: Products tablosunu olu�turup i�erisindeki field'lar� ve �zelliklerini belirtiyorum.
CREATE TABLE Products(
	ProductID INT PRIMARY KEY,
	ProductName NVARCHAR(100) NOT NULL,
	Price DECIMAL(10,2) NOT NULL
)
GO

--4.Ad�m: Sales tablosunu olu�turup ayn� �ekilde i�erisindeki field'lar� ve �zelliklerini belirtiyorum.Burada ayr�ca 'Foreign Key' tan�m� yap�yorum.
CREATE TABLE Sales(
	SaleID INT PRIMARY KEY,
	ProductID INT,
	Quantity INT NOT NULL,
	SaleDate DATE NOT NULL,
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
)
GO


--5.Ad�m: 'Products' tablosuna belirtilen verileri giriyorum.
INSERT INTO Products
(ProductID,ProductName,Price)
VALUES
(1,'Laptop',1500.00),
(2,'Mouse',25.00),
(3,'Keyboard',45.00)
GO

--6.Ad�m: 'Sales' tablosuna di�erinden farkl� olarak field alanlar�n� belirtmeden verileri giriyorum.
INSERT INTO Sales 
VALUES 
(1,1,2,'2024-01-10'),
(2,2,5,'2024-01-15'),
(3,1,1,'2024-02-20'),
(4,3,3, '2024-03-05'),
(5,2,7, '2024-03-25'),
(6,3,2, '2024-04-12')
GO



--7.Ad�m: �stenen analizleri olu�turuyorum.
	--�r�n baz�nda y�ll�k toplam sat�� miktar� ve y�ll�k toplam sat�� tutar�:
SELECT 
    p.ProductName, 
    YEAR(s.SaleDate) AS Year, 
    SUM(s.Quantity) AS TotalQuantity,
	SUM(p.Price * Quantity) AS TotalPrice
FROM 
    Products p
JOIN 
    Sales s ON p.ProductID = s.ProductID
GROUP BY 
    p.ProductName, YEAR(s.SaleDate)
ORDER BY 
    p.ProductName, Year

	-- En y�ksek toplam sat�� tutar�na sahip �r�n� bulma:
SELECT 
   TOP 1
   p.ProductName, 
   SUM(s.Quantity * p.Price) AS TotalSales
FROM 
    Products p
JOIN 
    Sales s ON p.ProductID = s.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    TotalSales DESC



--EXTRA
--�stenilen analizler �ok s�k kullan�lan analizler oldu�u i�in 'Ad Hoc Query' �eklinde sorgulamak yerine,
--'Stored Procedures' olarak �nceden tan�mlanm�� ve optimize edilmi� �ekilde sorgulamak bize performans ve bak�m avantaj� sunar.
--Ayr�ca bizi SQL Injection gibi g�venlik a��klar�na kar�� korur.

CREATE PROC GetAnnualSalesSummary
AS
BEGIN
	SELECT 
		p.ProductName, 
		YEAR(s.SaleDate) AS Year, 
		SUM(s.Quantity) AS TotalQuantity,
		SUM(p.Price * Quantity) AS TotalPrice
	FROM 
		Products p
	JOIN 
		Sales s ON p.ProductID = s.ProductID
	GROUP BY 
		p.ProductName, YEAR(s.SaleDate)
	ORDER BY 
		p.ProductName, Year
END

EXEC GetAnnualSalesSummary

CREATE PROC GetTopSellingProduct
AS
BEGIN
	SELECT 
	   TOP 1
	   p.ProductName, 
	   SUM(s.Quantity * p.Price) AS TotalSales
	FROM 
		Products p
	JOIN 
		Sales s ON p.ProductID = s.ProductID
	GROUP BY 
		p.ProductName
	ORDER BY 
		TotalSales DESC
END

EXEC GetTopSellingProduct