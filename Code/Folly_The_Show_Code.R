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

#You will have to change this to make it work on your machine.
workingDir <- 'C:\\Users\\areev\\MSDS455TheShow'

setwd(workingDir)

temp <- tempfile()

#gui version: https://www.transtats.bts.gov/DL_SelectFields.aspx?gnoyr_VQ=FGJ&QO_fu146_anzr=b0-gvzr

fileURL <- paste0('https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_','2022','_', '4', '.zip')

#fileURL <- 'https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_2022_4.zip'

download.file(fileURL, temp)

unzip(temp, exdir = paste0(getwd(),"\\Data"))

fileToReadIn <- paste0(paste0(getwd(),"\\Data") ,"\\", list.files(paste0(getwd(),"\\Data"), pattern = "On_"))

flightData <- fread(fileToReadIn)