-- Databricks notebook source


-- COMMAND ----------

--------------------------------------------------------------------------------------------
-----Creating transaction_time_bucket (3-hour intervals)
---------------------------------------------------------------------------
SELECT *,

CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS unit_price_clean,

ROUND(
    transaction_qty *
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE),
    2
) AS total_amount,

CASE
    WHEN HOUR(transaction_time) BETWEEN 0 AND 2 THEN '00:00 - 02:59'
    WHEN HOUR(transaction_time) BETWEEN 3 AND 5 THEN '03:00 - 05:59'
    WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00 - 08:59'
    WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00 - 11:59'
    WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00 - 14:59'
    WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00 - 17:59'
    WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00 - 20:59'
    ELSE '21:00 - 23:59'
END AS transaction_time_bucket

FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;
--------------------------------------------------------------------------------------
--Grouping by Product Type and Time Bucket
-------------------------------------------------------------------------------
SELECT

product_type,
store_location,
product_category,

CASE
    WHEN HOUR(transaction_time) BETWEEN 0 AND 2 THEN '00:00 - 02:59'
    WHEN HOUR(transaction_time) BETWEEN 3 AND 5 THEN '03:00 - 05:59'
    WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00 - 08:59'
    WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00 - 11:59'
    WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00 - 14:59'
    WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00 - 17:59'
    WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00 - 20:59'
    ELSE '21:00 - 23:59'
END AS transaction_time_bucket,

SUM(transaction_qty) AS quantity_sold,

ROUND(
    SUM(
        transaction_qty *
        CAST(REPLACE(unit_price, ',', '.') AS DOUBLE)
    ),
    2
) AS Total_Revenue

FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2
GROUP BY
product_type,
store_location,
product_category,
transaction_time_bucket
ORDER BY Total_Revenue DESC;
----------------------------------------------------------
---Create Time Buckets
-----------------------------------------
SELECT

CASE
WHEN HOUR(transaction_time) BETWEEN 6 AND 11 THEN 'Morning'
WHEN HOUR(transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
WHEN HOUR(transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
ELSE 'Night'
END AS transaction_time_bucket

FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;
-------Extracting the Hour
SELECT
transaction_time,
HOUR(transaction_time) AS transaction_hour
FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;
---Creating Weekday vs Weekend
SELECT
transaction_date,

CASE
    WHEN DAYOFWEEK(transaction_date) IN (1,7)
    THEN 'Weekend'
    ELSE 'Weekday'
END AS day_type

FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;
---Extracting the Year

SELECT
transaction_date,
YEAR(transaction_date) AS year
FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;
---Extracting the Month Name
SELECT
transaction_date,
MONTHNAME(transaction_date) AS month_name
FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;

--Extracting the Day of the Week
SELECT
transaction_date,
DAYNAME(transaction_date) AS day_name
FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2;
------------------------------------------------------------------------------
---combining into one table
-----------------------------
WITH coffee_sales AS (
    SELECT
        transaction_id,
        transaction_date,
        transaction_time,
        store_location,
        product_category,
        product_type,
        transaction_qty,
        product_detail,

        -- Clean unit price
        CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS unit_price,

        -- Total Revenue
        ROUND(
            transaction_qty *
            CAST(REPLACE(unit_price, ',', '.') AS DOUBLE),
            2
        ) AS total_amount,

        -- Transaction Hour
        HOUR(transaction_time) AS transaction_hour,

        -- 3-Hour Time Bucket
        CASE
            WHEN HOUR(transaction_time) BETWEEN 0 AND 2 THEN '00:00 - 02:59'
            WHEN HOUR(transaction_time) BETWEEN 3 AND 5 THEN '03:00 - 05:59'
            WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00 - 08:59'
            WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00 - 11:59'
            WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00 - 14:59'
            WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00 - 17:59'
            WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00 - 20:59'
            ELSE '21:00 - 23:59'
        END AS transaction_time_bucket,

        -- Time of Day
        CASE
            WHEN HOUR(transaction_time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
            WHEN HOUR(transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day,

        -- Weekday vs Weekend
        CASE
            WHEN DAYOFWEEK(transaction_date) IN (1,7)
            THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,

        -- Date Columns
        YEAR(transaction_date) AS year,
        MONTHNAME(transaction_date) AS month_name,
        DAYNAME(transaction_date) AS day_name

    FROM brightcofeecasestudy.cofeeshop.bright_coffee_shop_sales_2
)

SELECT
    store_location,
    product_category,
    product_type,
    transaction_time_bucket,
    time_of_day,
    day_type,
    year,
    month_name,
    day_name,
    product_detail,
    SUM(transaction_qty) AS quantity_sold,
    ROUND(SUM(total_amount),2) AS total_revenue,
    COUNT(transaction_id) AS total_transactions

FROM coffee_sales

GROUP BY
    store_location,
    product_category,
    product_type,
    transaction_time_bucket,
    time_of_day,
    day_type,
    year,
    month_name,
    day_name,
    product_detail
   ORDER BY total_revenue DESC;
