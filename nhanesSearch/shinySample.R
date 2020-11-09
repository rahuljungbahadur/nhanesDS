## Only run examples in interactive R sessions
if (interactive()) {
  
  # basic example
  shinyApp(
    ui = fluidPage(
      selectInput("variable", "Variable:",
                  c("Cylinders" = "cyl",
                    "Transmission" = "am",
                    "Gears" = "gear")),
      tableOutput("data")
    ),
    server = function(input, output) {
      output$data <- renderTable({
        mtcars[, c("mpg", input$variable), drop = FALSE]
      }, rownames = TRUE)
    }
  )
  
  # demoing group support in the `choices` 
  shinyApp(
    ui = fluidPage(
      selectInput("state", "Choose a state:",
                  multiple = T,
      ),
      textOutput("result")
    ),
    server = function(input, output) {
      output$result <- renderText({
        paste("You chose", input$state)
      })
    }
  )
}