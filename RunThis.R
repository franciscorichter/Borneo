# install needed packages in case are not installed
list.of.packages <- c('xlsx', "shiny", 'leaflet', 'RColorBrewer', 'DT')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# clean enviroment and load xlsx and shiny packages
rm(list=ls())
library(xlsx)
library('shiny')

# Load data
malaysia = read.xlsx('SABAH LAND SNAIL SPECIES DATABASE.xlsx',sheetIndex = 1)
# Run app 
runApp('shiny.R')
