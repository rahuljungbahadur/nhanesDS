#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("libraries.R")

## A list of year pairs for fetching data from NHANES
yearChoices <- vector(6, mode = "character")
yearSeq <- seq(2007, 2018)
i = 0
for (y in 1:length(yearChoices)) {
    yearChoices[y] <- paste(yearSeq[y + i], "-", yearSeq[y + i + 1], sep = "")
    i = i + 1
}

yearChoiceDf <- data.frame(yearChoices, LETTERS = LETTERS[5:(4 + length(yearChoices))])
### End of Logic

sidebar <- 
    dashboardSidebar(
        sidebarSearchForm(label = "Enter a number", "searchText", "searchButton"),
        sidebarMenu(
            # Setting id makes input$tabs give the tabName of currently-selected tab
            id = "tabs",
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Search Supplement", tabName = "searchSupplement", icon = icon("search")),
            menuItem("Widgets", icon = icon("th"), tabName = "widgets", badgeLabel = "new",
                     badgeColor = "green"),
            menuItem("Charts", icon = icon("bar-chart-o"),
                     menuSubItem("Sub-item 1", tabName = "subitem1"),
                     menuSubItem("Sub-item 2", tabName = "subitem2")
            )
        )
    )

## body

body <- 
    dashboardBody(
        tabItems(
            tabItem(
                tabName = "dashboard",
                sliderInput("bins",
                            "Number of bins:",
                            min = 1,
                            max = 50,
                            value = 30),
                mainPanel(
                    plotOutput("distPlot")
                )
            ),
            tabItem(
                tabName = "searchSupplement",
                box(
                    title = "Filter Supplements",
                    footer = "You can filter Supplement Names as well as the year",
                    searchInput(
                        inputId = "searchTerm",
                        label = "Search in supplement name",
                        value = "",
                        placeholder = "Eg: Cranberry"
                    ),
                    sliderTextInput(
                        inputId = "year",
                        label = "Year",
                        choices = yearChoiceDf[["yearChoices"]],
                        selected = c("2015-2016", "2017-2018"),
                        dragRange = T,
                        grid = T,
                        force_edges = T
                    ),
                    verbatimTextOutput(outputId = "printYear")
                ),
                DTOutput(outputId = "searchedSupplement")
            )
        )
    )

dashboardPage(
    header = dashboardHeader(),
    sidebar = sidebar,
    body = body)