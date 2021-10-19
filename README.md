# CoreLogic
The University of Michigan library system has acquired a comprehensive, nation-wide dataset containing real estate transactions, deeds, and property tax records for the entire US. The data was originally collected by the commercial vendor Corelogic https://www.corelogic.com/. The license arrangement allows UM researchers to use the data for research and teaching purposes. An interesting aspect of the data from my point of view is that it contains the centroid of each property and thus enables spatial investigation. The data can be of potential interest to researchers in many fields, as they capture spatial and temporal real estate market conditions, taxing practices, and the physical states of millions of residential structures in the US.  

You can use the code here to aggregate the data for any geography, e.g. Census Tracts or County, you are interested in. The Python notebook extracts the data and saves it as a shapefile for later use. The R files read the shapefile, attach some information from Census, and do basic exploratory analysis. You will need a Census API key to access and download the census data. 


