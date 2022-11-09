#MSDS455
#The Show
#Airline Study
#Amber Reeves

#############################################
#install packages############################
#############################################

#install.packages("data.table")
library(data.table)

#install.packages("dplyr")
library(dplyr)

#install.packages("ggplot2")
library(ggplot2)

#install.packages("ggthemes")
library(ggthemes)

#install.packages("lubridate")
library(lubridate)

#install.packages("lubridate")
library(scales)

#install.packages("maps")
library(maps)

#install.packages("tidycensus")
library(tidycensus)

#install.packages("sf")
library(sf)
############################################

############################################
#Read in that data #########################
############################################

#Set my working directory
setwd("G:\\My Drive\\Northwestern\\455 Data Viz\\The Show\\Data\\Airline Data")

#Start a timer as this took forever the first time
ptm <- proc.time()

#Load using fread
flightData <- data.table::fread("flightData2.csv")

#Create a small test version to look at
testFlightData <- head(flightData)

#Read in the look up tables from the FAA
cancellationReasons <- data.table::fread("L_CANCELLATION.csv")

carrierCodes <- data.table::fread("L_UNIQUE_CARRIERS.csv")

#Stop the timer
proc.time() - ptm

#Clean the look up tables
cancellationReasons <- cancellationReasons %>% rename(CancellationReasonDescription = Description)

carrierCodes <- carrierCodes %>% rename(AirlineCarrier = Description)


#Join the look up tables
flightData <- left_join(flightData, carrierCodes, by = c("Reporting_Airline" = "Code"))

flightData <- left_join(flightData, cancellationReasons, by = c("CancellationCode" = "Code"))

#Create another test DF as the real file is GBs.
testFlightData <- head(flightData, n = 100000)


flightData$week <- floor_date(flightData$FlightDate, "week")

flightData$dayOfWeek <- wday(flightData$FlightDate, abbr = TRUE, label = TRUE)


#Create another test DF as the real file is GBs.
testFlightData <- head(flightData, n = 100000)


#Summarize the data and create graphics

#Line graph - Number of Flights by Airlines over time
numFlightsByCarrierDate <- flightData %>%
                          group_by(AirlineCarrier, week) %>%
                          summarise(numFlights = n())


topFiveAirlines <- numFlightsByCarrierDate %>% 
  arrange(desc(numFlights)) %>% 
  group_by(week) %>% slice(1:5)


numberOfFlightsOverTime <- ggplot(data=topFiveAirlines, aes(x=week, y=numFlights, 
                                 group=AirlineCarrier, color=AirlineCarrier))+
  geom_line()  + scale_y_continuous(n.breaks = 10, label = comma)   + ggtitle("Top 5 Airlines Per Week") + 
  xlab("Date")  + ylab("Number of Flights Per Week") + 
  guides(color=guide_legend(title="Airline")) + 
  theme_tufte()


##Bar chart - number of flights per day of week
numFlightsByCarrierDay <- flightData %>%
  group_by(AirlineCarrier, dayOfWeek) %>%
  summarise(numFlights = n())

topFiveAirlinesDayofWeek <- numFlightsByCarrierDay %>% 
  arrange(desc(numFlights)) %>% 
  group_by(dayOfWeek) %>% slice(1:5)

numberOfFlightsPerWeek <- ggplot(data = topFiveAirlinesDayofWeek, aes(x = dayOfWeek, y = numFlights, 
                                            fill = AirlineCarrier)) +
  geom_bar(stat = "identity", position=position_dodge() ) + 
  scale_y_continuous(n.breaks = 12, label = comma)   + 
  ggtitle("Top 5 Airlines: Number of Flights Per Week Day") + 
  xlab("Day of Week")  + ylab("Number of Flights") + 
  guides(fill=guide_legend(title="Airline")) 

##############################################
# testing some map stuff out
##############################################

data(state.fips)

variablesToQuery <- load_variables(2020, "acs5", cache = TRUE)


Sys.getenv("CENSUS_API_KEY")

geometry <- get_acs(geography = "state",
        variables = 	
          "B01001_001", 
        year = 2020, geometry = TRUE)

numOriginFipsTest <- testFlightData %>% group_by(OriginStateFips) %>%
  summarise(numFlights = n())

geometry$GeoInt <- as.integer(geometry$GEOID)

numOriginFipsTest <- geometry  %>% 
  left_join(numOriginFipsTest, by=c('GeoInt'='OriginStateFips'))
#numOriginFipsTest %>% map("state", fill=TRUE, col=numOriginFipsTest$numFlights)

#remove air from the airline names!

ggplot(data = numOriginFipsTest, aes(fill = numFlights)) +
  geom_sf()