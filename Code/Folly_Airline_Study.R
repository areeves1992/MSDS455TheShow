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

#install.packages("stringr")
library(stringr)

#install.packages("tidyr")
library("tidyr")

#install.packages("reshape")
library("reshape")

#install.packages("reshape2")
library("reshape2")
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

#Remove "Airline" etc from the carrier - keep only the first word
flightData$AirlineCarrier <- str_extract(flightData$AirlineCarrier, "^([^\\s]+)")


#Create another test DF as the real file is GBs.
testFlightData <- head(flightData, n = 100000)

#Find the week of the date of departure
flightData$week <- floor_date(flightData$FlightDate, "week")

#Find day of week
flightData$dayOfWeek <- wday(flightData$FlightDate, abbr = TRUE, label = TRUE)

#Create another test DF as the real file is GBs.
testFlightData <- head(flightData, n = 100000)

#Colors as defined by our group via Canvas and the check-ins
color_palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#"Main color" is dark blue so i will be using blue for my maps

#Summarize the data and create graphics

#Line graph - Number of Flights by Airlines over time
numFlightsByCarrierDate <- flightData %>%
                          group_by(AirlineCarrier, week) %>%
                          summarise(numFlights = n())

#Find the top 5 by number of flights by week
topFiveAirlines <- numFlightsByCarrierDate %>% 
  arrange(desc(numFlights)) %>% 
  group_by(week) %>% slice(1:4)

#Create line graph of the number of flights per week by airline
numberOfFlightsOverTime <- ggplot(data=topFiveAirlines, aes(x=week, y=numFlights, 
                                 group=AirlineCarrier, color=AirlineCarrier))+
  geom_line()  + scale_y_continuous(n.breaks = 10, label = comma)   + ggtitle("Top 4 Airlines Per Week by Flight Count") + 
  xlab("Date")  + ylab("Number of Flights Per Week") + 
  guides(color=guide_legend(title="Airline")) + 
  theme_tufte()


##Bar chart - number of flights per day of week
numFlightsByCarrierDay <- flightData %>%
  group_by(AirlineCarrier, dayOfWeek) %>%
  summarise(numFlights = n())

#Find the top 5
topFiveAirlinesDayofWeek <- numFlightsByCarrierDay %>% 
  arrange(desc(numFlights)) %>% 
  group_by(dayOfWeek) %>% slice(1:4)

#Bar chart of the number of flights by week day by airline
numberOfFlightsPerWeek <- ggplot(data = topFiveAirlinesDayofWeek, aes(x = dayOfWeek, y = numFlights, 
                                            fill = AirlineCarrier)) +
  geom_bar(stat = "identity", position=position_dodge() ) + 
  scale_y_continuous(n.breaks = 12, label = comma)   + 
  ggtitle("Top 4 Airlines: Number of Flights Per Week Day") + 
  xlab("Day of Week")  + ylab("Number of Flights") + 
  guides(fill=guide_legend(title="Airline")) + 
  theme_tufte()

##############################################
# Create a heat map for the number of flights by origin state
#Which airline has the most origin flights in ameria?
##############################################

data(state.fips)

variablesToQuery <- load_variables(2020, "acs5", cache = TRUE)


Sys.getenv("CENSUS_API_KEY")

geometry <- get_acs(geography = "state",
        variables = 	
          "B01001_001", 
        year = 2020, geometry = TRUE)

topAirlinesMaps <- flightData %>% group_by(AirlineCarrier) %>%
  summarise(numFlights = n())
            
topAirlinesMaps <- topAirlinesMaps %>% 
    arrange(desc(numFlights)) %>% 
     slice(1:4)

topAirlinesMaps <- unique(topAirlinesMaps$AirlineCarrier)

numOriginFips <- flightData %>% filter(AirlineCarrier %in% topAirlinesMaps) %>% 
  group_by(AirlineCarrier,OriginStateFips) %>%
  summarise(numFlights = n())

