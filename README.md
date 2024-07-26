# 🚲 Cyclistic Bike-Share Analysis 📊

This project analyzes user data from Cyclistic, a bike-share company operating in Chicago. Cyclistic manages a fleet of 5,824 bicycles across 692 docking stations throughout the city, offering both casual (single-ride or full-day passes) and annual membership options.

## 🎯 Key Project Focus:

1. 📈 Analyze the usage patterns of casual riders vs. annual members 
2. 🔄 Identify potential strategies to convert casual riders to annual members 
3. 💡 Develop data-driven recommendations for an effective marketing campaign

The analysis takes into account the existing flexible pricing structure for casual riders and aims to leverage this information to create targeted marketing initiatives. The ultimate goal is to increase the number of annual memberships, which are believed to be more profitable for the company.

## 🛠️ Tools and Process:

### 💾 SQL (Azure Data Studio - SQL Server)
Used for data cleaning, manipulation, and exploration of 44+ million records. Key operations included:
- Renaming columns for clarity
- Consolidating tables using UNION statements
- Standardizing date formats for consistency
- Calculating trip durations (stop time - start time)
- Generating day of the week for trips using WEEKDAY statement
- Converting hexadecimal trip counter to decimal/integer
- Appending all records into one large dataset to optimize performance

### 📊 Power BI
Utilized for data visualization and creating an interactive dashboard to answer business questions and support the case study.

### 🖼️ PowerPoint
Employed to present insights and recommendations to the Marketing Director.

This repository contains the complete data analysis process, including SQL scripts, Power BI files, and the final presentation with recommendations based on the insights gathered.
