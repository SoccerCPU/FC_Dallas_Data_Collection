# install libraries

install.packages("rvest")
install.packages("stringr")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("plotly")
install.packages("readr")

# load packages

library(rvest)
library(stringr)
library(dplyr)
library(ggplot2)
library(plotly)
library(readr)

# read html of FB Ref and identify links

page <- read_html("https://fbref.com/en/comps/22/schedule/Major-League-Soccer-Scores-and-Fixtures")
links_1 <- unlist(page %>% html_nodes("a") %>% html_attr('href'))
head(links_1)

# game related links contain "matches" and "Major-League-Soccer"
# filter links using grepl command equally same amount of links as there are matches played

links_2 <- strsplit(links_1, '"')
links_2[100:120]
links_3 <- links_2[grepl("matches", links_2)]
links_4 <- links_3[grepl("Major-League-Soccer", links_3)]
all_urls <- unique(links_4)

# Make analysis about specific team

team_urls <- all_urls[grepl("FC-Dallas", all_urls)]

# create links to each individual games played by pasting domain and rest of url, will return full url for all games played up to date

selected_urls <- paste("https://fbref.com", team_urls, sep="")
selected_urls

match=1
# selected_urls[match]
# nchar("https://fbref.com/en/matches/310f83cc/")
# nchar("-Major-League-Soccer")

game_data <- substr(selected_urls[match], 39, nchar(selected_urls[match])-20)
game_data

  # abbreviation of months

  game_data <- str_replace(game_data, "January", "Jan")
  game_data <- str_replace(game_data, "February", "Feb")
  game_data <- str_replace(game_data, "March", "Mar")
  game_data <- str_replace(game_data, "April", "Apr")
  game_data <- str_replace(game_data, "June", "Jun")
  game_data <- str_replace(game_data, "July", "Jul")
  game_data <- str_replace(game_data, "August", "Aug")
  game_data <- str_replace(game_data, "September", "Sep")
  game_data <- str_replace(game_data, "October", "Oct")
  game_data <- str_replace(game_data, "November", "Nov")
  game_data <- str_replace(game_data, "Decemeber", "Dec")

date <- substr(game_data, nchar(game_data)-10, nchar(game_data))

# nchar("-Feb-22-2025")
teams <- substr(game_data, 1, nchar(game_data)-12)

  # Replace Team Names

  teams <- str_replace(teams,"FC-Dallas", "FC Dallas")
  teams <- str_replace(teams,"Houston-Dynamo", "Houston Dynamo")
  teams <- str_replace(teams,"Colorado-Rapids", "Colorado Rapids")
  teams <- str_replace(teams,"Chicago-Fire", "Chicago Fire")
  teams <- str_replace(teams,"Vanccouver-Whitecaps-FC", "Vancouver Whitecaps FC")
  teams <- str_replace(teams,"Real-Salt-Lake-FC", "Real Salt Lake FC")
  teams <- str_replace(teams,"Sporting-Kansas-City", "Sporting Kansas City")
  teams <- str_replace(teams,"Atlanta-United", "Atlanta United")
  teams <- str_replace(teams,"Minnesota-United", "Minnesota United")
  teams <- str_replace(teams,"Los-Angeles-FC", "Los Angeles FC")
  teams <- str_replace(teams,"Portland-Timbers", "Portland Timbers")
  teams <- str_replace(teams,"Nashville-SC", "Nashville SC")
  teams <- str_replace(teams,"New-England-Revolution", "New England Revolution")
  teams <- str_replace(teams,"St-Louis-City", "St Louis City")
  teams <- str_replace(teams,"Austin-FC", "Austin FC")
  teams <- str_replace(teams,"CF-Montreal", "CF Montreal")
  teams <- str_replace(teams,"FC-Cincinnati", "FC Cincinnati")
  teams <- str_replace(teams,"New-York-Red-Bulls", "New York Red Bulls")
  teams <- str_replace(teams,"Columbus-Crew", "Columbus Crew")
  teams <- str_replace(teams,"Orlando-City", "Orlando City")
  teams <- str_replace(teams,"Philadelphia-Union", "Philadelphia Union")
  teams <- str_replace(teams,"San-Jose-Earthquakes", "San Jose Earthquakes")
  teams <- str_replace(teams,"Inter-Miami", "Inter Miami")
  teams <- str_replace(teams,"New-York-City-FC", "New York City FC")
  teams <- str_replace(teams,"Seattle-Sounders", "Seattle Sounders")
  teams <- str_replace(teams,"Charlotte-FC", "Charlotte FC")
  teams <- str_replace(teams,"LA-Galaxy", "LA Galaxy")
  teams <- str_replace(teams,"San-Diego-FC", "San Diego FC")
  teams <- str_replace(teams,"DC-United", "DC United")
  teams <- str_replace(teams,"Toronto-FC", "Toronto FC")
  
