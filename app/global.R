library(httr)
library(jsonlite)
library(tm)
library(dplyr)
library(tidytext)
library(syuzhet)

subreddits_women <- c("Feminism", "TwoXChromosomes", "AskWomen")
subreddits_men <- c("TheRedPill", "MensRights", "AskMen", "MensLib")
subreddits_neutral <- c("news", "worldnews", "AskReddit")

fetch_reddit_data <- function(subreddit_vector, terms, limit = 500, sort = "desc", sort_type = "created_utc") {
  all_posts <- list()
  
  for (subreddit in subreddit_vector) {
    base_url <- "https://api.pullpush.io/reddit/search/submission/"
    params <- list(
      q = terms,
      subreddit = subreddit,
      size = limit,
      sort = sort,
      sort_type = sort_type
    )
    
    response <- GET(url = base_url, query = params, user_agent("SemanticSheReddit2/0.1"))
    if (status_code(response) == 200) {
      data <- fromJSON(rawToChar(response$content), flatten = TRUE)
      all_posts[[subreddit]] <- data$data
    } else {
      message("Failed to fetch data for subreddit: ", subreddit, " Status code: ", status_code(response))
    }
  }
  
  return(all_posts)
}

# collect data
posts_women <- fetch_reddit_data(subreddits_women, "women")
posts_men <- fetch_reddit_data(subreddits_men, "men")
posts_neutral <- fetch_reddit_data(subreddits_neutral, "")


# save data  to RDS
saveRDS(posts_women, file = "posts_women.rds")
saveRDS(posts_men, file = "posts_men.rds")
saveRDS(posts_neutral, file = "posts_neutral.rds")

posts_women <- readRDS("posts_women.rds")
posts_men <- readRDS("posts_men.rds")
posts_neutral <- readRDS("posts_neutral.rds")

create_word_freq_df <- function(posts) {
  words <- tolower(unlist(strsplit(posts$title, "\\s+")))
  words <- removePunctuation(words)
  words <- words[!words %in% stopwords("en")]
  words <- words[words != "" & !grepl("^[0-9]+$", words)]
  
  word_freq <- table(words)
  word_freq_df <- as.data.frame(word_freq, stringsAsFactors = FALSE)
  word_freq_df <- word_freq_df %>% arrange(desc(Freq)) %>% rename(word = words, freq = Freq)
  return(word_freq_df)
}

#save word frequencies as rds files
save_word_freq <- function(subreddit_data, filename) {
  word_freq_df <- create_word_freq_df(subreddit_data)
  saveRDS(word_freq_df, filename)
}

# save for all subreddits
save_word_freq(posts_women[["Feminism"]], "feminism_freq.rds")
save_word_freq(posts_women[["TwoXChromosomes"]], "twoxchromosomes_freq.rds")
save_word_freq(posts_women[["AskWomen"]], "askwomen_freq.rds")
save_word_freq(posts_men[["TheRedPill"]], "theredpill_freq.rds")
save_word_freq(posts_men[["MensRights"]], "mensrights_freq.rds")
save_word_freq(posts_men[["AskMen"]], "askmen_freq.rds")
save_word_freq(posts_men[["MensLib"]], "menslib_freq.rds")
save_word_freq(posts_neutral[["news"]], "news_freq.rds")
save_word_freq(posts_neutral[["worldnews"]], "worldnews_freq.rds")
save_word_freq(posts_neutral[["AskReddit"]], "askreddit_freq.rds")


# for easy access in server.R
precomputed_freqs <- list(
  "Feminism" = readRDS("feminism_freq.rds"),
  "TwoXChromosomes" = readRDS("twoxchromosomes_freq.rds"),
  "AskWomen" = readRDS("askwomen_freq.rds"),
  "TheRedPill" = readRDS("theredpill_freq.rds"),
  "MensRights" = readRDS("mensrights_freq.rds"),
  "AskMen" = readRDS("askmen_freq.rds"),
  "MensLib" = readRDS("menslib_freq.rds"),
  "news" = readRDS("news_freq.rds"),
  "worldnews" = readRDS("worldnews_freq.rds"),
  "AskReddit" = readRDS("askreddit_freq.rds")
)