geometry$GeoInt <- as.integer(geometry$GEOID)

numOriginFips <- geometry  %>% 
  left_join(numOriginFips, by=c('GeoInt'='OriginStateFips')) 
#numOriginFipsTest %>% map("state", fill=TRUE, col=numOriginFipsTest$numFlights)

numOriginFips <- numOriginFips %>% tidyr::drop_na(AirlineCarrier)

numOriginFips <- numOriginFips %>% filter(GeoInt <=56 ) %>% 
  filter(GeoInt != 2) %>% filter(GeoInt != 15)

numberofFlightsbyOriginState <- ggplot(data = numOriginFips, aes(fill = numFlights)) +
  facet_wrap(~AirlineCarrier, nrow = 2, ncol = 2) +
  geom_sf() +
  theme_void() +
  scale_fill_distiller(labels=function(x) format(x, big.mark = ",", scientific = FALSE), palette = "Blues", direction = 1) +
  labs(title = "Number of Flights by Origin State by Top Four Airlines",
       caption = "Data Source: FAA Flight Data, Census Geographies \n Lower 48 States Only. 2020-2021.")

##############################################
# End Origin Map
##############################################

##############################################
# Create a heat map for the number of flights by departure state
# Which airline has the most departure flights in america?
##############################################

numDestFips <- flightData %>% filter(AirlineCarrier %in% topAirlinesMaps) %>% 
  group_by(AirlineCarrier,DestStateFips) %>%
  summarise(numFlights = n())

geometry$GeoInt <- as.integer(geometry$GEOID)

numDestFips <- geometry  %>% 
  left_join(numDestFips, by=c('GeoInt'='DestStateFips')) 
#numOriginFipsTest %>% map("state", fill=TRUE, col=numOriginFipsTest$numFlights)

numDestFips <- numDestFips %>% tidyr::drop_na(AirlineCarrier)

numDestFips <- numDestFips %>% filter(GeoInt <=56 ) %>% 
  filter(GeoInt != 2) %>% filter(GeoInt != 15)

numberofFlightsbyDestState <- ggplot(data = numDestFips, aes(fill = numFlights)) +
  facet_wrap(~AirlineCarrier, nrow = 2, ncol = 2) +
  geom_sf() +
  theme_void() +
  scale_fill_distiller(labels=function(x) format(x, big.mark = ",", scientific = FALSE), palette = "Blues", direction = 1) +
  labs(title = "Number of Flights by Destination State by Top Four Airlines",
       caption = "Data Source: FAA Flight Data, Census Geographies \n Lower 48 States Only. 2020-2021.")

###########################################
## Cancellation Study
###########################################



###########################################
## Delay Study
###########################################

#Section for Melted data
meltFlight <- flightData %>% select(AirlineCarrier, week, CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay)

#meltFlight$id <- c(1:nrow(meltFlight))

meltFlight <- melt(meltFlight, id.vars = c("AirlineCarrier", "week"))




## Sum of Delay minutes
meltFlight <- na.omit(meltFlight)

typeOfDelay <- meltFlight %>%
  group_by(AirlineCarrier, variable) %>%
  summarise(totalMinutes = sum(value), mean = mean(value))



typeOfDelay <- typeOfDelay %>% 
  filter(variable == 'CarrierDelay' ) %>%
arrange(desc(mean))

typeOfDelay <- typeOfDelay[1:4,]

avgCarrierDelay <- ggplot(data = typeOfDelay, aes(x = AirlineCarrier, y = mean,
                               fill = AirlineCarrier, label = AirlineCarrier)) +
  geom_bar(stat = "identity", position=position_dodge() ) +
  scale_y_continuous(n.breaks = 15, label = comma)   + 
  ggtitle("Top 4 Airlines: Average Carrier Delay") + 
  xlab("Airline")  + ylab("Average Delay (Minutes)") + 
  guides(fill=guide_legend(title="Airline")) +
  labs(caption = "Data Source: FAA Flight Data. 2020-2021.")