source("libraries.R")
source("readNHANES.R")
## Function for returning supplements containing 'searchTerm' in their name

## Saving all files
dsProductFile <- func_readProductFile()
dsIngredientFile <- func_readIngredientFile()



func_filterSupplementName <- function(searchTerm, year, letter) {
  
  ## Preprocess the search term - replace comma by pipe for searching 'OR' terms.
  searchTerm <- str_replace(searchTerm, pattern = ",", replacement = "|") %>%
    str_remove_all(pattern = " ") %>%
    trimws() %>%
    toupper()
  
  #browser()
  dsInterviewFile <- func_readInterviewFile(year = year[2], letter = letter[2])
  
  dsProductFile %>%
    filter(str_detect(DSDSUPP, pattern = regex(searchTerm, ignore_case = T))) %>%
    inner_join(dsInterviewFile, by = "DSDSUPID") %>%
    select(DSDSUPID, DSDSUPP.x, WTDRD1, WTDR2D) %>% 
    group_by(DSDSUPID, DSDSUPP.x) %>%
    summarise(across(where(is.numeric), .fns = list(sum = sum), na.rm = T)) %>%
    arrange(desc(WTDRD1_sum), desc(WTDR2D_sum)) %>%
    rename(DSDSUPP = DSDSUPP.x) %>%
    return()
}


