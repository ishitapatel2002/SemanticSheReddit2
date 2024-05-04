
library(shiny)
library(shinyWidgets)
library(wordcloud2)
ui <- fluidPage(
  titlePanel("Reddit Gender Discourse Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("subreddit", "Choose a Subreddit:", 
                  choices = c("Feminism", "TwoXChromosomes", "AskWomen", 
                              "TheRedPill", "MensRights", "AskMen", "MensLib",
                              "news", "worldnews", "AskReddit")),
      actionButton("goButton", "Analyze", icon = icon("search"))
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Summary", tableOutput("summaryOutput")),
                  tabPanel("Word Cloud", wordcloud2Output("wordCloudOutput")),
                  tabPanel("Sentiment Analysis", plotOutput("sentimentPlot"))
      )
    )
  )
)
