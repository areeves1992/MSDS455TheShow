#Cool intro comments go here but I'll come back to those.


###########################################
######### INSTALL PACKAGES ################
#Uncomment the section below if you need the packages
#or if your code errors out.

#install.packages("data.table")

####

library(data.table)


######### END OF INSTALL PACKAGES ##########
############################################

###########################################
######### FUNCTION DECLARATIONS ###########


fetchData <- function(yearOfData, monthOfData){
  
  fileURL <- paste0('https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_',yearOfData,'_', monthOfData, '.zip')
  
  #fileURL <- 'https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_2022_4.zip'
  
  download.file(fileURL, temp)
  
  unzip(temp, exdir = paste0(getwd(),"\\Data"))
  
  fileToReadIn <- paste0(paste0(getwd(),"\\Data") ,"\\", list.files(paste0(getwd(),"\\Data"), pattern = "On_"))
  
  flightDataTemp <- fread(fileToReadIn)
  
  file.remove(fileToReadIn)
  
  fwrite(flightDataTemp, paste0(paste0(getwd(),"\\Data") ,"\\","flightData.csv"), append = TRUE)
  
}#end of function fetchData



######END OFFUNCTION DECLARATIONS #########
###########################################



#You will have to change this to make it work on your machine.
workingDir <- 'C:\\Users\\areev\\MSDS455TheShow'

setwd(workingDir)

temp <- tempfile()

#gui version: https://www.transtats.bts.gov/DL_SelectFields.aspx?gnoyr_VQ=FGJ&QO_fu146_anzr=b0-gvzr

yearOfData <- 1988

monthOfData <- 1


