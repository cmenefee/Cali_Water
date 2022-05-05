# install.packages("RPostgreSQL")
require("RPostgreSQL")

# Load the PostgreSQL driver, create a connection to the postgres database
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "cali_water", host = "localhost", port = 5432, user = "ruser", password = "ruser")
sql_string <- paste("SELECT * FROM lab_results WHERE (units = 'mg/L' AND parameter LIKE '%Dissolved%')", sep="")
Lab_Results <- data.frame(dbGetQuery(con, sql_string))

dir.create("/home/daiten/Programming/R/Projects/Water Quality Data/Results/")

# Let's make some overview graphs
for(i in unique(Lab_Results$county_name))
  {
    Working_SQL_String <- paste("SELECT * FROM lab_results WHERE (units = 'mg/L' AND county_name = '",i,"' AND parameter LIKE '%Dissolved%')", sep="")
    Working_Lab_Results <- data.frame(dbGetQuery(con, Working_SQL_String))
    FileDirectory <- paste("/home/daiten/Programming/R/Projects/Water Quality Data/Results/",i,"/", sep="")
    workingwhole <- subset(Working_Lab_Results, Working_Lab_Results$county_name == i)
    
    dir.create(FileDirectory)
    
    if(length(Working_Lab_Results) == 0)
      {
        stop()
        geterrormessage(print(paste("No data found")))
      }
    
    for(ii in unique(workingwhole$parameter))  
      {
        workingparameter <- subset(workingwhole, workingwhole$parameter == ii)
        
        png(paste(FileDirectory, i, "_",ii,"_lab_results.jpg", sep = ""), width = 1000, height = 1000)
        par(mar = c(25, 5, 5, 5))
        # try(plot(workingparameter$sample_date, workingparameter$result, main = paste(ii, "Results"), xlab = "Time", ylab = "mg/L", ylim = range(workingparameter$result)))
        try(plot(workingparameter$sample_date, workingparameter$result, 
                 main = paste(ii, "Results"), 
                 xlab = "Time", 
                 ylab = "mg/L", 
                 ylim = range(min(workingparameter$result, na.rm = TRUE):max(workingparameter$result, na.rm = TRUE)), 
                 xlim = range(workingparameter$sample_date)))
        dev.off()
      }
  }

# Let's make the one-year-at-a-time graphs.
for(i in unique(Lab_Results$county_name))
  {
    Working_SQL_String <- paste("SELECT * FROM lab_results WHERE (units = 'mg/L' AND county_name = '",i,"' AND parameter LIKE '%Dissolved%')", sep="")
    Working_Lab_Results <- data.frame(dbGetQuery(con, Working_SQL_String))
    FileDirectory <- paste("/home/daiten/Programming/R/Projects/Water Quality Data/Results/",i,"/", sep="")
    
    dir.create(FileDirectory)
    
    if(length(Working_Lab_Results) == 0)
      {
        stop()
        geterrormessage(print(paste("No data found")))
      }
    
    startstopyears <- range(format(Working_Lab_Results$sample_date, format = "%Y"))
    totalrange <- (startstopyears[1]:startstopyears[2])
    
    for(ii in totalrange)
      {
        FileDirectory <- paste("/home/daiten/Programming/R/Projects/Water Quality Data/Results/",i,"/",ii,"_Results/", sep="")
        workingyear <- subset(Working_Lab_Results, format(Working_Lab_Results$sample_date, format = "%Y") == ii)
        
        dir.create(FileDirectory)
        
        for(iii in unique(workingyear$parameter))
          {
            workingparameter <-  subset(workingyear, workingyear$parameter == iii)
            
            png(paste(FileDirectory, ii, "_",iii,"_lab_results.jpg", sep = ""), width = 1000, height = 1000)
            par(mar = c(25, 5, 5, 5))
            try(plot(workingparameter$sample_date, workingparameter$result, main = paste(iii, ii, "Results"), xlab = "Month", ylab = "mg/L", ylim = range(workingparameter$result)))
            dev.off()
          }
      }
  }
    
