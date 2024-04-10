library(httr)
library(jsonlite)

subreddits_women <- c("Feminism", "TwoXChromosomes", "AskWomen")
subreddits_men <- c("TheRedPill", "MensRights", "AskMen", "MensLib")
subreddits_neutral <- c("news", "worldnews", "AskReddit")

fetch_reddit_data <- function(subreddit_vector, terms, limit = 100, sort = "desc", sort_type = "created_utc") {
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


