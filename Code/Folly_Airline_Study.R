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
############################################

############################################
#Read in that data #########################
############################################

setwd("G:\\My Drive\\Northwestern\\455 Data Viz\\The Show\\Data\\Airline Data")

ptm <- proc.time()

flightData <- data.table::fread("flightData2.csv")

testFlightData <- head(flightData)

cancellationReasons <- data.table::fread("L_CANCELLATION.csv")


carrierCodes <- data.table::fread("L_UNIQUE_CARRIERS.csv")

proc.time() - ptm

#Clean the look up tables
cancellationReasons <- cancellationReasons %>% rename(CancellationReasonDescription = Description)

carrierCodes <- carrierCodes %>% rename(AirlineCarrier = Description)


#Join the look up tables
flightData <- left_join(flightData, carrierCodes, by = c("Reporting_Airline" = "Code"))

flightData <- left_join(flightData, cancellationReasons, by = c("CancellationCode" = "Code"))


testFlightData <- head(flightData, n = 100000)

