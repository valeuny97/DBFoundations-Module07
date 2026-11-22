--*************************************************************************--
-- Title: Assignment07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2026-11-20,ValerieIjai,Modified File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_ValerieIjai')
	 Begin 
	  Alter Database [Assignment07DB_ValerieIjai] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_ValerieIjai;
	 End
	Create Database Assignment07DB_ValerieIjai;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_ValerieIjai;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- Data comes from the Products view: columns ProductName and UnitPrice
-- Start with simple select statement to show these two columns
Select ProductName, UnitPrice
From vProducts;
go
-- The next easiest thing to tackle is ordering by Product
Select ProductName, UnitPrice
From vProducts
Order By ProductName;
go
-- Now the only thing missing is to format UnitPrice as US currency
-- FORMAT w/ country code works best here
Select ProductName, 
	Format (UnitPrice, 'C', 'en-US') as UnitPrice -- need to add column alias
From vProducts
Order By ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- Requires a join since we're working with three columns (CategoryName, ProductName, UnitPrice)
-- from two views: Categories and Products
Select CategoryName, ProductName, UnitPrice
From vProducts
Inner Join vCategories
	On vProducts.CategoryID = vCategories.CategoryID;
go
-- Next, add the function
Select CategoryName, 
	ProductName, 
	Format (UnitPrice, 'C', 'en-US') as UnitPrice
From vProducts
Inner Join vCategories
	On vProducts.CategoryID = vCategories.CategoryID;
go
-- Finally, order results by Category and Product
Select CategoryName, 
	ProductName, 
	Format (UnitPrice, 'C', 'en-US') as UnitPrice
From vProducts
Inner Join vCategories
	On vProducts.CategoryID = vCategories.CategoryID
Order By CategoryName, ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- working with two views Products and Inventories so start with a join 
Select ProductName, InventoryDate, [Count]
From vProducts
Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID;
go
-- Next, format the date to show 'January, 2017'
Select ProductName, 
Format (InventoryDate, 'MMMM, yyyy') as InventoryDate, 
[Count] as InventoryCount
From vProducts
Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID;
go
-- Finally, order results by Product and Date
-- Need to order by original date otherwise February could come before January
Select ProductName, 
Format (InventoryDate, 'MMMM, yyyy') as InventoryDate, 
[Count] as InventoryCount
From vProducts
Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID
Order By ProductName, vInventories.InventoryDate;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- reusing the code from q3 so start with the final product minus order by
-- because order by operates under differemt rules when working with views
Select ProductName, 
Format (InventoryDate, 'MMMM, yyyy') as InventoryDate, 
[Count] as InventoryCount
From vProducts
Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID;
go
-- Then create the view itself
Create View vProductInventories
As 
Select ProductName, 
Format (InventoryDate, 'MMMM, yyyy') as InventoryDate, 
[Count] as InventoryCount
From vProducts
Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID;
go
-- but my view has the new inventoryDate saved so if i used that in the Order By
-- it will order in alphabetic order and not chronologically
-- Check that it works but use Cast to convert InventoryDate
-- back to a date for chronological sorting:
Select * 
From vProductInventories
Order By ProductName,
	Cast('1 ' + InventoryDate As date);
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- The first step us to identify the columns needed: CategoryName, InventoryDate, and Count
-- Categories and Inventories don't share a common column so need to use Products as a bridge
Select CategoryName, InventoryDate, [Count]
From vCategories
Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
Inner Join vInventories
	On vInventories.ProductID = vProducts.ProductID;
go
-- but dates appear multiple times so will need to add all the different counts for each date
Select CategoryName, 
	InventoryDate, 
	SUM([Count]) as InventoryCountByCategory
From vCategories
Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
Inner Join vInventories
	On vInventories.ProductID = vProducts.ProductID
Group By CategoryName, InventoryDate;
go 
-- Format inventoryDate as 'January, 2017'
Select CategoryName, 
	Format (InventoryDate, 'MMMM, yyyy') as InventoryDate,  
	SUM([Count]) as InventoryCountByCategory
From vCategories
Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
Inner Join vInventories
	On vInventories.ProductID = vProducts.ProductID
