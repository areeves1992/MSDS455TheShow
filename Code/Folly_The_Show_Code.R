#Cool intro comments go here but I'll come back to those.


###########################################
######### INSTALL PACKAGES ################
#Uncomment the section below if you need the packages
#or if your code errors out.

#install.packages("data.table")
#install.packages("dplyr")
####

library(data.table)

library(dplyr)


######### END OF INSTALL PACKAGES ##########
############################################

###########################################
######### FUNCTION DECLARATIONS ###########

#I need to document this function
fetchData <- function(yearOfData, monthOfData){
  
  flightData <- fread(paste0(getwd(),"\\Data\\flightData.csv"))
  
  dataCheck <- flightData %>% dplyr::filter(Year == yearOfData, Month == monthOfData)
  
  if(nrow(dataCheck) > 0){
    print(paste0("Already downloaded year ", yearOfData, " and month ", monthOfData,". Moving to next iteration."))
    
    return()
    
  }else{
  
    temp <- tempfile()
  
    fileURL <- paste0('https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_',yearOfData,'_', monthOfData, '.zip')
  
    #fileURL <- 'https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_2022_4.zip'
  
    download.file(fileURL, temp)
  
    unzip(temp, exdir = paste0(getwd(),"\\Data"))
  
    fileToReadIn <- paste0(paste0(getwd(),"\\Data") ,"\\", list.files(paste0(getwd(),"\\Data"), pattern = "On_"))
  
    flightDataTemp <- fread(fileToReadIn)
  
    file.remove(fileToReadIn)
  
    fwrite(flightDataTemp, paste0(paste0(getwd(),"\\Data") ,"\\","flightData.csv"), append = TRUE)
  
    return()
  }
}#end of function fetchData



######END OFFUNCTION DECLARATIONS #########
###########################################

###########################################
######START OF THE CODE ###################
###########################################

#You will have to change this to make it work on your machine.
workingDir <- 'C:\\Users\\areev\\MSDS455TheShow'

setwd(workingDir)


#gui version: https://www.transtats.bts.gov/DL_SelectFields.aspx?gnoyr_VQ=FGJ&QO_fu146_anzr=b0-gvzr

#Set the variables to the start of the data - 1988 and 01/January
yearToFetch <- 1988

monthToFetch <- 1

#While the year is less than 2023 as the data don't exisit in the future
while(yearToFetch < 2023){
  
  #While we have not iterated paste 12 or December
  while(monthToFetch <= 12){
    
    #Print a message to the user
    print(paste0("Currently fetching year: ", yearToFetch, " and month: ", monthToFetch))
    
    #Fetch, download, and append the data.
    #fetchData(yearOfData = yearToFetch, monthOfData = monthToFetch)
    
    #Iterate through the months increase them by one.
    monthToFetch <- monthToFetch + 1
    
    #edit this if when new data become available
    if(yearToFetch == 2022 & monthToFetch == 8){
      print("Stopping fetching as there is no more data.")
      break()
      
    }#end of data checking if
      
  }#End of month while
    

  #If the month is December/12, reset this variable to January or 1
  if(monthToFetch > 12){
    print("in the if")
    monthToFetch <- 1
  }#end of if
  
  #Iterate through the years, increase the year by one
  yearToFetch <- yearToFetch + 1
  
    
}#End of the entire while loop


