library(tidyverse)


milb <- read_delim("MILB_Batting_GM.csv")
mlb <- read_delim("MLB_Batting.csv")

#library(openxlsx)
#write.xlsx(milb, '~/Desktop/Projects/new_file.xlsx')

players = unique(milb["Player ID"])

player_outliers <- data.frame()

for (id in unlist(players)){
  player_data = milb[milb["Player ID"] == id, ]
  # Example data: Number of games played in the minor leagues for each year
  games_played <- unlist(player_data["G"])
  
  # Calculate the interquartile range (IQR)
  Q1 <- quantile(games_played, 0.25)
  Q3 <- quantile(games_played, 0.75)
  IQR <- Q3 - Q1
  
  # Calculate the lower and upper fences
  lower_fence <- Q1 - (1.5 * IQR)
  upper_fence <- Q3 + (1.5 * IQR)
  
  # Identify outliers
  outliers <- games_played < lower_fence
  
  # Example data: Number of games played in the minor leagues for each year NO ROOKIE YEAR
  games_played_norook <- (unlist(player_data["G"]))[-1]
  
  # Calculate the interquartile range (IQR)
  Q1_norook <- quantile(games_played_norook, 0.25)
  Q3_norook <- quantile(games_played_norook, 0.75)
  IQR_norook <- Q3_norook - Q1_norook
  
  # Calculate the lower and upper fences
  lower_fence_norook <- Q1_norook - (1.5 * IQR_norook)
  upper_fence_norook <- Q3_norook + (1.5 * IQR_norook)
  
  # Identify outliers
  outliers_norook <- games_played_norook < lower_fence_norook
  
  # Display the outliers
  # Consider the rookie year numbers
  gp_out_sum <- sum(outliers)
  
  gp_out_norook <- sum(outliers_norook)
  
  # Get total number of years played
  n_years <- length(games_played)
  
  player_outliers = rbind(player_outliers , c(games = paste(games_played,collapse=','), 
                                              out_sum = gp_out_sum, 
                                              out_sum_norook = gp_out_norook,
                                              n_years = n_years, 
                                              player_id = id))
  
}

colnames(player_outliers) = c("Games Per Year", "Outliers", "Outliers No Rookie", 
                              "Number of Years Played", "Player ID")

player_outliers["Player ID"] = as.numeric(unlist(player_outliers["Player ID"]))
player_outliers["Outliers"] = as.numeric(unlist(player_outliers["Outliers"]))
player_outliers["Outliers No Rookie"] = as.numeric(unlist(player_outliers["Outliers No Rookie"]))
player_outliers["Number of Years Played"] = as.numeric(unlist(player_outliers["Number of Years Played"]))

games_player = milb %>% group_by(`Player ID`) %>% 
                summarise(mean_games=mean(G), prop_games=mean(GamesOverMax), number_below_median = sum(`Below Median Annualy`),
                .groups = 'drop')

games_player = left_join(games_player, player_outliers, by = "Player ID")

mlb$`BB%` <- as.numeric(gsub("[\\%,]", "", mlb$`BB%`))
mlb$`K%` <- as.numeric(gsub("[\\%,]", "", mlb$`K%`))

mlb_player = mlb[unlist(lapply(mlb, is.numeric))] %>% group_by(`Player ID`) %>% 
  summarise(across(everything(), mean),
            .groups = 'drop')  %>%
  as.data.frame()

full_data = left_join(mlb_player, games_player, by = "Player ID")



anova_model = aov(WAR ~ Outliers + `Below Median`+ `Years Below Median`, data = full_data)
summary(anova_model)
plot(WAR ~ Outliers, data = full_data)




