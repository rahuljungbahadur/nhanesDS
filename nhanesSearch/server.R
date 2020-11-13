#

# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("libraries.R")
source("functions.R")
#source("functions.R")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    
    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })
    # output$printYear <- renderPrint(paste("Selected NHANES survey cycles are",
    #                                       yearChoiceSubset$yearChoices))
    
    supplementDf <- reactiveValues(data = data.table())
    
    observe(supplementDf$data <- func_filterSupplementName(searchTerm = input$searchTerm,
                                                   year = input$year,
                                                   alphabet = yearChoiceDf$LETTERS[yearChoiceDf$yearChoices %in% input$year],
                                                   searchType = input$searchType,
                                                   removeTerm = input$removeTerm))
    

    #browser()
    output$uniqSuppl <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total unique supplements", style = "font-size: 80%;"),
            value = tags$p(nrow(supplementDf$data), style = "font-size: 60%;"),
            width = 4
        )
    )
    
    output$days30Sum <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total 30 days interview weights",style = "font-size: 80%;"),
            value = tags$p(format(round(sum(supplementDf$data$WTINT2YR_sum, na.rm = T)),
                                  big.mark = ","),
                           style = "font-size: 60%;"),
            width = 4,
            icon = icon("user")
            
        )
    )
    
    output$first24Sum <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total first 24 Hr weights",style = "font-size: 80%;"),
            value = tags$p(format(round(sum(supplementDf$data$WTDRD1_sum, na.rm = T)),
                                  big.mark = ","),
                           style = "font-size: 60%;"),
            width = 4,
            icon = icon("user")
            
        )
    )
    
    output$second24Sum <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total second 24 Hr weights", style = "font-size: 80%;"),
            value = tags$p(format(round(sum(supplementDf$data$WTDR2D_sum, na.rm = T)),
                                  big.mark = ","),
                           style = "font-size: 60%;"),
            width = 4,
            icon = icon("user")
        )
    )
    
    output$uniqBrand <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total unique brands", style = "font-size: 80%;"),
            value = tags$p(supplementDf$data %>%
                               ungroup() %>%
                               select(brandName) %>%
                               distinct() %>%
                               count(),
                           style = "font-size: 60%;"),
            width = NULL
        )
    )
    

    output$searchedSupplement <- 
        renderDT(datatable(supplementDf$data,
                 colnames = c("SupplementID",
                              "SupplementName",
                              "BrandName",
                              "30DayWeights",
                              "First24HrWeights",
                              "Sec24HrWeights")) %>%
        formatRound(columns = c(4,5,6),
                    digits = 0,
                    interval = 3,
                    mark = ",")
        )
    
    ## Download button
    output$downloadSupplement <- downloadHandler(
        filename = function() {
            paste0("downloadSupplement", Sys.Date(), ".xlsx")
        },
        content = function(file) {
            #write.csv(ingrid_counts_list$data, file, row.names = FALSE)
            write_xlsx(supplementDf$data, path = file)
        }
        
    )
    
    output$pctFirst24Wt <- flexdashboard::renderGauge({
        index = input$searchedSupplement_rows_selected 
        flexdashboard::gauge(value = round(
            sum(supplementDf$data$WTDRD1_sum[index], na.rm = T) * 100 /
                sum(supplementDf$data$WTDRD1_sum, na.rm = T), 2),
            min = 0,
            max = 100,
            symbol = "%",
            label = "First 24 Hr\n cummulative weight %"
        )
    }
    )
    
    output$pct30DaysWt <- flexdashboard::renderGauge({
        index = input$searchedSupplement_rows_selected 
        flexdashboard::gauge(value = round(
            sum(supplementDf$data$WTINT2YR_sum[index], na.rm = T) * 100 /
                sum(supplementDf$data$WTINT2YR_sum, na.rm = T), 2),
            min = 0,
            max = 100,
            symbol = "%",
            label = "30 Days interview\n cummulative weight %"
        )
    }
    )
    
    # addPopover(id = "searchType", "title Here", "contentHere", placement = "bottom",
    #            trigger = "hover", options = NULL)
    
    
    output$pctSecond24Wt <- flexdashboard::renderGauge({
        index = input$searchedSupplement_rows_selected 
        flexdashboard::gauge(value = round(
            sum(supplementDf$data$WTDR2D_sum[index], na.rm = T) * 100 /
                sum(supplementDf$data$WTDR2D_sum, na.rm = T), 2),
            min = 0,
            max = 100,
            symbol = "%",
            label = "Second 24 Hr\n cummulative weight %"
        )
    }
    )
    
    output$downloadIngredient <- downloadHandler(
        filename = function() {
            paste0("downloadIngredient", Sys.Date(), ".xlsx")
        },
        content = function(file) {
            #write.csv(ingrid_counts_list$data, file, row.names = FALSE)
            supplementDf$data %>% left_join(dsIngredientFile %>% 
                                                select(-DSDSUPP), by = "DSDPID") %>%
            write_xlsx(path = file)
        }
        
    )
    

})
