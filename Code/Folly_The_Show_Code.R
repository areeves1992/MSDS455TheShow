#Cool intro comments go here but I'll come back to those.


#You will have to change this to make it work on your machine.
workingDir <- 'C:\\Users\\areev\\MSDS455TheShow'

setwd(workingDir)

temp <- tempfile()

fileURL <- 'https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_2022_4.zip'

download.file(fileURL, temp)

unzip(temp, exdir = paste0(getwd(),"\\Data"))
