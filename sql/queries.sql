/* ============================================================
   📊 Blinkit Data Analysis Project (SQL)
   ------------------------------------------------------------
   Description:
   This project performs end-to-end data analysis on Blinkit 
   grocery dataset using SQL. It includes:
   - Data ingestion
   - Data cleaning
   - KPI calculations
   - Business insights generation

   Dataset: Blinkit Grocery Data
   ============================================================ */


/* =======================
   🗂️ Database Setup
   ======================= */

-- Create a dedicated database for the project
create database blinkitdb;

-- Select the database
use blinkitdb;


/* =======================
   📋 Table Creation
   ======================= */

-- Create table to store Blinkit dataset
CREATE TABLE blinkit_data (
Item_Fat_Content VARCHAR(50),         -- Fat category (Low Fat / Regular)
Item_Identifier VARCHAR(50),          -- Unique product ID
Item_Type VARCHAR(50),                -- Product category
Outlet_Establishment_Year INT,        -- Outlet setup year
Outlet_Identifier VARCHAR(50),        -- Unique outlet ID
Outlet_Location_Type VARCHAR(50),     -- Tier (Tier 1, 2, 3)
Outlet_Size VARCHAR(50),              -- Outlet size classification
Outlet_Type VARCHAR(50),              -- Store type
Item_Visibility FLOAT,                -- Shelf visibility
Item_Weight FLOAT,                    -- Product weight
Total_Sales FLOAT,                    -- Revenue generated
Rating FLOAT                          -- Customer rating
);


/* =======================
   📥 Data Import
   ======================= */

-- Enable file import (required for CSV loading)
SET GLOBAL local_infile = 1;

-- Verify import settings
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';

-- Load dataset into table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/BlinkIT Grocery Data.csv'
INTO TABLE blinkit_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(item_fat_content,item_identifier,item_type,outlet_establishment_year,
outlet_identifier,outlet_location_type,outlet_size,outlet_type,
item_visibility,@item_weight,total_sales,rating)
SET item_weight = NULLIF(@item_weight,'');  -- Convert blanks to NULL


/* =======================
   🔍 Initial Exploration
   ======================= */

-- View complete dataset
select * from blinkit_data;

-- Total number of records
select count(*) from blinkit_data;


/* =======================
   🧹 Data Cleaning
   ======================= */

-- Disable safe updates to allow modifications
SET SQL_SAFE_UPDATES = 0;

-- Standardize Item_Fat_Content values
UPDATE blinkit_data
SET Item_Fat_Content =
CASE
    WHEN Item_Fat_Content IN ('LF','low_fat') THEN 'Low Fat'
    WHEN Item_Fat_Content = 'reg' THEN 'Regular'
    ELSE Item_Fat_Content
END;

-- Validate cleaned values
SELECT distinct(Item_Fat_Content) from blinkit_data;


/* =======================
   📈 Key Performance Indicators (KPIs)
   ======================= */

-- Total sales (in millions)
SELECT CAST(SUM(Total_Sales) / 1000000 AS DECIMAL(10,2)) AS Total_Sales_Millions
from blinkit_data;

-- Total sales (absolute value)
SELECT CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Avg_Sales
from blinkit_data;

-- Total number of items
select count(*) AS No_of_Items from blinkit_data;

-- Total sales for Low Fat items
SELECT CAST(SUM(Total_Sales) / 1000000 AS DECIMAL(10,2)) AS Total_Sales_Millions
FROM blinkit_data
WHERE Item_Fat_Content = 'Low Fat';

-- Sales performance for outlets established in 2022
SELECT CAST(SUM(Total_Sales) / 1000000 AS DECIMAL(10,2)) AS Total_Sales_Millions
FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022;

-- Average sales (2022 outlets)
SELECT CAST(AVG(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales_Millions
FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022;

-- Number of items (2022 outlets)
select count(*) AS No_of_Items from blinkit_data
WHERE Outlet_Establishment_Year = 2022;

-- Overall average rating
select CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating from blinkit_data;


/* =======================
   📊 Business Insights
   ======================= */

-- Sales breakdown by Fat Content (2022)
SELECT Item_Fat_Content, 
	CAST(SUM(Total_Sales)/ 1000 AS DECIMAL(10,2)) as Total_Sales_Thousands,
	CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as Avg_Sales,
	count(*) AS No_of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating 
FROM Blinkit_data
WHERE Outlet_Establishment_Year = 2022
GROUP BY Item_Fat_Content
ORDER BY Total_Sales_Thousands DESC;


-- Top 5 Item Types by Sales
SELECT Item_Type, 
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) as Total_Sales,
	CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as Avg_Sales,
	count(*) AS No_of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating 
FROM Blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC
LIMIT 5;


-- Sales distribution by Location & Fat Content
SELECT Outlet_Location_Type,Item_Fat_Content, 
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) as Total_Sales,
	CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as Avg_Sales,
	count(*) AS No_of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating 
FROM Blinkit_data
GROUP BY Outlet_Location_Type,Item_Fat_Content
ORDER BY Total_Sales ASC;


-- Pivot view: Low Fat vs Regular sales by location
SELECT Outlet_Location_Type,
       CAST(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END) AS DECIMAL(10,2)) AS Low_Fat,
       CAST(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END) AS DECIMAL(10,2)) AS Regular
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;


-- Year-wise performance trends
SELECT Outlet_Establishment_Year,
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) as Total_Sales,
	CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as Avg_Sales,
	count(*) AS No_of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating 
FROM Blinkit_data
GROUP BY  Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year ASC;


-- Sales contribution by outlet size
SELECT Outlet_Size,
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
       CAST(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER() AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;


-- Location-wise analysis (2022)
SELECT Outlet_Location_Type,
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
       CAST(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER() AS DECIMAL(10,2)) AS Sales_Percentage,
       CAST(AVG(Total_Sales) AS DECIMAL(10,2)) AS Avg_Sales,
       COUNT(*) AS No_of_Items,
       CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;


-- Outlet type performance (2022)
SELECT Outlet_Type,
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
       CAST(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER() AS DECIMAL(10,2)) AS Sales_Percentage,
       CAST(AVG(Total_Sales) AS DECIMAL(10,2)) AS Avg_Sales,
       COUNT(*) AS No_of_Items,
       CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;
