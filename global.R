# ------------------------------------------------------------------------------
oldw <- getOption("warn")
options(warn = -1)

# ------------------------------------------------------------------------------
# Import Libraries and Modules
# ------------------------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(magrittr)
library(scales)
library(ggplot2)
library(openair)
library(reshape2)
library(RODBC)
library(lubridate)


# ------------------------------------------------------------------------------
# Define Filepath and Column Names
# ------------------------------------------------------------------------------
filepath1 <<- "C:\\Campbellsci\\LoggerNet\\CR1000_FifteenSec.dat"
filepath2 <<- "C:\\Campbellsci\\LoggerNet\\CR1000_OneMinute.dat"
filepath3 <<- "C:\\Campbellsci\\LoggerNet\\CR1000_OneHour.dat"
cols <<- c("ts", "rec", "ws", "wd", "wsc", "srad", "temp", "rh", "rain", "vis", "bp")


# ------------------------------------------------------------------------------
# Define Database Connection
# ------------------------------------------------------------------------------

connect_to_db <- function() {
  con <<- odbcDriverConnect(connection=
                              'dsn=weather-ODBC;
                            driver={SQL Server Native Client 11.0};
                            trusted_connection=yes')
  return(con)
}

# ------------------------------------------------------------------------------
# Define Calculation Functions
# ------------------------------------------------------------------------------

# Air Density
air_density_function <- function(reactive_data){

  density_frame <- reactive_data
  phi <- density_frame$rh
  p_sat <- 6.1078 * 10^((7.5*density_frame$temp)/(density_frame$temp+237.3)) * 100
  p_v <- phi*p_sat
  abs_temp <- density_frame$temp + 273.15
  p <- density_frame$bp * 1.3332237 * 100
  p_d <- p - p_v
  # kg/mol
  M_d <- 0.028964
  M_v <- 0.018016
  # J/(kg.K)
  R_d <- 287.058
  R_v <- 461.495
  air_density <- ((p_d / (R_d * abs_temp)) + (p_v / (R_v * abs_temp)))
  air_density <<- round(air_density, 3)
}

# Wind Power
wind_power_function <- function(air_density, reactive_data) ({
  w1 <- 1*air_density*(reactive_data$ws^3)
})

# Data Scaling and Normalization Function - Range (0,1)
norm_data <- function(x) {
  x <- (x - min(x)) / (max(x) - min(x))
}

options(warn = oldw)