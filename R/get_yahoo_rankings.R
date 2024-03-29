
#' @export
get_yahoo_rankings <- function(update = FALSE) {
  options(stringsAsFactors = FALSE)

  ranks <- read.csv(file = "data/yahoo_ranks.csv", header = T, stringsAsFactors = F)
  ranks <- ranks[order(ranks[,ncol(ranks)]),]
  colnames(ranks) <- gsub("X", "", colnames(ranks))
  colnames(ranks) <- gsub("\\.", "/", colnames(ranks))

  if(update) {
    YahooFantasyAPI::check_token()
    # YahooFantasyAPI::get_token(readLines("yahoocreds.txt")[1], readLines("yahoocreds.txt")[2])

    yahoorankings <- YahooFantasyAPI::get_player_list(gameid = "414", leagueid = "11036", numPlayers = 300)
    yahoorankings$name <- gsub(" II", "", yahoorankings$name)
    yahoorankings$name <- gsub(" Jr.| Sr.", "", yahoorankings$name)
    yahoorankings$name <- gsub(" V", "", yahoorankings$name)
    yahoorankings$team <- gsub("JAX", "JAC", yahoorankings$team)

    # yahoorankings <- yahoorankings %>% filter(pos != "DEF", pos != "K")
    yahoorankings <- yahoorankings %>% select(-pos)

    yahoorankings$rank <- c(1:nrow(yahoorankings))

    colnames(yahoorankings) <- c("Player", "Team", format(Sys.Date(), "%m/%d"))

    ranks <- merge(ranks, yahoorankings, by = c("Player", "Team"))

    nonunique <- grep("X", colnames(ranks))
    if(length(nonunique) > 0) {
      ranks <- ranks[,-nonunique]
    }

    ranks <- ranks[order(ranks[,ncol(ranks)]),]
    ranks$match <- ranks[,ncol(ranks) - 1] == ranks[,ncol(ranks)]

    if(FALSE %in% ranks$match & ncol(ranks) > 4) {
      write.csv(ranks %>% select(-match), file = "data/yahoo_ranks.csv", row.names = F)
    }
    ranks$match <- NULL
  }

  ranks$Player <- gsub("Melvin Gordon III", "Melvin Gordon", ranks$Player)
  ranks$Player <- gsub(" II", "", ranks$Player)

  return(ranks)
}
