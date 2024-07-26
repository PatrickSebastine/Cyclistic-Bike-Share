--#region Rename Columns
-- Rename the column ride_id to trip_id
EXEC sp_rename 'dbo.[2024].ride_id', 'trip_id', 'COLUMN';

-- Rename the column started_at to start_time
EXEC sp_rename 'dbo.[2024].started_at', 'start_time', 'COLUMN';

-- Rename the column ended_at to stop_time
EXEC sp_rename 'dbo.[2024].ended_at', 'stop_time', 'COLUMN';

-- Rename the column member_casual to user_type
EXEC sp_rename 'dbo.[2024].member_casual', 'user_type', 'COLUMN';
--#endregion

--#region Step 1: Consolidate tables

CREATE VIEW dbo.View2013 AS
SELECT *
FROM dbo.[2024_1]

UNION

SELECT *
FROM dbo.[2024_2]

UNION

SELECT *
FROM dbo.[2024_3];

--#endregion

--#region Step 2: Drop the 'trip_duration' column from the table (if exists)
ALTER TABLE dbo.[2024]
DROP COLUMN trip_duration;

--#endregion

SELECT TOP 1000 *
FROM dbo.[2024]

--#region Step 3: Format date columns
-- Update the 'start_time' and 'stop_time' columns to the desired format
-- This step actually converts the datetime values to strings in the desired format
-- NOTE: This will change the data type of the columns to NVARCHAR

/* Remove trailing characters 
UPDATE dbo.[2024]
SET start_time = LEFT(start_time, LEN(start_time) - 3),
    stop_time = LEFT(stop_time, LEN(stop_time) - 3);
*/

ALTER TABLE dbo.[2024]
ALTER COLUMN start_time NVARCHAR(50);

ALTER TABLE dbo.[2024]
ALTER COLUMN stop_time NVARCHAR(50);

UPDATE dbo.[2024]
SET start_time = FORMAT(CAST(start_time AS DATETIME), 'MM-dd-yyyy HH:mm'),
    stop_time = FORMAT(CAST(stop_time AS DATETIME), 'MM-dd-yyyy HH:mm');

--#endregion

--#region Step 4: Create and calculate ride lenght column
-- Add a new column named 'ride_lenght' to the table
ALTER TABLE dbo.[2024]
ADD ride_length INT;

-- Update the new column with calculated values
UPDATE dbo.[2024]
SET ride_length = DATEDIFF(SECOND, start_time, stop_time);

-- Verify that the update was successful
SELECT TOP 100 start_time, stop_time, ride_length
FROM dbo.[2024];

-- Check for anomalies in calculation
-- Negative results indicates the start time is a future date
SELECT ride_length
FROM dbo.[2024]
WHERE ride_length < 0

--#endregion

--#region Step 5: Create and calculate week day column
-- Add a new column named 'day_of_week' to the table
ALTER TABLE dbo.[2024]
ADD day_of_week INT; -- This column will store the day of the week for each ride

-- Update the 'day_of_week' column with the day of the week values based on 'start_time'
UPDATE dbo.[2024]
SET day_of_week = DATEPART(WEEKDAY, start_time); 
-- DATEPART(WEEKDAY, start_time) returns an integer representing the day of the week
-- By default, 1 = Sunday, 2 = Monday, ..., 7 = Saturday

-- Verify that the update was successful
SELECT TOP 1000 start_time, day_of_week
FROM dbo.[2024];
-- This query retrieves the 'start_time' and 'day_of_week' columns to ensure that the 'day_of_week' values have been correctly populated

--#endregion

--#region Step 6: Update 'user_type' values
-- Replace 'Customer' with 'Casual' and 'Subscriber' with 'Member'
UPDATE dbo.[2024]
SET user_type = CASE 
                    WHEN user_type = 'Customer' THEN 'Casual'
                    WHEN user_type = 'Subscriber' THEN 'Member'
                    ELSE user_type -- Keeps the existing value if it is neither 'Customer' nor 'Subscriber'
                END;

