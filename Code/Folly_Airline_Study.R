#MSDS455
#The Show
#Airline Study
#Amber Reeves

#############################################
#install packages############################
#############################################

#install.packages("data.table")
library(data.table)

############################################

############################################
#Read in that data #########################
############################################

#Read in the data we got from the other script from my local hard drive
ptm <- proc.time()

flightData <- data.table::fread("G:\\My Drive\\Northwestern\\455 Data Viz\\The Show\\Data\\flightData.csv")

proc.time() - ptm

