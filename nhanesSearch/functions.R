source("libraries.R")
source("readNHANES.R")
## Function for returning supplements containing 'searchTerm' in their name

## Saving all files
dsProductFile <- func_readProductFile()
dsIngredientFile <- func_readIngredientFile()
yearChoiceSubset <- data.table()

## A list of year pairs for fetching data from NHANES
yearChoices <- vector(6, mode = "character")
yearSeq <- seq(2007, 2018)
i = 0
for (y in 1:length(yearChoices)) {
  yearChoices[y] <- paste(yearSeq[y + i], "-", yearSeq[y + i + 1], sep = "")
  i = i + 1
}

yearChoiceDf <- data.frame(serial = 1:length(yearChoices),
                           yearChoices,
                           LETTERS = LETTERS[5:(4 + length(yearChoices))])
### End of Logic



func_filterSupplementName <- function(searchTerm, year, alphabet,
                                      searchType = TRUE, removeTerm = NA) {
  
  ## Preprocess the search term - replace comma by pipe for searching 'OR' terms.
  # searchTerm <- str_replace(searchTerm, pattern = "\\s{1,}", replacement = "") %>%
  #   #str_remove_all(pattern = " ") %>%
  #   trimws() %>%
  #   toupper()
  
  
  yearChoiceSubset <<- yearChoiceDf %>% 
    slice(
      which(
        yearChoiceDf$yearChoices == year[1]):which(yearChoiceDf$yearChoices == year[2]
                                                        )
      )
  
  ## 30 Days interview data
  ds30DayInterview <- data.table()
  

  for (i in 1:nrow(yearChoiceSubset)) {
    ds30DayInterview <- bind_rows(ds30DayInterview,
                                  func_read30DayInterview(
                                    year = yearChoiceSubset$yearChoices[i],
                                    alphabet = yearChoiceSubset$LETTERS[i]) %>% 
                                    select(SEQN, WTINT2YR, DSDPID)
    )
  }
  
  # ds30DayInterview %<>%
  #   left_join(dsProductFile %>% select(DSDPID), by = "DSDPID")
  
  ds30DayInterview %<>% setkey(DSDPID)
  #browser()
  dsInterviewFile <- data.table()
  for (i in 1:nrow(yearChoiceSubset)) {
    dsInterviewFile <- bind_rows(dsInterviewFile,
                                 func_readInterviewFile(
                                   year = yearChoiceSubset$yearChoices[i],
                                   alphabet = yearChoiceSubset$LETTERS[i])
                                 )
    
    
  }
  
  dsInterviewFile %<>% setkey(DSDPID)
  
  #browser()
  
  
  dsInterviewFile %<>% 
    full_join(ds30DayInterview, by = c("SEQN", "DSDPID"))
  
  dsInterviewFile %<>% 
    inner_join(dsProductFile %>% select(DSDPID, DSDSUPP), by = "DSDPID")
  
  dsInterviewFile %<>% 
    filter(DSDSUPP != "NO PRODUCT INFORMATION AVAILABLE")
  
  #browser()
  
  if (!searchType) {
    searchTerm <- 
      str_replace_all(searchTerm, pattern = "\\s{0,}", replacement = "") %>%
      str_split(pattern = ",", simplify = T) %>%
      toupper() 
    
    
    dsInterviewFile <-
      dsInterviewFile %>%
      filter(
        lapply(
          searchTerm, FUN = grepl, dsInterviewFile$DSDSUPP
        ) %>%
          data.frame() %>%
          apply(MARGIN = 1, FUN = prod) %>%
          as.logical() %>%
          as.vector()
      )

  } else {
    searchTerm <- str_replace(searchTerm, pattern = ",\\s{0,}", replacement = "|") %>%
        trimws() %>%
        toupper()
    
    
    dsInterviewFile %<>% 
      filter(str_detect(DSDSUPP, pattern = regex(searchTerm, ignore_case = T)))
  }
  
  ## remove supplements which have their names matching the 'removeTerm' string
  if (removeTerm != "") {
    removeTerm <- str_replace(removeTerm, pattern = ",\\s{0,}", replacement = "|") %>%
      trimws() %>%
      toupper()
    
    dsInterviewFile %<>% 
      filter(!grepl(pattern = removeTerm, DSDSUPP))
  }
  


  outputDf <- dsProductFile %>% select(-DSDSUPP) %>%
    #filter(str_detect(DSDSUPP, pattern = regex(searchTermAnd, ignore_case = T))) %>%
    inner_join(dsInterviewFile, by = c("DSDPID")) %>%
    select(DSDPID, DSDSUPP, brandName, WTINT2YR, WTDRD1, WTDR2D) %>%
    group_by(DSDPID, DSDSUPP, brandName) %>%
    summarise(across(where(is.numeric),
                     .fns = list(sum = ~sum(.x, na.rm = T)/nrow(yearChoiceSubset)),
                     .groups = "keep"
                     )) %>%
    arrange(desc(WTINT2YR_sum), desc(WTDRD1_sum), desc(WTDR2D_sum))

  return(outputDf)
}


