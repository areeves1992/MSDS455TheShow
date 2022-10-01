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



#You will have to change this to make it work on your machine.
workingDir <- 'C:\\Users\\areev\\MSDS455TheShow'

setwd(workingDir)



#gui version: https://www.transtats.bts.gov/DL_SelectFields.aspx?gnoyr_VQ=FGJ&QO_fu146_anzr=b0-gvzr

yearToFetch <- 1988

monthToFetch <- 1

fetchData(yearOfData = yearToFetch, monthOfData = monthToFetch)
