# ------------------------------------------------------------------------------
oldw <- getOption("warn")
options(warn = -1)


# Import Libraries and Modules
# ------------------------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(xlsx)
library(magrittr)
library(scales)
library(ggplot2)
library(openair)
library(reshape2)
library(RODBC)
library(lubridate)

# ------------------------------------------------------------------------------
# Define SQL Functions
# ------------------------------------------------------------------------------
con <- odbcDriverConnect(connection=
                        "driver=/opt/microsoft/msodbcsql/lib64/libmsodbcsql-13.1.so.9.1;
                         server=localhost;
                         database=wsDB;
                         uid=**********;
                         pwd=**********")
retrieve_data <- function() {
  reactive_data <- sqlQuery(con, "select * from perHOUR")
  # close(con)
  return(reactive_data)
}
cheap_check <- function() {
  data_check <- sqlQuery(con, "select MAX(ts) from perHOUR")
  # close(con)
  return(data_check)
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