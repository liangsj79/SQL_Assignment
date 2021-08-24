/*
1.What is View? What are the benefits of using views?
   A view is a virtual table based on the result-set of an SQL statement.
2.Can data be modified through views?
	No.
3.What is stored procedure and what are the benefits of using it?
	A store procedure is a prepared SQL code that you can save, so the code can be reused over and over again. 
4.What is the difference between view and stored procedure?
	A view is a stored SELECT statement, and a stored procedure is one or more Transact-SQL statements that execute as a batch. 
5.What is the difference between stored procedure and functions?
	A  function must return a value, but a stored procedure does not. 
	A function can have only input parameters while a procedure can hav input or output parameters. 
6.Can stored procedure return multiple result sets?
	Yes. 
7.Can stored procedure be executed as part of SELECT Statement? Why?
	NO.
8.What is Trigger? What types of Triggers are there?
	A trigger is a special type of stored procedure that automatically runs when an event occurs in the database server.
	 DML, DDL, or logon trigger. 
9.What are the scenarios to use Triggers?
	Triggers can be used to automatically execute scripts after an event is triggered.
10.What is the difference between Trigger and Stored Procedure?
	Trigger is invoked explicitly by the user while stored procedure is executed automatically based on the event. 
*/

SELECT *
FROM Region

SELECT *
FROM Territories

SELECT * 
FROM EmployeeTerritories

SELECT * FROM Employees
--1
BEGIN TRAN
INSERT INTO Region VALUES (5,'Middle Earth')
INSERT INTO Territories VALUES(65954, 'Gondor', 5)

INSERT INTO Employees 
SELECT 'King', 'Aragorn',Title,TitleOfCourtesy, BirthDate,HireDate,Address,City,Region,PostalCode,Country,HomePhone,Extension,Photo,Notes,ReportsTo,PhotoPath
FROM Employees
WHERE EmployeeID = 9
INSERT INTO EmployeeTerritories VALUES(13,65954)

IF @@ERROR <> 0 
	ROLLBACK
COMMIT 

--2
UPDATE Territories
SET TerritoryDescription = 'Arnor'
WHERE TerritoryDescription ='Gondor'

--3
BEGIN TRAN
DELETE 
FROM EmployeeTerritories
WHERE EmployeeID = 13

DELETE 
FROM Territories 
WHERE TerritoryID = 65954

DELETE 
FROM Region
WHERE RegionID = 5
COMMIT

SELECT * FROM Products
--4
CREATE VIEW view_product_order_Liang AS
SELECT p.ProductName, sum(od.Quantity) AS TotalOrderQuantity
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID 
GROUP BY p.ProductName

SELECT * FROM view_product_order_Liang

--5
CREATE PROCEDURE sp_product_order_quantity_liang
	@product_name nvarchar(50),
	@total_quantity int OUTPUT
AS
SELECT  @total_quantity = sum(od.Quantity)
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID 
WHERE p.ProductName = @product_name
GROUP BY p.ProductName

DECLARE @total_quantity INT
EXEC sp_product_order_quantity_liang 'chai' , @total_quantity OUTPUT
SELECT @total_quantity

--6
CREATE PROCEDURE sp_product_order_city_liang
	@product_id nvarchar(50),
	@top_5_cities nvarchar(500) OUTPUT
AS
SELECT TOP 5 @top_5_cities = COALESCE(@top_5_cities + ',', '') + CAST(o.ShipCity AS VARCHAR(5))
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE p.ProductID  = @product_id
GROUP BY p.ProductID,o.ShipCity
ORDER BY sum(od.Quantity) DESC

DECLARE @top_5_cities nvarchar(500)
EXEC sp_product_order_city_liang 1 , @top_5_cities OUTPUT
SELECT @top_5_cities


SELECT value AS City FROM STRING_SPLIT(@top_5_cities, ',')

--7
CREATE PROCEDURE sp_move_employees_liang 
AS 
BEGIN 
	DECLARE @NumberOfEmployee int

	SET @NumberOfEmployee = (
	SELECT COUNT(EmployeeID) 
	FROM EmployeeTerritories et 
	JOIN Territories t on et.TerritoryID = t.TerritoryID
	WHERE t.TerritoryDescription = 'Troy')
	IF (@NumberOfEmployee > 0)
		INSERT INTO Territories VALUES (95984,'Stevens Point', 3)
		UPDATE EmployeeTerritories
		SET TerritoryID = 95984
		WHERE EmployeeID IN (
		SELECT et.EmployeeID
		FROM EmployeeTerritories et 
		JOIN Territories t on et.TerritoryID = t.TerritoryID
		WHERE t.TerritoryDescription = 'Troy') 
		AND TerritoryID = 
		(SELECT TerritoryID
		FROM Territories
		WHERE TerritoryDescription = 'Troy') 
