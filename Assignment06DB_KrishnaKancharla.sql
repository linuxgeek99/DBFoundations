--*************************************************************************--
-- Title: Assignment06
-- Author: Krishna Kancharla
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-14,Krishna Kancharla,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KrishnaKancharla')
	 Begin 
	  Alter Database [Assignment06DB_KrishnaKancharla] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KrishnaKancharla;
	 End
	Create Database Assignment06DB_KrishnaKancharla;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KrishnaKancharla;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
-- 1) You can use any name you like for you views, but be descriptive and consistent
-- 2) You can use your working code from assignment 5 for much of this assignment
-- 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

---Categories View
CREATE VIEW vCategories
WITH SCHEMABINDING
As
	Select
		   CategoryID, CategoryName
	From   dbo.Categories;
go
--Select * From [dbo].[vCategories]

---Products View
CREATE VIEW vProducts
WITH SCHEMABINDING
As
	Select
		   ProductID, ProductName, CategoryID, UnitPrice
	From   dbo.Products;
go
--Select * From [dbo].[vProducts]

---Employees View
CREATE VIEW vEmployees
WITH SCHEMABINDING
As
	Select
		   EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From   dbo.Employees;
go
--Select * From [dbo].[vEmployees]

---Inventories View
CREATE VIEW vInventories
WITH SCHEMABINDING
As
	Select
		   InventoryID, InventoryDate, EmployeeID, ProductID, Count
	From   dbo.Inventories;
go
--Select * From [dbo].[vInventories]


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Denied accees to public for all 4 tables
Deny Select on Categories  to Public;
Deny Select on Products to Public;
Deny Select on Employees to Public;
Deny Select on Inventories to Public;

--Grant access to public for all 4 views
Grant Select on vCategories to Public;
Grant Select on vProducts to Public;
Grant Select on vEmployees to Public;
Grant Select on vInventories to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

CREATE VIEW vProductsByCategories
As
	Select  Top 10000
			c.CategoryName,
			p.ProductName,
			p.UnitPrice
	From
			Categories c
			join Products p
			on c.CategoryID = p.CategoryID
	Order By CategoryName asc, ProductName asc;
go
--Select * From [dbo].[vProductsByCategories]

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

--DROP VIEW IF EXISTS DBO.vInventoriesByProductsByDates;
CREATE VIEW vInventoriesByProductsByDates
As
	Select	Top 10000
			p.ProductName,
			i.InventoryDate,
			i.Count
	From
			Products p
			join Inventories i
			on p.ProductID = i.ProductID
	Order By ProductName, InventoryDate, Count;
go
--Select * From [dbo].[vInventoriesByProductsByDates]

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDates
As
	Select  
			distinct i.InventoryDate,
		    concat(e.EmployeeFirstName, ' ' , e.EmployeeLastName) AS EmployeeName
	From
			Inventories i
			join Employees e
			on i.EmployeeID = e.EmployeeID
	--Order By InventoryDate; 
	--Comments - Removed order by clause as I need to add top 10000 in select statement and adding top 10000 throws errors as invalid sytanx error with distinct function
	--plus the results are displayed in the same order with and without order by clause.
go
--Select * From [dbo].[vInventoriesByEmployeesByDates]

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

CREATE VIEW vInventoriesByProductsByCategories
As
	Select	Top 10000
			c.CategoryName,
			p.ProductName,
			i.InventoryDate,
			i.count
	From
			Categories c
			join Products p
			on c.CategoryID = p.CategoryID
			join Inventories i
			on p.ProductID = i.ProductID
	Order By CategoryName, ProductName, InventoryDate, Count;
go
--Select * From [dbo].[vInventoriesByProductsByCategories]


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

CREATE VIEW vInventoriesByProductsByEmployees
As
	Select	Top 10000
			c.CategoryName,
			p.ProductName,
			i.InventoryDate,
			i.count,
			concat(e.EmployeeFirstName, ' ' , e.EmployeeLastName) AS EmployeeName
	From
			Categories c
			join Products p
			on c.CategoryID = p.CategoryID
			join Inventories i
			on p.ProductID = i.ProductID
			join Employees e
			on e.EmployeeID = i.EmployeeID
	Order By InventoryDate, CategoryName, ProductName, EmployeeName;
go
--Select * From [dbo].[vInventoriesByProductsByEmployees]


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

CREATE VIEW vInventoriesForChaiAndChangByEmployees
As
	Select	Top 10000
			c.CategoryName,
			p.ProductName,
			i.InventoryDate,
			i.count,
			concat(e.EmployeeFirstName, ' ' , e.EmployeeLastName) AS EmployeeName
	From
			Categories c
			join Products p
			on c.CategoryID = p.CategoryID
			join Inventories i
			on p.ProductID = i.ProductID
			join Employees e
			on e.EmployeeID = i.EmployeeID
	Where   p.ProductName  in (Select ProductName from Products where ProductName in ('Chai', 'Chang')) 
	Order By InventoryDate, CategoryName, ProductName;
go
--Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

CREATE VIEW vEmployeesByManager
As
	Select	Top 10000
			concat(m.EmployeeFirstName, ' ' , m.EmployeeLastName) AS Manager,
			concat(e.EmployeeFirstName, ' ' , e.EmployeeLastName) AS Employee
	From
			Employees e
			inner join Employees m
			on m.EmployeeID = e.ManagerID
	Order By Manager, Employee;
go
--Select * from [dbo].[vEmployeesByManager];


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,         Manager
-- 1,			Beverages,		1,		Chai,		18.00,		1,      2017-01-01,   72,      5,      Steven Buchanan, Andrew Fuller
-- 1,			Beverages,		1,		Chai,		18.00,     78,      2017-02-01,   52,      7,      Robert King,     Steven Buchanan
-- 1,			Beverages,		1,		Chai,		18.00,     155,    2017-03-01,    54,      9,      Anne Dodsworth,  Steven Buchanan

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
As
Select		Top 10000
			c.CategoryID, c.CategoryName,
			p.ProductID, p.ProductName, p.UnitPrice,
			i.InventoryID, i.InventoryDate, i.Count,
			e.EmployeeID, concat(e.EmployeeFirstName, ' ' , e.EmployeeLastName) AS Employee, concat(m.EmployeeFirstName, ' ' , m.EmployeeLastName) AS Manager
From		vCategories c
Join		vProducts p on c.CategoryID = p.CategoryID
Join		vInventories i on i.ProductID = p.ProductID
Join		vEmployees e on e.EmployeeID = I.EmployeeID
Inner Join  Employees m
			on m.EmployeeID = e.ManagerID
Order by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;
go
--Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]






