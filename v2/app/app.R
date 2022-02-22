library(shiny)
library(dplyr)
library(tidyr)
library(DBI)
library(ggplot2)

# Connect to Database
con <- RSQLite::dbConnect(RSQLite::SQLite(), file.path("..", "db.sqlite"))

results <- dbGetQuery(con, "
  SELECT *
  FROM results
") %>%
  tibble()

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      numericInput("seq", label = "Sequence", min = 1, max = 720, step = 1, value = 1),
      sliderInput("rep", label = "Replicate", min = 1, max = 3, step = 1, value = 1),
      sliderInput("statement", label = "Statement", min = 1, max = 38, value = 1),
      radioButtons("batchname", label = "Batch", choices = c("continuous_homophily", "bounded_confidence"), selected = "continuous_homophily")
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  
  output$plot <- renderPlot({
    results %>%
      filter(batchname == input$batchname, seq == input$seq, rep == input$rep, statement_id == input$statement) %>%
      ggplot(aes(x = step, y = position, group = agent_id, color = party)) +
      geom_line() +
      scale_y_continuous(limits = c(-1, 1))
  })
  
  session$onSessionEnded(function(){
    RSQLite::dbDisconnect(conn = con)
    stopApp()
  })
    
}

shinyApp(ui, server)