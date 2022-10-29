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

#Summarize the data

#Number of Flights by Airlines over time

numFlightsByCarrierDate <- flightData %>%
                          group_by(AirlineCarrier, FlightDate) %>%
                          summarise(numFlights = n())

topFiveAirlines <- numFlightsByCarrierDate %>% 
  arrange(desc(numFlights)) %>% 
  group_by(FlightDate) %>% slice(1:5)


ggplot(data=topFiveAirlines, aes(x=FlightDate, y=numFlights, 
                                 group=AirlineCarrier, color=AirlineCarrier))+
  geom_line()  + scale_y_continuous() + 
  theme_tufte()  + ggtitle("Number of Flights Per Week") + 
  xlab("Date")  + ylab("Number of Flights")
