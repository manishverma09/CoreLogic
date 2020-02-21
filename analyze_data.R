library(sf)
library(stringr)
library(dplyr)
library(tidycensus)
library(leaflet)
library(USAboundaries)
library(tigris)

projString = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

# Set your census API key
census_api_key('Your API key goes here as a string', overwrite = FALSE, install = TRUE)


### 1. Read and examine the corelogic data that we extracted using Python file extract_and_format.ipynb
corelogic = st_read('dc_prop_sale.shp')
corelogic = st_transform(corelogic, projString)
corelogic['apn'] = str_squish(as.character(corelogic$apn))
print(object.size(corelogic), units = 'Gb')

head(corelogic)  # We do not have sale date for most records

# Let us get data where we have the sale date
index = is.na(corelogic$sale.date)
corelogic.subset = corelogic[!index,]   

# But a lot of these do not have sale amount
index = is.na(corelogic.subset$sale.amoun)
corelogic.subset = corelogic.subset[!index,] 

# Format date values to get the year, note that it is a numeric 
yr = lapply(corelogic.subset$sale.date, function (x) substr(as.character(x), 1, 4))
corelogic.subset['year'] = as.numeric(yr)

# Count no of observations and plot
corelogic.subset.year = corelogic.subset['year'] 
st_geometry(corelogic.subset.year) = NULL
corelogic.subset.year = corelogic.subset.year %>% group_by(year) %>% summarize('Count' = n())
b1 = ggplot(data = corelogic.subset.year, aes(x = year, y=Count)) + geom_bar(stat = 'identity')
b1 + scale_x_continuous(breaks = seq(min(corelogic.subset.year$year), max(corelogic.subset.year$year), 3))

# Let us plot this data to see spatial coverage
dc.boundary = us_states(resolution = 'high', states = 'DC')
leaflet() %>% addTiles() %>% addCircleMarkers(data = st_transform(corelogic.subset, 4326), radius = 2) %>% 
                             addPolygons(data = st_transform(dc.boundary, 4326), fill = FALSE, color = '#F00')


### 2. Let us extract all the data from 2000 onwards and see tract level coverage

corelogic.subset.latest = corelogic.subset[corelogic.subset$year>=2000,]
dc.tracts = st_as_sf(tracts(state = 'DC'))
dc.tracts = st_transform(dc.tracts, projString)
dc.tracts = dc.tracts[c('GEOID')]

# Join and count observations in each tract for each year
dc.mean.val = st_join(corelogic.subset.latest, dc.tracts, left=TRUE)     # this is using st_intersects
st_geometry(dc.mean.val) = NULL
dc.mean.val.count = dc.mean.val %>% group_by(GEOID) %>% group_by(year, add=TRUE) %>% summarise('Count' = n())
print(dc.mean.val.count)

# How many tracts have more than 10 observations in a year

sprintf('No of tracts with more than 10 observaitons in a year is %d out of 540 tract-years', sum(dc.mean.val.count$Count>10))

### 3. What about county level coverage
corelogic.subset.latest = corelogic.subset[corelogic.subset$year>=2000,]
dc.counties = st_as_sf(counties(state = 'DC'))  # There is only one county in DC


