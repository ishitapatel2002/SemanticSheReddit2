server <- function(input, output, session) {
  posts_women <- readRDS("posts_women.rds")
  posts_men <- readRDS("posts_men.rds")
  posts_neutral <- readRDS("posts_neutral.rds")
  
  # reactive data frame that depends on the input
  data_selected <- reactive({
    switch(input$subreddit,
           "Feminism" = posts_women[["Feminism"]],
           "TwoXChromosomes" = posts_women[["TwoXChromosomes"]],
           "AskWomen" = posts_women[["AskWomen"]],
           "TheRedPill" = posts_men[["TheRedPill"]],
           "MensRights" = posts_men[["MensRights"]],
           "AskMen" = posts_men[["AskMen"]],
           "MensLib" = posts_men[["MensLib"]],
           "news" = posts_neutral[["news"]],
           "worldnews" = posts_neutral[["worldnews"]],
           "AskReddit" = posts_neutral[["AskReddit"]])
  })
  
  # Summary output
  output$summaryOutput <- renderTable({
    req(data_selected())
    data <- data_selected()
    summary_data <- data.frame(
      Total_Posts = nrow(data),
      Average_Score = round(mean(as.numeric(data$score), na.rm = TRUE), 2),
      Average_Number_of_Comments = round(mean(as.numeric(data$num_comments), na.rm = TRUE), 2)
    )
    
    colnames(summary_data) <- c("Total Posts", "Average Score", "Average Number of Comments")
    
    summary_data
  })
  
  
  # Wordcloud output
  output$wordCloudOutput <- renderWordcloud2({
    req(input$subreddit)
    word_freq_df <- precomputed_freqs[[input$subreddit]]
    if (is.null(word_freq_df) || nrow(word_freq_df) == 0 || !is.numeric(word_freq_df$freq)) {
      return("No data to display or data is not numeric.")
    }
    wordcloud2(word_freq_df, size = 1)
  })
  
  # Sentiment analysis
  output$sentimentPlot <- renderPlot({
    req(data_selected())
    data <- data_selected()
    sentiments <- get_nrc_sentiment(paste(data$title, collapse=" "))
    barplot(colSums(sentiments), las = 2, col = rainbow(10),
            main = "Sentiment Analysis of Posts", xlab = "Sentiment", ylab = "Count")
  })
}
