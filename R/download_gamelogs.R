
#' @export
download_gamelogs <- function(year = 2020) {

  t <- readLines(paste0("https://www.pro-football-reference.com/years/", year, "/fantasy.htm"))
  t <- t[grep("<tr ><th scope=\"row\" class=\"right \" data-stat=\"ranker\"", t)]
  player <- unlist(lapply(t, function(x) {
    return(strsplit(strsplit(x, ".htm\\\">")[[1]][2], "<")[[1]][1])
  }))
  position <- unlist(lapply(t, function(x) {
    return(strsplit(strsplit(strsplit(x, "data-stat=\"fantasy_pos\"")[[1]][2], ">")[[1]][2], "<")[[1]][1])
  }))
  link <- unlist(lapply(t, function(x) {
    return(paste0("https://www.pro-football-reference.com", strsplit(strsplit(x, "a href=\"")[[1]][2], ".htm")[[1]][1], "/gamelog/", year))
  }))

  t <- data.frame(cbind(player, position, link), stringsAsFactors = F)

  gamelogs <- plyr::ldply(t$link, function(x) {
    a <- readLines(x)
    a <- a[grep("<td class=\"left \" data-stat=\"game_date\" >", a)]
    a <- strsplit(a, "data-stat=\"")
    a <- plyr::ldply(a, function(y) {
      b <- y[c(4:length(y))]
      stats <- unlist(lapply(b, function(x) strsplit(x, "\"")[[1]][1]))
      b <- unlist(lapply(b, function(x) strsplit(x, " >")[[1]][2]))
      b <- unlist(lapply(b, function(x) strsplit(x, "<")[[1]][1]))
      b <- data.frame(matrix(unlist(b), nrow=1, byrow=T))
      colnames(b) <- stats
      b <- b %>% select(-age, -team, -game_location, -opp, -game_result)
      if(b$game_num[1] != "") {
        b[b == ""] <- 0
        return(b)
      }
    })
    if(nrow(a) > 0) { a$link <- x }
    return(a)
  })

  gamelogs <- merge(t, gamelogs, by = "link")
  gamelogs$link <- NULL
  gamelogs$year <- year
  gamelogs$player <- stringi::stri_trim(gamelogs$player)
  write.csv(gamelogs, file = paste0("data/gamelogs/", year, ".csv"), row.names = F)

}