teamA <- sub("-.*", "",teams)
teamB <- sub(".*-", "",teams)

# read first pair of tables

# match=1
url <- selected_urls[match]

# read html and get table for each team

statA <- curl::curl(url) %>%
  xml2::read_html() %>%
  rvest::html_nodes('table') %>%
  rvest::html_table() %>%
  .[[4]]

statB <- curl::curl(url) %>%
  xml2::read_html() %>%
  rvest::html_nodes('table') %>%
  rvest::html_table() %>%
  .[[11]]

# fix column names

colnames(statA) <- paste0(colnames(statA), ">>", statA[1, ])
names(statA)[1:6] <- paste0(statA[1,1:6])
statA <- statA[-c(1), ]

colnames(statB) <- paste0(colnames(statB), ">>", statB[1, ])
names(statB)[1:6] <- paste0(statB[1,1:6])
statB <- statB[-c(1), ]

# add date and team name to stats

statA <- cbind(date, Team = teamA, Opponent = teamB, statA)
statB <- cbind(date, Team = teamB, Opponent = teamA, statB)

stat_both <- rbind(statA,statB)


#####
# Scrape all table
#####

selected_urls <- paste("https://fbref.com", team_urls, sep="")

# modify single digit dates to have two digits

selected_urls <- str_replace(selected_urls, "-1-", "-01-")
selected_urls <- str_replace(selected_urls, "-2-", "-02-")
selected_urls <- str_replace(selected_urls, "-3-", "-03-")
selected_urls <- str_replace(selected_urls, "-4-", "-04-")
selected_urls <- str_replace(selected_urls, "-5-", "-05-")
selected_urls <- str_replace(selected_urls, "-6-", "-06-")
selected_urls <- str_replace(selected_urls, "-7-", "-07-")
selected_urls <- str_replace(selected_urls, "-8-", "-08-")
selected_urls <- str_replace(selected_urls, "-9-", "-09-")

# initialize tables
# all_stat is all stat for one game
# full_stat is all stat for all games

all_stat <- NULL
full_stat <- NULL

