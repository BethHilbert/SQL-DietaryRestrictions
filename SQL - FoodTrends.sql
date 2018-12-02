USE FoodTrends;

------------- Prepare Data ------------------------------------------------------

-- Create and Populate DietCategory (new column)
IF OBJECT_ID('dbo.Category', 'U') IS NOT NULL DROP TABLE dbo.Category;
CREATE TABLE dbo.Category (
						CategoryID INT IDENTITY (1,1) PRIMARY KEY
						, CategoryName VARCHAR (25) UNIQUE
						);
INSERT INTO dbo.Category(CategoryName) VALUES ('Allergy');
INSERT INTO dbo.Category(CategoryName) VALUES ('Religion');
INSERT INTO dbo.Category(CategoryName) VALUES ('Wellness');
INSERT INTO dbo.Category(CategoryName) VALUES ('Meatless');

SELECT * FROM Category;

-- Create and Populate Region
IF OBJECT_ID('dbo.Region', 'U') IS NOT NULL DROP TABLE dbo.Region;
CREATE TABLE dbo.Region (
						RegionID INT IDENTITY (1,1) PRIMARY KEY
						,RegionName VARCHAR (25) UNIQUE
						);
INSERT INTO dbo.Region (RegionName)
SELECT DISTINCT Region
FROM InitialFoodTrends;
SELECT * FROM dbo.Region;

-- Create and Populate Diet
IF OBJECT_ID('dbo.Diet', 'U') IS NOT NULL DROP TABLE dbo.Diet;
CREATE TABLE dbo.Diet (
						DietID INT IDENTITY (1,1) PRIMARY KEY
						,DietName VARCHAR (25) UNIQUE
						);
INSERT INTO dbo.Diet (DietName)
SELECT DISTINCT Diet
FROM InitialFoodTrends;

-- Add Column for DietCategory to Diet Table
ALTER TABLE dbo.Diet
ADD DietCategoryID INT FOREIGN KEY REFERENCES dbo.Category(CategoryID);
UPDATE dbo.Diet
SET DietCategoryID = 1
WHERE DietName IN ('Wheat or Gluten Free', 'Lactose/Dairy Free');
UPDATE dbo.Diet
SET DietCategoryID = 2
WHERE DietName IN ('Kosher', 'Halal');
UPDATE dbo.Diet
SET DietCategoryID = 3
WHERE DietName IN ('Low Carbohydrate', 'Low Fat', 'Low Sodium', 'Sugar Conscious');
UPDATE dbo.Diet
SET DietCategoryID = 4
WHERE DietName IN ('Flexitarian', 'Vegan', 'Vegetarian');
SELECT * FROM dbo.Diet;

-- Create Table to Link Other Tables
IF OBJECT_ID('dbo.Trend', 'U') IS NOT NULL DROP TABLE dbo.Trend;
SELECT DISTINCT IDENTITY(INT,1,1)  TrendID
		, RegionID
		, DietID
		, Followers
INTO dbo.Trend
FROM dbo.InitialFoodTrends I
INNER JOIN dbo.Region R on I.Region = R.RegionName
INNER JOIN dbo.Diet D on I.Diet = D.DietName;

ALTER TABLE dbo.TREND ADD PRIMARY KEY (TrendID);
ALTER TABLE dbo.TREND ADD FOREIGN KEY (RegionID) REFERENCES dbo.Region(RegionID);
ALTER TABLE dbo.TREND ADD FOREIGN KEY (DietID) REFERENCES dbo.Diet(DietID);

-- Check that Separation and Join Worked Correctly
-- Original Table
SELECT * FROM dbo.InitialFoodTrends
ORDER BY Diet, Region;

-- Joined Tables
SELECT DietName, RegionName, Followers, CategoryName
FROM dbo.Trend T
LEFT JOIN dbo.Diet D
	ON T.DietID = D.DietID
LEFT JOIN dbo.Region R
	ON T.RegionID = R.RegionID
LEFT JOIN dbo.Category C
	ON D.DietCategoryID = C.CategoryID
ORDER BY DietName, RegionName;

------------- Queries ------------------------------------------------------

-- Group By Category
SELECT C.CategoryName, ROUND(AVG(Followers), 3) AS Avg_Followers
FROM dbo.Trend T
LEFT JOIN dbo.Diet D
	ON T.DietID = D.DietID
LEFT JOIN dbo.Category C
	ON D.DietCategoryID = C.CategoryID
GROUP BY C.CategoryName
ORDER BY Avg_Followers DESC;

-- Group By Region
SELECT R.RegionName, ROUND(AVG(Followers), 3) AS Avg_Followers
FROM dbo.Trend T
LEFT JOIN dbo.Region R
	ON T.RegionID = R.RegionID
GROUP BY R.RegionName
ORDER BY Avg_Followers DESC;

-- Group By Diet
SELECT D.DietName, ROUND(AVG(Followers), 3) AS Avg_Followers
FROM dbo.Trend T
LEFT JOIN dbo.Diet D
	ON T.DietID = D.DietID
GROUP BY D.DietName
ORDER BY Avg_Followers DESC;

-- Most Common Diet Restrictions In Each Region
SELECT RegionName, DietName, Max_Follower
FROM 
   (SELECT RegionID, MAX (Followers) as Max_Follower
   FROM dbo.Trend T
   GROUP BY RegionID ) AS RF
INNER JOIN dbo.Trend T
ON RF.Max_Follower = T.Followers
	AND RF.RegionID = T.RegionID
INNER JOIN dbo.Region R
ON T.RegionID = R.RegionID
INNER JOIN dbo.Diet D
ON T.DietID = D.DietID
ORDER BY Max_Follower DESC;

