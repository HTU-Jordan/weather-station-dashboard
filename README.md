# Weather Station Dashboard

## Overview
We have a weather station atop the main building at HTU. We decided to take the data feed and create a simple real-time / pseudo real-time dashboard that represents the data in an intuitive way and gives insight into our weather conditions.

![dashboard](dashboard_scrot.png)

__Note:__ All IP addresses, database users and passwords have been replaced with * for security purposes.

## Technologies

- __R__ for data analyses and visualizations
- __Shiny__ for dashboard Server logic and UI
- __HTML__ for design
- __CSS__ for design
- __Python__ for initializing and updating the database
- __SQL__ for database
- __LoggerNet (CRBasic)__ for the weather station connection


## Folder Structure
Stylesheet, logo, font and footer files are place in the `www` folder. Shiny readily accepts them in this directory.

## Data Pipeline
The weather station outputs 3 comma-separated tables.   
1. `CR1000_FifteenSec.dat` - A single entry that gets replaced every 15 seconds due to storage constraints.  
2. `CR1000_OneMin.dat` - Readings every minute.  
3. `CR1000_OneHour.dat` - Readings every hour.  

The new entries in these tables (except the 15 Second table) are appended to a MS-SQL database called `weatherDB` with tables called `perMINUTE` and `perHOUR` respectively.  

Then our dashboard connects to the database and the 15 Second Table and reads a specified number of rows from each to process and display.

## Source Code Explanation
- `loggernet-config.CR1`  
Configuration file/program for the weather station.  

- `global.R`  
Contains static logic for the dashboard as well as library imports.

- `app.R`  
Main dashboard source file, contains all UI and Server logic.

- `ws_db.sql`    
Creates database schema.

- `init_weatherDB.py`  
Populate the database for the first time.

- `update_min_weatherDB.py`  
Update the database (table = perMINUTE) on change in output tables from weather station.

- `update_hour_weatherDB.py`  
Update the database (table = perHOUR) on change in output tables from weather station.

- `update_min_weatherDB.bat`  
Call `update_min_weatherDB.py` from windows task scheduler.

- `update_hour_weatherDB.bat`  
Call `update_hour_weatherDB.py` from windows task scheduler.

- `run_dashboard.sh`, and `run_db script.sh`   
Linux scripts to run the dashboard by broadcasting to an IP address and run the database update script

- `www\style.css`  
CSS design stylesheet for the dashboard.

## Difficulties and Obstacles   
#### Design  
- Because we used `shinydashboard` as the package for the UI, altering the UI and sizing it according to resolution demanded hard-coding the CSS elements. The code hosted here is for a resolution of 1920x1080. We had to redesign it when broadcasting to a screen because the resolution was 1280x768.  

- We intially wanted to display a correlation between _solar radiation_ and _visibility_, however the plot was difficult to read and understand, and was not so aesthetically pleasing. So we decided to investigate and show the inverse-correlation between _relative humidity_ and _air density_.  

#### Calculations  
- We also needed to find the _air density_ through calculations, this was important to display the _wind rose_ and the _air density vs relative humidity_. So we got on Wikipedia and used the equation of air density for humid air. <https://en.wikipedia.org/wiki/Density_of_air#Humidity_(water_vapor)>

- The _wind rose_ displays __wind power__, however our weather station does not output the wind power, it outputs variables such as __wind speed__ and __wind direction__. So we calculated the **_specific_** __wind power__ as if it is being collected by a wind turbine with an area of 1m^2 because we do not have a wind turbine.  
The equation was also taken from Wikipedia: <https://en.wikipedia.org/wiki/Wind_power#Wind_energy>

#### Code


#### Hardware
