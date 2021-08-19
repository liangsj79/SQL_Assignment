/*
1.In SQL Server, assuming you can find the result by using both joins and subqueries, which one would you prefer to use and why?
	Joins. Joins have better performance than subqueries.
2.What is CTE and when to use it?
	A CTE is a temporary result set. A CTE is used to simpify queries. 
3.What are Table Variables? What is their scope and where are they created in SQL Server?
	Table variables are a special data type that can be used to store temporary data similar to a temporary table.
The table variable scope is within the batch. Table variables are stored in tempdb database.
4.What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
	DELETE is a DML command while TRUNCATE is a DDL command.Unlike DELETE that comes with a WHERE clause to remove speicified rows,
	TRUNCATE does not come with a WHERE clause, and TRUNCATE deletes complete data from an exisiting data. TRUNCATE has a better performance
	because DELETE needs to search and look for specific records.
5.What is Identity column? How does DELETE and TRUNCATE affect it?
	Identity column is a column that is used to generate key values based on provided seed and increment. Delete retains the identity and does
	not reset it to the seed value while TRUNCATE reset the identity to its seed value.
6.What is difference between “delete from table_name” and “truncate table table_name”?
	"Delete from table_name" remove rows matched with the where clause while "truncate table table_name" remove all rows of a table. 
*/

USE Northwind
GO

--1
SELECT DISTINCT City
FROM Employees
WHERE City IN 
(SELECT City
FROM Customers)

--2
SELECT DISTINCT City
FROM Customers
WHERE CITY NOT IN 
(SELECT City
FROM Employees)

SELECT DISTINCT c.City
FROM Customers c
LEFT JOIN Employees e
ON c.City = e.City
WHERE e.City IS NULL 

--3
SELECT p.ProductID, p.ProductName,
(SELECT SUM(Quantity) 
FROM [Order Details] od
WHERE od.ProductID = p.ProductID) AS TotalOrderQuantity
FROM Products p
ORDER BY 3 DESC

--4
SELECT DISTINCT c.City, A.TotalProductNumber
FROM Customers c
LEFT JOIN(
SELECT o.ShipCity AS City, COUNT(od.ProductID) AS TotalProductNumber
FROM [Order Details] od
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY o.ShipCity
) a ON a.City = c.City

--5
SELECT City, COUNT(CustomerID) AS NumberCustomer
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >= 2
UNION
SELECT City, COUNT(CustomerID) AS NumberCustomer
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) = 2

SELECT DISTINCT City
FROM Customers
WHERE City IN ( SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >= 2)



--6
SELECT DISTINCT c.City, A.TotalProductNumber
FROM Customers c
JOIN(
SELECT o.ShipCity AS City, COUNT(od.ProductID) AS TotalProductNumber
FROM [Order Details] od
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY o.ShipCity
HAVING COUNT(od.ProductID) >=2
) a ON a.City = c.City

--7
SELECT DISTINCT c.ContactName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City != o.ShipCity
ORDER BY 1

--8 
SELECT dt.ProductID,dt.QuantitySold, dt.RNK, dt.AvgPrice, dt2.ShipCity
FROM 
(SELECT ProductID, SUM(Quantity) AS QuantitySold,RANK() OVER (ORDER BY SUM(Quantity) DESC) RNK, SUM(UnitPrice*Quantity)/SUM(Quantity) AS AvgPrice
FROM [Order Details] 
GROUP BY ProductID) dt 
JOIN 
(SELECT od.ProductID AS ProductID,  o.ShipCity AS ShipCity, RANK() OVER (PARTITION BY od.ProductID Order BY SUM(od.Quantity) DESC) RNK
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY od.ProductID, o.ShipCity ) dt2 ON dt.ProductID = dt2.ProductID
WHERE dt.RNK <=5 and dt2.RNK = 1
ORDER BY dt.RNK

--9
--a
SELECT City
FROM Employees
WHERE City NOT IN 
(SELECT ShipCity
FROM Orders)
--b
SELECT City
FROM Employees e
LEFT JOIN Orders o
ON e.city = o.ShipCity
WHERE o.ShipCity IS NULL

--10
SELECT ShipCity,NumberOfOrder, RNK
FROM 
(SELECT ShipCity, COUNT(OrderID) AS NumberOfOrder, RANK() OVER (ORDER BY COUNT(OrderID) DESC) RNK
FROM Orders
GROUP BY ShipCity
) dt
WHERE RNK = 1

SELECT ShipCity,TotalQuantity, RNK
FROM 
(SELECT  o.ShipCity AS ShipCity, SUM(od.Quantity) AS TotalQuantity , RANK() OVER (ORDER BY SUM(od.Quantity) DESC) RNK
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.ShipCity
) dt
WHERE RNK = 1


--11
/*
WITH CTE AS
(
SELECT *,ROW_NUMBER() OVER (PARTITION BY col1,col2,col3 ORDER BY col1,col2,col3) AS RN
FROM MyTable
)
DELETE FROM CTE WHERE RN!=1
*/

--12
/*
SELECT empid
FROM Employee
WHERE empid NOT IN 
(SELECT mgrid
FROM Employee)
*/

--13
/*
SELECT d.deptname, EmployeeCOUNT
FROM (
SELECT deptid, COUNT(empid) AS EmployeeCount, , RANK() OVER (ORDER BY COUNT(empid) DESC) AS RNK
FROM Employee
GROUP BY deptid
) dt
JOIN Dept d on dt.deptid = d.deptid
WHERE RNK = 1
ORDER BY deptname

*/

--14
/*

SELECT d.deptname, dt.empid
FROM (
SELECT deptid, empid, RANK() OVER(PARTITION BY deptid ORDER BY salary DESC) RNK
FROM Employee
GROUP BY deptid, empid
) dt
JOIN Dept d on dt.deptid = d.deptid
WHERE RNK >=3
ORDER BY deptname
*/

SELECT * FROM Customers
SELECT * FROM Orders
SELECT * FROM [Order Details] ORDER BY ProductID
SELECT * FROM Employees

SELECT City, Count(CustomerID), RANK() OVER ( ORDER BY COUNT(CustomerID)DESC) RNK
FROM Customers
GROUP BY City