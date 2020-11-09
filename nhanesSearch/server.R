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
    output$printYear <- renderPrint(input$year)
    output$searchedSupplement <- 
        renderDT(func_filterSupplementName(input$searchTerm, input$year,
                                           yearChoiceDf$LETTERS[yearChoiceDf$yearChoices %in% input$year]),
                 colnames = c("SupplementID",
                              "SupplementName",
                              "First24HrWeights",
                              "Sec24HrWeights"))

})
