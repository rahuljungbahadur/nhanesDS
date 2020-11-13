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
        sidebarMenu(
            # Setting id makes input$tabs give the tabName of currently-selected tab
            id = "tabs",
            menuItem("Search Supplement", tabName = "searchSupplement", icon = icon("search"))
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
                                switchInput(inputId = "searchType",
                                            label = "Type of search",
                                            onLabel = "OR",
                                            offLabel = "AND",
                                            offStatus = "info",
                                            inline = T,
                                            value = F,
                                            size = "small",
                                            #labelWidth = "500px",
                                            width = "100%"
                                ),
                                bsTooltip("searchType", "The wait times will be broken into this many equally spaced bins",
                                          "right", options = list(container = "body")),
                                HTML("<hr>"),
                                searchInput(
                                    inputId = "searchTerm",
                                    label = "Terms to include in supplement name",
                                    value = "",
                                    placeholder = "Eg: calcium,antacid"
                                ),
                                searchInput(
                                    inputId = "removeTerm",
                                    label = "Terms to remove",
                                    value = NA,
                                    placeholder = "Eg: Antacid,Gummy"
                                )
                            )
                        ),
                        column(
                            width = 6,
                            box(
                                width = NULL,
                                title = "Select survey cycles",
                                footer = tags$p("Selecting multiple survey cycles combines the weights according to NHANES procedure",
                                                tags$a(href = "https://wwwn.cdc.gov/nchs/nhanes/tutorials/module3.aspx", "Click here for NHANES document!"),
                                                style = "font-size: 60%;"),
                                sliderTextInput(
                                    inputId = "year",
                                    label = "Year",
                                    choices = yearChoiceDf[["yearChoices"]],
                                    selected = c("2013-2014", "2015-2016"),
                                    dragRange = T,
                                    grid = T,
                                    force_edges = T
                                ),
                                column(
                                    width = 12,
                                    flexdashboard::gaugeOutput(outputId = "pct30DaysWt",
                                                              height = "120px")
                                ),
                                column(
                                    width = 6,
                                    flexdashboard::gaugeOutput(outputId = "pctFirst24Wt",
                                                               height = "120px")
                                ), column(
                                    width = 6,
                                    flexdashboard::gaugeOutput(outputId = "pctSecond24Wt",
                                                               height = "120px")
                                )
                            )
                        ),
                        column(
                            width = 3,
                            
                            fluidRow(
                                column(
                                    width = 6,
                                    valueBoxOutput(outputId = "uniqSuppl",
                                                   width = NULL)
                                ),
                                column(
                                    width = 6,
                                    valueBoxOutput(outputId = "uniqBrand",
                                                   width = NULL)
                                )
                            ),
                            fluidRow(
                                valueBoxOutput(outputId = "days30Sum",
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
                    DTOutput(outputId = "searchedSupplement"),
                    downloadBttn(outputId = "downloadSupplement",
                                   label = "Download supplement info",
                                 size = "sm",
                                 style = "jelly"),
                    downloadBttn(outputId = "downloadIngredient",
                                 label = "Download Ingredient info",
                                 size = "sm",
                                 style = "jelly")
                )
            )
        )
    )

header <- dashboardHeader(
    title = "NHANES dietary supplement",
    titleWidth = "300px"
)

dashboardPage(
    header = header,
    sidebar = sidebar,
    body = body)