# Let us associate building footprints with the relevant data.
library(sf)
library(leaflet)
library(dplyr)
library(readxl)
library(tidycensus)
library(USAboundaries)
library(data.table)
library(ggplot2)

# Set your census API key
census_api_key('Your API key goes here as a string', overwrite = FALSE, install = TRUE)


##### Get the names of the three data files
fileNames = list.files('/Volumes/corelogic/', pattern = '*_Count', full.names = TRUE)
print(fileNames)
summaryData = read_excel(fileNames[1])     # Change the no to 1, 2, or 3 here

head(summaryData)

##### 1. Let us examine how much coverage do we have for each of the three files 

# Coverage extent in a state relative to county population
cencusVar = load_variables(year=2010, dataset = 'sf1')

stateCode = "MI"   # Change FIPS code here
summaryData.mi = summaryData[summaryData$STATE == stateCode,]  

mi.county = get_decennial(geography = 'county', state = stateCode, variables = 'P001001', year = 2010, geometry = TRUE)
mi.county = mi.county[c('GEOID', 'value')]
setnames(mi.county, 'value', 'population')
mi.county = inner_join(mi.county, summaryData.mi[c('FIPS', 'TOTAL_RECORDS')], by = c('GEOID'= 'FIPS'))
mi.county['records_rate'] = (mi.county$TOTAL_RECORDS / mi.county$population)*6

ggplot(data = mi.county) + geom_sf(aes(fill = records_rate)) + scale_fill_viridis_c(option = "plasma", trans = "sqrt", breaks = c(1, 4, 7, 11, 14, 17))








