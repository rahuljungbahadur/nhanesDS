source("libraries.R")

readPath <- "../dataFiles/"

## 24 hours interview file
func_readInterviewFile <- function(year, alphabet) {
  

  if (file.exists(paste0(readPath, "dsInterview", year, ".csv"))) {
    dsInterview <- fread(paste0(readPath, "dsInterview", year, ".csv"))#, key = "DSDSUPID")
  } else {
    #browser()
    dsInterview <- read_xpt(
      file = paste0("https://wwwn.cdc.gov/Nchs/Nhanes/",
                    year,
                    "/DS1IDS_",
                    alphabet, 
                    ".XPT")
    ) %>%
      as.data.table() ##Removed key = "DSDSUPID"
    write.csv(dsInterview, paste0(readPath, "dsInterview", year, ".csv"), row.names = F)
  }
  
  dsInterview %<>% select(SEQN, DSDPID, WTDRD1, WTDR2D)
  
  return(dsInterview)
}

#brandNames <- read_rds("BrandNames.RDS")

## Product information file - This file is updated every year to include newer products
func_readProductFile <- function() {
  
  if (file.exists(paste0(readPath, "dsProduct.csv"))) {

    dsProduct <- fread(paste0(readPath, "dsProduct.csv"))#, key = c("DSDSUPID", "DSDPID"))
    
  } else {
    dsProduct <- read_xpt(
      file = "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSPI.XPT"
    ) %>% as.data.table()
    #write.csv(dsProduct, paste0(readPath, "dsProduct.csv"), row.names = F)
  }
  return(dsProduct)
}

## Ingredient Information file - This file is updated every survey cycle to include latest product

func_readIngredientFile <- function() {
  
  if (file.exists(paste0(readPath, "dsIngredientInfo.csv"))) {
    dsIngredient <- fread(paste0(readPath, "dsIngredientInfo.csv"))#, key = "DSDPID")
  } else {
    dsIngredient <- read_xpt(
      file = "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DSII.XPT"
    ) %>% as.data.table() ## Removed key = "DSDPID"
    write.csv(dsIngredient, paste0(readPath, "dsIngredientInfo.csv"), row.names = F)
  }
  
  return(dsIngredient)
}

## 30 Day interview period - 
func_read30DayInterview <- function(year, alphabet) {
   
   #browser()
   if (file.exists(paste0(readPath, "day30Interview", year, ".csv"))) {
     ds30DayInterview <- fread(paste0(readPath, "day30Interview", year, ".csv"))#, key = "DSDSUPID")
   } else {
     #browser()
     ds30DayInterview <- read_xpt(
       file = paste0("https://wwwn.cdc.gov/Nchs/Nhanes/",
                     year,
                     "/DSQIDS_",
                     alphabet,
                     ".XPT")
     ) %>%
       as.data.table() ##Removed key = "DSDSUPID"
     write.csv(ds30DayInterview, paste0(readPath, "day30Interview", year, ".csv"), row.names = F)
   }
   
   ds30DayInterview %<>%
     left_join(
       func_readDemoFile(year, alphabet) %>% 
         select(SEQN, WTINT2YR), by = "SEQN")
   


   return(ds30DayInterview)
 }
 
func_readDemoFile <- function(year, alphabet) {
   if (file.exists(paste0(readPath, "demoFile", year, ".csv"))) {
     demoFile <- fread(paste0(readPath, "demoFile", year, ".csv"))
     #, key = "DSDSUPID")
   } else {
     #browser()
     demoFile <- read_xpt(
       file = paste0("https://wwwn.cdc.gov/Nchs/Nhanes/",
                     year,
                     "/DEMO_",
                     alphabet,
                     ".XPT")
     ) %>%
       as.data.table() ##Removed key = "DSDSUPID"
     write.csv(demoFile, paste0(readPath, "demoFile", year, ".csv"), row.names = F)
   }
   
   demoFile %<>% 
     select(SEQN, WTINT2YR)
   
   
   return(demoFile)
 }

