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
                                                   alphabet = yearChoiceDf$LETTERS[yearChoiceDf$yearChoices %in% input$year]))
    

    #browser()
    output$uniqSuppl <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total unique supplements", style = "font-size: 70%;"),
            value = tags$p(nrow(supplementDf$data), style = "font-size: 60%;"),
            width = 4
        )
    )
    
    output$first24Sum <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total first 24 Hr weights",style = "font-size: 70%;"),
            value = tags$p(round(sum(supplementDf$data$WTDRD1_sum, na.rm = T)), style = "font-size: 60%;"),
            width = 4,
            icon = icon("user")
            
        )
    )
    
    output$second24Sum <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total second 24 Hr weights", style = "font-size: 70%;"),
            value = tags$p(round(sum(supplementDf$data$WTDR2D_sum, na.rm = T)),style = "font-size: 60%;"),
            width = 4,
            icon = icon("user")
        )
    )
    
    output$uniqBrand <- renderValueBox(
        valueBox(
            subtitle = tags$p("Total unique brands", style = "font-size: 80%;"),
            value = tags$p(supplementDf$data %>% select(brandName) %>% count(), style = "font-size: 60%;"),
            width = NULL
        )
    )
    

    output$searchedSupplement <- 
        renderDT(supplementDf$data,
                 colnames = c("SupplementID",
                              "SupplementName",
                              "BrandName",
                              "First24HrWeights",
                              "Sec24HrWeights"))

})
