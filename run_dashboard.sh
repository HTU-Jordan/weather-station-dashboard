#!/bin/bash

Rscript -e 'library(methods); shiny::runApp("../weather-station-dashboard/", host="*.*.*.*", port=5051, launch.browser=TRUE)'