--#endregion

--#region Step 7: Drop the 'birthday' column 
ALTER TABLE dbo.[2019]
DROP COLUMN birthday

--#endregion

--#region Step 8: Delete records with wrong format on 'trip_id' column
SELECT trip_id
FROM dbo.[2024]
WHERE ISNUMERIC(trip_id) > 0;

DELETE FROM dbo.[2024]
WHERE ISNUMERIC(trip_id) > 0;
--#endregion

--#region Step 9: Convert 'trip_id' from hexadecimal to integer

-- Add a new column to store the integer values if it doesn't exist
ALTER TABLE dbo.[2024] ADD trip_id_integer BIGINT;

-- Clean the data: Remove non-numeric characters if any
UPDATE dbo.[2024]
SET trip_id = REPLACE(trip_id, ',', '');  -- Example for removing commas, adjust as necessary

-- Update the new column with the converted integer values
UPDATE dbo.[2024]
SET trip_id_integer = CAST(CONVERT(BIGINT, CONVERT(VARBINARY, trip_id, 2)) AS BIGINT);

-- Update the trip_id column with values cast from trip_id_integer
UPDATE dbo.[2024]
SET trip_id = CAST(trip_id_integer AS BIGINT);

-- Update the trip_id column to be of type BIGINT
ALTER TABLE dbo.[2024]
ALTER COLUMN trip_id BIGINT;

-- Update the table to set trip_id to its absolute value
UPDATE dbo.[2024]
SET trip_id = ABS(trip_id)
WHERE trip_id < 0;

ALTER TABLE dbo.[2024]
DROP COLUMN trip_id_integer;

SELECT TOP 100 *
FROM dbo.[2024]

--#endregion

--#region Step 10: Consolidate dataset for Analysis

SELECT * INTO dbo.[All_Years_Trip_Data]
FROM dbo.[2013]

UNION 
SELECT * 
FROM dbo.[2014]

UNION 
SELECT * 
FROM dbo.[2015]

UNION 
SELECT * 
FROM dbo.[2016]

UNION 
SELECT * 
FROM dbo.[2017]

UNION 
SELECT * 
FROM dbo.[2018]

UNION 
SELECT * 
FROM dbo.[2019]

UNION 
SELECT * 
FROM dbo.[2020]

UNION 
SELECT * 
FROM dbo.[2021]

UNION 
SELECT * 
FROM dbo.[2022]

UNION 
SELECT * 
FROM dbo.[2023]

UNION 
SELECT * 
FROM dbo.[2024];

--#endregion

--#region Step 11: Descriptive analysis

-- Calculate the mean of ride_length
SELECT AVG(CAST(ride_length AS FLOAT)) AS mean_ride_length
FROM dbo.[2024];

-- Calculate the maximum of ride_length
SELECT MAX(ride_length) AS max_ride_length
FROM dbo.[2024];

-- Calculate the mode of day_of_week
-- First, we count the occurrences of each day_of_week
WITH DayOfWeekCounts AS (
    SELECT
        day_of_week,
        COUNT(*) AS count_of_day
    FROM dbo.[2024]
    GROUP BY day_of_week
),
-- Then, we assign a row number to each day_of_week count, ordered by the count descending
RankedDayOfWeek AS (
    SELECT
        day_of_week,
        count_of_day,
        ROW_NUMBER() OVER (ORDER BY count_of_day DESC) AS row_num
    FROM DayOfWeekCounts
)
-- Finally, we select the day_of_week with the highest count (mode)
SELECT day_of_week AS mode_day_of_week
FROM RankedDayOfWeek
WHERE row_num = 1;

--#endregion

--#region Step 12: Verify that the all data manipulation was successful
SELECT *
FROM dbo.[2024]

--#endregion

--#region Step 13: Export file as csv