END

EXEC sp_move_employees_liang 

--8
CREATE TRIGGER tgr_MoveToTroy 
ON EmployeeTerritories
AFTER INSERT AS
BEGIN
	DECLARE @NumberOfEmployee int

	SET @NumberOfEmployee = (
	SELECT COUNT(EmployeeID) 
	FROM EmployeeTerritories et 
	JOIN Territories t on et.TerritoryID = t.TerritoryID
	WHERE t.TerritoryDescription = 'Stevens Point')
	IF (@NumberOfEmployee > 100)
		UPDATE EmployeeTerritories
		SET TerritoryID = 48084
		WHERE EmployeeID IN (
		SELECT et.EmployeeID
		FROM EmployeeTerritories et 
		JOIN Territories t on et.TerritoryID = t.TerritoryID
		WHERE t.TerritoryDescription = 'Stevens Point') 
		AND TerritoryID = 
		(SELECT TerritoryID
		FROM Territories
		WHERE TerritoryDescription = 'Stevens Point') 
END

--9
CREATE TABLE people_liang
(Id int PRIMARY KEY IDENTITY(1,1), Name VARCHAR(50), City int)
CREATE TABLE city_liang
(Id int PRIMARY KEY IDENTITY(1,1), City VARCHAR(50))

SELECT * FROM people_liang
SELECT * FROM city_liang
INSERT INTO people_liang VALUES( 'Aaron Rodgers', 2), ('Russel Wilson', 1), ('Jody Nelson', 2)
INSERT INTO city_liang VALUES('Seattle'),('Green Bay')
INSERT INTO city_liang VALUES('Madison')
INSERT INTO people_liang VALUES('Russel Wilson', 3)

DELETE FROM people_liang 
WHERE City = 1
DELETE FROM city_liang 
WHERE City = 'Seattle'
ALTER TABLE people_liang
ADD FOREIGN KEY (City) REFERENCES city_liang(Id)


CREATE VIEW Packers_liang
AS
SELECT p.*
FROM people_liang p
JOIN city_liang c ON p.City = c.Id
WHERE c.City = 'Green Bay'

DROP VIEW Packers_liang
DROP TABLE people_liang
DROP TABLE city_liang

--10
CREATE PROCEDURE sp_birthday_employees_liang
AS
BEGIN
	SELECT * INTO birthday_employees_liang
	FROM Employees
	WHERE MONTH(BirthDate) = 2 
END

EXEC sp_birthday_employees_liang
SELECT * FROM birthday_employees_liang
DROP PROCEDURE sp_birthday_employees_liang
DROP TABLE birthday_employees_liang

--11
CREATE PROCEDURE sp_liang_1
AS
BEGIN
	SELECT dt.City, SUM(dt.CustomerCount) AS TotalCustomerCount
	FROM
	(
	SELECT c.City, COUNT(c.CustomerID) AS CustomerCount
	FROM Customers c
	LEFT JOIN Orders o on c.CustomerID = o.CustomerID
	WHERE o.CustomerID IS NULL
	GROUP BY c.City
	UNION ALL
	SELECT c.city, COUNT(o.CustomerID)
	FROM Orders o
	JOIN Customers c ON o.CustomerID = c.CustomerID
	GROUP BY c.city, o.CustomerID
	HAVING COUNT(o.OrderID) = 1
	) dt
	GROUP BY dt.City
	HAVING SUM(dt.CustomerCount) > 2
END

CREATE PROCEDURE sp_liang_2
AS
BEGIN
	SELECT dt.City, SUM(dt.CustomerCount) AS TotalCustomerCount
	FROM
	(
	SELECT City, COUNT(CustomerID) AS CustomerCount
	FROM Customers 
	WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders)
	GROUP BY City
	UNION ALL
	SELECT c.City, (SELECT COUNT(o.OrderID) FROM Orders o WHERE o.CustomerID = c.CustomerID) AS CustomerCount
	FROM Customers c
	WHERE (SELECT COUNT(o.OrderID) FROM Orders o WHERE o.CustomerID = c.CustomerID) = 1
	) dt
	GROUP BY dt.City
	HAVING SUM(dt.CustomerCount) > 2
	
END
SELECT * FROM Customers
SELECT * FROM [Order Details]
SELECT * FROM Orders


--12
SELECT * FROM TABLEA
MINUS
SELECT * FROM TABLEB

--14
SELECT [First Name] + ' ' + [Last Name] + IFF([Middle Name] = '','',[Middle Name] + '.') AS 'Full Name'
FROM TABLEA


--15
SELECT MAX(Marks)
FROM Students
WHERE Sex = 'F'

SELECT TOP 1 
FROM Students 
WHERE Marks = Max(Marks)

--16

SELECT Student, Marks, SEX
FROM Students
ORDER BY 2,3