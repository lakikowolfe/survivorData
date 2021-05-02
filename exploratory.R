install.packages("rvest")
library(rvest)
library(tidyverse)

# html for the recurring challenges page on the survivor fan wiki
survivor <- read_html("https://survivor.fandom.com/wiki/Category:Recurring_Challenges")

# pull in recurring challenge names
challenges_recurring_title <- survivor %>%
  html_elements(".category-page__member-link") %>%
  html_attr("title")

challenges_recurring_href <- survivor %>%
  html_elements(".category-page__member-link") %>%
  html_attr("href")

# create challengeData df
challengeData <- tibble(name = challenges_recurring_title, href = challenges_recurring_href)

# create function to pull data from each challenege page
getSurvivorChallengeData <- function(challengeData) {
  base <- "https://survivor.fandom.com/"
  urls <- paste0(base, challengeData$href)
  res <- lapply(urls, function(x) {
    html <- read_html(x)
    tst <- html %>%
      html_elements("table") %>%
      html_table()
  })
  # pull out first table for each challenge
  recurringChallengeList <- map(res, 1)
  names(recurringChallengeList) <- challengeData$name
  return(recurringChallengeList)
}
# pull data
recurringChallengeList <- getSurvivorChallengeData(challengeData)

lapply(recurringChallengeList, dim)


# pull out episode list
episodeList <- map(recurringChallengeList, "Episode")

### helper functions

# parse Episode columm
episodeCol <- function(episodeCol) {
  episodeInfo <- data.frame(str_split(episode, "\"", 2, simplify = TRUE))
  names(episodeInfo) <- c("season", "episode")
  episodeInfo$episode <- gsub(".{1}$", "", episodeInfo$episode)
}

