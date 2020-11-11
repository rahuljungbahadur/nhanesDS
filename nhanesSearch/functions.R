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



func_filterSupplementName <- function(searchTerm, year, alphabet) {
  
  ## Preprocess the search term - replace comma by pipe for searching 'OR' terms.
  searchTerm <- str_replace(searchTerm, pattern = ",\\s{0,}", replacement = "|") %>%
    #str_remove_all(pattern = " ") %>%
    trimws() %>%
    toupper()
  
  yearChoiceSubset <<- yearChoiceDf %>% 
    slice(
      which(
        yearChoiceDf$yearChoices == year[1]):which(yearChoiceDf$yearChoices == year[2]
                                                        )
      )
  
  #browser()
  dsInterviewFile <- data.table()
  for (i in 1:nrow(yearChoiceSubset)) {
    dsInterviewFile <- bind_rows(dsInterviewFile,
                                 func_readInterviewFile(
                                   year = yearChoiceSubset$yearChoices[i],
                                   alphabet = yearChoiceSubset$LETTERS[i])
                                 )
  }
  
  

  outputDf <- dsProductFile %>%
    filter(str_detect(DSDSUPP, pattern = regex(searchTerm, ignore_case = T))) %>%
    inner_join(dsInterviewFile, by = c("DSDSUPID")) %>%
    select(DSDSUPID, DSDSUPP.x, brandName, WTDRD1, WTDR2D) %>%
    group_by(DSDSUPID, DSDSUPP.x, brandName) %>%
    summarise(across(where(is.numeric),
                     .fns = list(sum = ~sum(.x, na.rm = T)/nrow(yearChoiceSubset)),
                     .groups = "keep"
                     )) %>%
    arrange(desc(WTDRD1_sum), desc(WTDR2D_sum)) %>%
    rename(DSDSUPP = DSDSUPP.x)

  return(outputDf)
}