for (match in 1:length(selected_urls)){
  # get game info from url
  game_data <- substr(selected_urls[match], 39, nchar(selected_urls[match])-20)
  game_data <- str_replace(game_data, "January", "Jan")
  game_data <- str_replace(game_data, "February", "Feb")
  game_data <- str_replace(game_data, "March", "Mar")
  game_data <- str_replace(game_data, "April", "Apr")
  game_data <- str_replace(game_data, "June", "Jun")
  game_data <- str_replace(game_data, "July", "Jul")
  game_data <- str_replace(game_data, "August", "Aug")
  game_data <- str_replace(game_data, "September", "Sep")
  game_data <- str_replace(game_data, "October", "Oct")
  game_data <- str_replace(game_data, "November", "Nov")
  game_data <- str_replace(game_data, "Decemeber", "Dec")
  
  date <- substr(game_data, nchar(game_data)-10, nchar(game_data))
  teams <- substr(game_data, 1, nchar(game_data)-12)
  teams <- str_replace(teams,"FC-Dallas", "FC Dallas")
  teams <- str_replace(teams,"Houston-Dynamo", "Houston Dynamo")
  teams <- str_replace(teams,"Colorado-Rapids", "Colorado Rapids")
  teams <- str_replace(teams,"Chicago-Fire", "Chicago Fire")
  teams <- str_replace(teams,"Vanccouver-Whitecaps-FC", "Vancouver Whitecaps FC")
  teams <- str_replace(teams,"Real-Salt-Lake-FC", "Real Salt Lake FC")
  teams <- str_replace(teams,"Sporting-Kansas-City", "Sporting Kansas City")
  teams <- str_replace(teams,"Atlanta-United", "Atlanta United")
  teams <- str_replace(teams,"Minnesota-United", "Minnesota United")
  teams <- str_replace(teams,"Los-Angeles-FC", "Los Angeles FC")
  teams <- str_replace(teams,"Portland-Timbers", "Portland Timbers")
  teams <- str_replace(teams,"Nashville-SC", "Nashville SC")
  teams <- str_replace(teams,"New-England-Revolution", "New England Revolution")
  teams <- str_replace(teams,"St-Louis-City", "St Louis City")
  teams <- str_replace(teams,"Austin-FC", "Austin FC")
  teams <- str_replace(teams,"CF-Montreal", "CF Montreal")
  teams <- str_replace(teams,"FC-Cincinnati", "FC Cincinnati")
  teams <- str_replace(teams,"New-York-Red-Bulls", "New York Red Bulls")
  teams <- str_replace(teams,"Columbus-Crew", "Columbus Crew")
  teams <- str_replace(teams,"Orlando-City", "Orlando City")
  teams <- str_replace(teams,"Philadelphia-Union", "Philadelphia Union")
  teams <- str_replace(teams,"San-Jose-Earthquakes", "San Jose Earthquakes")
  teams <- str_replace(teams,"Inter-Miami", "Inter Miami")
  teams <- str_replace(teams,"New-York-City-FC", "New York City FC")
  teams <- str_replace(teams,"Seattle-Sounders", "Seattle Sounders")
  teams <- str_replace(teams,"Charlotte-FC", "Charlotte FC")
  teams <- str_replace(teams,"LA-Galaxy", "LA Galaxy")
  teams <- str_replace(teams,"San-Diego-FC", "San Diego FC")
  teams <- str_replace(teams,"DC-United", "DC United")
  teams <- str_replace(teams,"Toronto-FC", "Toronto FC")
  
  teamA <- sub("-.*", "",teams)
  teamB <- sub(".*-", "",teams)
  
  #read first pair of tables
  url <- selected_urls[match]
  
  statA <- curl::curl(url) %>%
    xml2::read_html() %>%
    rvest::html_nodes('table') %>%
    rvest::html_table() %>%
    .[[4]]
  
  statB <- curl::curl(url) %>%
    xml2::read_html() %>%
    rvest::html_nodes('table') %>%
    rvest::html_table() %>%
    .[[11]]
  
  colnames(statA) <- paste0(colnames(statA), ">>", statA[1, ])
  names(statA)[1:6] <- paste0(statA[1,1:6])
  statA <- statA[-c(1), ]
  
  colnames(statB) <- paste0(colnames(statB), ">>", statB[1, ])
  names(statB)[1:6] <- paste0(statB[1,1:6])
  statB <- statB[-c(1), ]

  statA <- cbind(date, Team = teamA, Opponent = teamB, statA)
  statB <- cbind(date, Team = teamB, Opponent = teamA, statB)
  
  stat_both <- rbind(statA,statB)
  
  #define data frame
  all_stat <- stat_both
  Sys.sleep(15)
  
  #loop for all tables related to game
  for(i in 5:10){
    statA <- curl::curl(url) %>%
      xml2::read_html() %>%
      rvest::html_nodes('table') %>%
      rvest::html_table() %>%
      .[[i]]
    colnames(statA) <- paste0(colnames(statA), ">>", statA[1, ])
    names(statA)[1:6] <- paste0(statA[1,1:6])
    statA <- statA[-c(1), ]
    statA <- cbind(date, Team = teamA, Opponent = teamB, statA)
    statB <- curl::curl(url) %>%
      xml2::read_html() %>%
      rvest::html_nodes('table') %>%
      rvest::html_table() %>%
      .[[i+7]]
    colnames(statB) <- paste0(colnames(statB), ">>", statB[1, ])
    names(statB)[1:6] <- paste0(statB[1,1:6])
    statB <- statB[-c(1), ]
    statB <- cbind(date, Team = teamB, Opponent = teamA, statB)
    stat_both <- rbind(statA,statB)
    all_stat <- merge(all_stat, stat_both, all=T)
    
    #remove duplicates
    all_stat <- unique(all_stat)

    #clean
    all_stat$Player <- str_trim(all_stat$Player, side = c("both", "left", "right"))
   
    #convert all stats into numeric variables
    all_stat <- cbind(all_stat[,1:8], mutate_all(all_stat[,9:ncol(all_stat)], function(x) as.numeric(as.character(x))))
    
    write.csv(all_stat, paste0("MLS_2025", game_data, ".csv"))
              
    Sys.sleep(15)
  }

  # add game table to total table
  full_stat <- rbind(full_stat, all_stat)
}