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
  
  #If we already dont have a file called flight data, start it out and download
  if(length(list.files(paste0(getwd(),"\\Data"), pattern = "flightData")) < 1) {
    
    #Create a temp file so we dont take up hard drive space
    temp <- tempfile()
    
    #Create the url using the parameters
    fileURL <- paste0('https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_',yearOfData,'_', monthOfData, '.zip')
    
    #For testing :)
    #fileURL <- 'https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_2022_4.zip'
    
    #Download that file to the temp file
    download.file(fileURL, temp)
    
    #unzip in the Data dir
    unzip(temp, exdir = paste0(getwd(),"\\Data"))
    
    #Create the file path to read it in
    fileToReadIn <- paste0(paste0(getwd(),"\\Data") ,"\\", list.files(paste0(getwd(),"\\Data"), pattern = "On_"))
    
    #Read it in quickly
    flightDataTemp <- fread(fileToReadIn)
    
    #Remove the old one. THIS IS NECESSARY AND WILL CAUSE ISSUES IF NOT RUN
    file.remove(fileToReadIn)
    
    #Write/append it to the current flight data csv
    fwrite(flightDataTemp, paste0(paste0(getwd(),"\\Data") ,"\\","flightData.csv"), append = TRUE)
    
    return()
    
    #If we do have a file, we want to make sure we already didn't download this 
    #month and year as this is already an expensive process and we dont want dupes.
    }else{
      
      #Read in the current data csv
      flightData <- fread(paste0(getwd(),"\\Data\\flightData.csv"))
      
      #filter to the current month and year to fetch
      dataCheck <- flightData %>% dplyr::filter(Year == yearOfData, Month == monthOfData)
      
      #Check to see if the data already exisit. If they do, get outta this loop and return
      #to the next iteration
      if(nrow(dataCheck) > 0){
        print(paste0("Already downloaded year ", yearOfData, " and month ", monthOfData,". Moving to next iteration."))
        
        return()
      
      #If the data dont already exist start downloading and appending it.  
      }else{
        #Create a temp file so we dont take up hard drive space
        temp <- tempfile()
        
        #Create the url using the parameters
        fileURL <- paste0('https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_',yearOfData,'_', monthOfData, '.zip')
  
        #For testing :)
        #fileURL <- 'https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_2022_4.zip'
  
        #Download that file to the temp file
        download.file(fileURL, temp)
  
        #unzip in the Data dir
        unzip(temp, exdir = paste0(getwd(),"\\Data"))
        
        #Create the file path to read it in
        fileToReadIn <- paste0(paste0(getwd(),"\\Data") ,"\\", list.files(paste0(getwd(),"\\Data"), pattern = "On_"))
  
        #Read it in quickly
        flightDataTemp <- fread(fileToReadIn)
  
        #Remove the old one. THIS IS NECESSARY AND WILL CAUSE ISSUES IF NOT RUN
        file.remove(fileToReadIn)
  
        #Write/append it to the current flight data csv
        fwrite(flightDataTemp, paste0(paste0(getwd(),"\\Data") ,"\\","flightData.csv"), append = TRUE)
  
        #Return and get outta this iteration
        return()
      }#end of inner else
      
  }#end of outer else
  
}#end of function fetchData



######END OF FUNCTION DECLARATIONS ########
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

#While the year is less than 2023 as the data don't exist in the future
while(yearToFetch < 2023){
  
  #While we have not iterated paste 12 or December
  while(monthToFetch <= 12){
    
    #Print a message to the user
    print(paste0("Currently fetching year: ", yearToFetch, " and month: ", monthToFetch))
    
    #Fetch, download, and append the data.
    fetchData(yearOfData = yearToFetch, monthOfData = monthToFetch)
    
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

    monthToFetch <- 1
  }#end of if
  
  #Iterate through the years, increase the year by one
  yearToFetch <- yearToFetch + 1
  
    
}#End of the entire while loop

print("End of script. :)")
