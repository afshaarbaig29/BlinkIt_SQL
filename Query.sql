-- ============================================
-- Blinkit Grocery Data Analysis (SQL Project)
-- ============================================

-- Project Overview:
-- This project analyzes Blinkit's grocery sales dataset to understand 
-- business performance, customer behavior, and product trends.
-- The goal is to extract meaningful insights using SQL through data cleaning,
-- KPI calculations, and aggregation techniques.

-- Dataset:
-- Source: Blinkit grocery dataset (CSV)
-- The dataset includes information on:
-- - Item Type & Fat Content
-- - Total Sales & Ratings
-- - Outlet Location, Size, and Type
-- - Outlet Establishment Year
-- - Item Visibility

-- Objectives:
-- 1. Perform data cleaning to ensure consistency (e.g., standardizing item fat content)
-- 2. Calculate key performance indicators (KPIs):
--    - Total Sales
--    - Average Sales
--    - Number of Items
--    - Average Rating
-- 3. Analyze sales performance across:
--    - Item Types
--    - Fat Content
--    - Outlet Location & Size
--    - Outlet Establishment Year
-- 4. Identify trends and patterns in customer behavior and product demand

-- Key Concepts Used:
-- - Data Cleaning (UPDATE, CASE statements)
-- - Aggregations (SUM, AVG, COUNT)
-- - Conditional Analysis (CASE WHEN)
-- - NULL Handling (IFNULL)
-- - Grouping & Sorting (GROUP BY, ORDER BY)

-- Note:
-- This project is implemented using MySQL. 
-- Pivot-like analysis is performed using CASE-based aggregation 
-- since MySQL does not support the PIVOT function.


-- ============================================
-- Step 1: View Raw Data
-- ============================================
-- Preview the dataset

SELECT * FROM blinkit_grocery_data;

-- ============================================
-- Step 2: Data Cleaning
-- ============================================
-- Objective:
-- Standardize 'Item_Fat_Content' values to ensure consistency.
-- Multiple variations like 'LF', 'low fat', and 'reg' can lead to incorrect analysis.

UPDATE blinkit_grocery_data
SET `Item Fat Content` =
CASE 
    WHEN `Item Fat Content` IN ('LF', 'low fat') THEN 'Low Fat'
    WHEN `Item Fat Content` = 'reg' THEN 'Regular' 
    ELSE `Item Fat Content`
END;

-- ============================================
-- Step 3: Validate Data Cleaning
-- ============================================
-- Check distinct values after cleaning

SELECT DISTINCT `Item Fat Content`
FROM blinkit_grocery_data;

-- ============================================
-- Section A: Key Performance Indicators (KPIs)
-- ============================================

-- 1. Total Sales (in Millions)
-- Calculates total revenue generated from all items sold

SELECT CAST( SUM(`Total Sales`)/1000000 AS DECIMAL(10,2)) AS Total_Sales_in_Millions
FROM blinkit_grocery_data;

-- 2. Average Sales
-- Calculates average revenue per transaction

SELECT CAST(AVG(`Total Sales`) AS DECIMAL(10,0)) AS Avg_Sales
FROM blinkit_grocery_data;

-- 3. Number of Orders
-- Counts total number of records/orders

SELECT COUNT(*) AS Total_Items 
FROM blinkit_grocery_data;

-- 4. Average Rating
-- Calculates average customer rating

SELECT CAST(AVG(`Rating`) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_grocery_data;

-- ============================================
-- Section B: Total Sales by Fat Content
-- ============================================

-- Objective:
-- Analyze how different fat content categories contribute to total sales

SELECT `Item Fat Content`,
CAST(SUM(`Total Sales`)AS DECIMAL(10,2))AS Total_Sales
FROM blinkit_grocery_data
GROUP BY `Item Fat Content`
ORDER BY Total_Sales DESC

-- ============================================
-- Section C: Total Sales by Item Type
-- ============================================

-- Objective:
-- Identify top-performing item categories based on total sales

SELECT `Item Type`,
CAST(SUM(`Total Sales`)AS DECIMAL(10,2))AS Total_Sales
FROM blinkit_grocery_data
GROUP BY `Item Type`
ORDER BY Total_Sales DESC

-- ============================================
-- Section D: Fat Content by Outlet for Total Sales
-- ============================================

-- Objective:
-- Compare total sales across different outlet locations 
-- based on item fat content (Low Fat vs Regular)
  
SELECT `Outlet Location Type`,
    CAST(IFNULL(SUM(
				CASE 
				WHEN `Item Fat Content` = 'Low Fat' 
				THEN `Total Sales` 
				END), 0) AS DECIMAL (10,2)) AS Low_Fat,
    CAST(IFNULL(SUM(
				CASE 
				WHEN `Item Fat Content` = 'Regular' 
				THEN `Total Sales` 
				END), 0 ) AS DECIMAL (10,2)) AS Regular
FROM blinkit_grocery_data
GROUP BY `Outlet Location Type`
ORDER BY `Outlet Location Type`;

-- ============================================
-- Section E: Total Sales by Outlet Establishment Year
-- ============================================

-- Objective:
-- Analyze how outlet establishment year impacts total sales performance

SELECT `Outlet Establishment Year`,
CAST(SUM(`Total Sales`)AS DECIMAL(10,2))AS Total_Sales
FROM blinkit_grocery_data
GROUP BY `Outlet Establishment Year`
ORDER BY `Outlet Establishment Year`

-- ============================================
-- Section F: Percentage of Sales by Outlet Size
-- ============================================

-- Objective:
-- Analyze the contribution of each outlet size to total sales
  
SELECT `Outlet Size`,
CAST(SUM(`Total Sales`)AS DECIMAL(10,2))AS Total_Sales,
CAST((SUM(`Total Sales`)* 100.0 /SUM(SUM(`Total Sales`))OVER())AS DECIMAL(10,2))AS Sales_Percentage
FROM blinkit_grocery_data
GROUP BY `Outlet Size`
ORDER BY Total_Sales DESC;

-- ============================================
-- Section G: Sales by Outlet Location
-- ============================================

-- Objective:
-- Analyze total sales distribution across different outlet locations

SELECT `Outlet Location Type`,
CAST(SUM(`Total Sales`)AS DECIMAL(10,2))AS Total_Sales
FROM blinkit_grocery_data
GROUP BY `Outlet Location Type`
ORDER BY `Total_Sales` DESC;

-- ============================================
-- Section H: All Metrics by Outlet Type
-- ============================================

-- Objective:
-- Provide a comprehensive view of key performance metrics 
-- across different outlet types

SELECT `Outlet Type`,
CAST(SUM(`Total Sales`)AS DECIMAL(10,2))AS Total_Sales,
		CAST(AVG(`Total Sales`)AS DECIMAL(10,0))AS Avg_Sales,
		COUNT(*)AS No_Of_Items,
		CAST(AVG(`Rating`)AS DECIMAL(10,2))AS Avg_Rating,
		CAST(AVG(`Item Visibility`)AS DECIMAL(10,2))AS Item_Visibility
FROM blinkit_grocery_data
GROUP BY `Outlet Type`
ORDER BY Total_Sales DESC;
