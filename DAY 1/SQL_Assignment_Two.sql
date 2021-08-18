
/*
1.What is a result set?
	A result set are records generated after executing SQL queries. 
2.What is the difference between Union and Union All?
	Union sorts and remove duplicate records while Union ALL keeps all duplicate records.
3.What are the other Set Operators SQL Server has?
	MINUS, INTERSECT
4.What is the difference between Union and Join?
	UNION requires both tables have the same columns while JOIN does not. 	UNION 	is used to combine rows while JOIN is used to combine columns.
5.What is the difference between INNER JOIN and FULL JOIN?
	INNER JOIN outputs rows that both tables have in common while FULL JOIN outputs 	every rows in both tables. 
6.What is difference between left join and outer join
	LEFT JOIN outputs rows all rows in the left table and the associated rows in the right 	tables while outer join outputs every row in both tables. 
7.What is cross join?
CROSS JOIN outputs the Cartesian product of records from tables.
8.What is the difference between WHERE clause and HAVING clause?
	WHERE is executed earlier than HAVING.  WHERE is used to filter records before 	aggregation while HAVING is used to filter records after aggregation. 
9.Can there be multiple group by columns?
	Yes.
*/

Use AdventureWorks2019
GO

--1
SELECT COUNT(*) AS COUNT 
FROM Production.Product

--2
SELECT COUNT(ProductSubcategoryID)
FROM Production.Product

--3
SELECT ProductSubcategoryID, COUNT(*) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID 

--4
SELECT COUNT(*)  AS ProductCount
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

--5
SELECT SUM(Quantity) AS SumQuantity
FROM Production.ProductInventory

--6
SELECT  ProductID, SUM(Quantity)  AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity)  <   100

--7
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100

--8
SELECT ProductID, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE LocationID = 10
GROUP BY ProductID

--9
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
	GROUP BY ProductID, Shelf

--10
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf != 'N/A'
GROUP BY ProductID, Shelf

--11
SELECT Color, Class, COUNT(*) AS TheCount, Avg(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

--12
SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c
JOIN person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode

--13
SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c
JOIN person.StateProvince s
ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name in ('Germany', 'Canada')

USE Northwind
GO

--14
SELECT p.ProductID, count(od.OrderID) AS NumOrders
FROM Products p
JOIN [Order Details]  od ON p.ProductID = od.ProductID
JOIN Orders o on od. OrderID = o.OrderID
WHERE YEAR(GETDATE()) - YEAR(o.OrderDate) <= 25
GROUP BY p.ProductID
HAVING count(od.OrderID) > 0
ORDER BY 2 DESC

--15
SELECT TOP 5 ShipPostalCode, Count(OrderID) AS NumOrders
FROM Orders
WHERE ShipPostalCode IS NOT NULL
GROUP BY ShipPostalCode
ORDER BY Count(OrderID) DESC

--16
SELECT TOP 5 ShipPostalCode, Count(OrderID) AS NumOrders
FROM Orders
WHERE ShipPostalCode IS NOT NULL AND YEAR(GETDATE()) - YEAR(OrderDate) <= 25
GROUP BY ShipPostalCode
ORDER BY Count(OrderID) DESC

--17
SELECT City, COUNT(CustomerID) AS NumCustomers
FROM Customers
GROUP BY City
ORDER BY 2 DESC

--18
SELECT City, COUNT(CustomerID) AS NumCustomers
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2
ORDER BY 2 DESC

--19
SELECT  c.CompanyName, o.OrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID 
WHERE o.OrderDate  > '1998-01-01'

--20
SELECT c.CompanyName, Max(o.OrderDate)
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName
ORDER BY 2 DESC	

--21
SELECT c.CompanyName, COUNT(od.ProductID) AS ProductQuantityBought
FROM Customers c
JOIN Orders o on c.CustomerID = o.CustomerID
JOIN [Order Details] od on o.OrderID = od.OrderID
GROUP BY c.CompanyName
ORDER BY 2 DESC

--22
SELECT c.CustomerID, COUNT(od.ProductID) AS ProductQuantityBought
FROM Customers c
JOIN Orders o on c.CustomerID = o.CustomerID
JOIN [Order Details] od on o.OrderID = od.OrderID
GROUP BY c.CustomerID
HAVING COUNT(od.ProductID) > 100
ORDER BY 2 DESC

--23
SELECT su.CompanyName AS 'Supplier Company Name' , sh.CompanyName AS 'Shipping 	Company Name'
FROM Suppliers su
CROSS JOIN Shippers sh

--24
SELECT o.OrderDate, p.ProductName
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON p.ProductID = od.ProductID
ORDER BY 1

--25
SELECT e.FirstName +' ' + e.LastName AS FirstEmployeeName, 
c.FirstName + ' ' + c.LastName AS SecondEmployeeName, e.Title
FROM Employees e
JOIN Employees c ON e.Title = c.Title
WHERE e.EmployeeID > c.EmployeeID

--26
SELECT m.FirstName +' ' + m.LastName AS ManagerName, COUNT(e.EmployeeID) AS 	NumReporting
FROM Employees m
JOIN Employees e ON m.EmployeeID = e.ReportsTo
GROUP BY m.FirstName +' ' + m.LastName
HAVING COUNT(e.EmployeeID) > 2

--27
SELECT City, CompanyName, ContactName, 'Customer' AS Type
FROM Customers 
UNION 
SELECT CITY, CompanyName, ContactName, 'Supplier' AS Type
FROM Suppliers
ORDER BY 4

--28
SELECT t1.F1,t2.F2
FROM T1 t1
INNER JOIN T2 t2 ON t1.F1= t2.F2

/*
----------------
| F1.T1 | F2.T2|
----------------
|  2    |  2   |
----------------
*/

--29
SELECT t1.F1, t2.F2
FROM T1 t1
LEFT JOIN t2.F2 ON t1.F1 = t2.F2

/*
----------------
| F1.T1 | F2.T2|
----------------
|  1    | NULL |
----------------
|  2    |  2   |
----------------
|  3    | NULL |
----------------
*/




