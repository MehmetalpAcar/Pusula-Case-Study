--NOT: Case ingilizce olduðundan dolayý tablolarý ve sütunlarý Ýngilizce dilinde oluþturdum.

--1.Adým: Maðaza veri tabanýný 'Create Database' komutu ile oluþturuyorum.
CREATE DATABASE ShopDB
GO

--2.Adým: Oluþturduðum veri tabanýna baðlanýyorum.
USE ShopDB
GO

--3.Adým: Products tablosunu oluþturup içerisindeki field'larý ve özelliklerini belirtiyorum.
CREATE TABLE Products(
	ProductID INT PRIMARY KEY,
	ProductName NVARCHAR(100) NOT NULL,
	Price DECIMAL(10,2) NOT NULL
)
GO

--4.Adým: Sales tablosunu oluþturup ayný þekilde içerisindeki field'larý ve özelliklerini belirtiyorum.Burada ayrýca 'Foreign Key' tanýmý yapýyorum.
CREATE TABLE Sales(
	SaleID INT PRIMARY KEY,
	ProductID INT,
	Quantity INT NOT NULL,
	SaleDate DATE NOT NULL,
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
)
GO


--5.Adým: 'Products' tablosuna belirtilen verileri giriyorum.
INSERT INTO Products
(ProductID,ProductName,Price)
VALUES
(1,'Laptop',1500.00),
(2,'Mouse',25.00),
(3,'Keyboard',45.00)
GO

--6.Adým: 'Sales' tablosuna diðerinden farklý olarak field alanlarýný belirtmeden verileri giriyorum.
INSERT INTO Sales 
VALUES 
(1,1,2,'2024-01-10'),
(2,2,5,'2024-01-15'),
(3,1,1,'2024-02-20'),
(4,3,3, '2024-03-05'),
(5,2,7, '2024-03-25'),
(6,3,2, '2024-04-12')
GO



--7.Adým: Ýstenen analizleri oluþturuyorum.
	--Ürün bazýnda yýllýk toplam satýþ miktarý ve yýllýk toplam satýþ tutarý:
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

	-- En yüksek toplam satýþ tutarýna sahip ürünü bulma:
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
--Ýstenilen analizler çok sýk kullanýlan analizler olduðu için 'Ad Hoc Query' þeklinde sorgulamak yerine,
--'Stored Procedures' olarak önceden tanýmlanmýþ ve optimize edilmiþ þekilde sorgulamak bize performans ve bakým avantajý sunar.
--Ayrýca bizi SQL Injection gibi güvenlik açýklarýna karþý korur.

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