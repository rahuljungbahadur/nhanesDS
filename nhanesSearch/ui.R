#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("libraries.R")
source("functions.R")


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
                fluidPage(
                    fluidRow(
                        column(
                            width = 3,
                            box(
                                width = NULL,
                                title = "Filter Supplements",
                                footer = "You can filter Supplement Names as well as the year",
                                searchInput(
                                    inputId = "searchTerm",
                                    label = "Search in supplement name",
                                    value = "",
                                    placeholder = "Eg: Cranberry"
                                )
                            )
                        ),
                        column(
                            width = 6,
                            box(
                                width = NULL,
                                title = "Select survey cycles",
                                footer = "weights are combined if multiple survey cycles are selected",
                                sliderTextInput(
                                    inputId = "year",
                                    label = "Year",
                                    choices = yearChoiceDf[["yearChoices"]],
                                    selected = c("2013-2014", "2015-2016"),
                                    dragRange = T,
                                    grid = T,
                                    force_edges = T
                                )
                                #verbatimTextOutput(outputId = "printYear")
                            )
                        ),
                        column(
                            width = 3,
                            
                            fluidRow(
                                valueBoxOutput(outputId = "uniqSuppl",
                                                   width = NULL),
                                valueBoxOutput(outputId = "uniqBrand",
                                                   width = NULL)
                            ),
                            fluidRow(
                                valueBoxOutput(outputId = "first24Sum",
                                               width = NULL)
                            ),
                            fluidRow(
                                valueBoxOutput(outputId = "second24Sum",
                                               width = NULL)
                            )
                            
                        )
                    ),
                    DTOutput(outputId = "searchedSupplement")
                )
            )
        )
    )

dashboardPage(
    header = dashboardHeader(),
    sidebar = sidebar,
    body = body)