Group By CategoryName, InventoryDate;
go 
-- Finally create the view
Create View vCategoryInventories
As
Select CategoryName, 
	Format (InventoryDate, 'MMMM, yyyy') as InventoryDate,  
	SUM([Count]) as InventoryCountByCategory
From vCategories
Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
Inner Join vInventories
	On vInventories.ProductID = vProducts.ProductID
Group By CategoryName, InventoryDate;
go 
-- Check that it works, including the order by clause
-- instructions ask to order by product, is this a typo? will order by category
Select * From vCategoryInventories
Order By CategoryName,
	Cast('1 ' + InventoryDate As date);
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- Step 1: using result from q4
Select ProductName, InventoryDate, InventoryCount
From vProductInventories;
go
-- Step 2: Now, use LAG to retrive the prev month's inventory count
-- Must use PARTITION BY to tell sql server to separate the records by the product
-- Order By is also required to arrange the dates so LAG can find the prev month's count
Select ProductName, 
	InventoryDate, 
	InventoryCount,
	LAG(InventoryCount) Over (
		Partition By ProductName
		Order By CAST('1 ' + InventoryDate As date)
	) As PreviousMonthCount
From vProductInventories;
go
-- Step 3: There are quite a number of NULLs 
-- use ISNULL to return 0 for the previous counts that show as NULL
-- must use column alias otherwise SQL won't assign a column name
Select ProductName, 
	InventoryDate, 
	InventoryCount,
	IsNull (
		LAG(InventoryCount) Over (
			Partition By ProductName
			Order By CAST('1 ' + InventoryDate As date) 
		), 0 
	) As PreviousMonthCount
From vProductInventories;
go
-- Step 4: Create the new view 
Create View vProductInventoriesWithPreviousMonthCounts
As 
Select ProductName, 
	InventoryDate, 
	InventoryCount,
	IsNull (
		LAG(InventoryCount) Over (
			Partition By ProductName
			Order By CAST('1 ' + InventoryDate As date) 
		), 0 
	) As PreviousMonthCount
From vProductInventories;
go
-- Step 5: Check that it works
-- order by product and date: 
Select * 
From vProductInventoriesWithPreviousMonthCounts
Order By ProductName,
	CAST('1 ' + InventoryDate As date);
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

-- Srep 1, start by selecting columns from the view made in Q6
Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount
From vProductInventoriesWithPreviousMonthCounts;
go 
-- Step 2: now, need a function to compare current inventory and previous count
-- use CASE which requires END
Select ProductName, 
	InventoryDate, 
	InventoryCount, 
	PreviousMonthCount,
	Case 
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount < PreviousMonthCount Then -1
		Else 0
	End as CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCounts;
go 
-- Step 3: use this SELECT statement to finally create the View
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As 
Select ProductName, 
	InventoryDate, 
	InventoryCount, 
	PreviousMonthCount,
	Case 
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount < PreviousMonthCount Then -1
		Else 0
	End as CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCounts;
go 
-- Step 4: Check that it works
Select * 
From vProductInventoriesWithPreviousMonthCountsWithKPIs
Order By ProductName,
	CAST('1 ' + InventoryDate as date);
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- Step 1: I am reusing Q7 final view so start by reviewing the columns
Select ProductName, InventoryDate, InventoryCount, 
	PreviousMonthCount, CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go 
-- Step 2: Now, wrap this inside a simple function
-- Since the end result is a table, this is an inline function 
-- We will input a value and get a table result back
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI int)
Returns Table 
As 
Return ( -- will now insert the previous view and its columns here
	Select ProductName, InventoryDate, InventoryCount, 
		PreviousMonthCount, CountVsPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = @KPI
);
go
-- Now, check that the function works with the different parameters: 1, -1, 0
-- Will use Order By when calling the function
-- Show where inventory increased (KPI = 1)
Select * 
From fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
Order By ProductName,
	CAST('1 ' + InventoryDate as date);
go 
-- Show where inventory decreased (KPI = -1)
Select * 
From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
Order By ProductName,
	CAST('1 ' + InventoryDate as date);
go 
-- Show where inventory stayed the same (KPI = 0)
Select * 
From fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
Order By ProductName,
	CAST('1 ' + InventoryDate as date);
go 

Print 'Note: You will get an error until the views and functions are created!'
/* Check that it works:
Select * From vProductInventories;
Select * From vCategoryInventories;
Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/