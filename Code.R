library(tidyverse)
library(corrplot)
library(xtable)

# Read in the batting data
batting <- read_delim("Batting.csv")
# Read in the pitching data
pitching <- read_delim("Pitching.csv")


# Create correlation plot for the batting data
batting_cor <- batting %>%
  select_if(is.numeric) %>%
  select(-c(`Player ID`, `Number of Years Played`, 
            Year, `xwOBA`, `wRC+`, G)) %>%
  as.matrix() %>%
  cor()

corrplot(batting_cor, type = "upper", order = "hclust",
         tl.col = "black")



# Create correlation plot for the pitching data
pitching_cor <- pitching %>%
  select_if(is.numeric) %>%
  select(-c(`Player ID`, `Number of Years Played`, 
            Year, G, `vFA (pi)`, xERA)) %>%
  as.matrix() %>%
  cor()

corrplot(pitching_cor, type = "upper", order = "hclust",
         tl.col = "black")



# ANOVA Batting
anova_model = aov(WAR ~ Outliers + `Years Below Median`, data = batting)
summary(anova_model)

xtable(anova_model)

# Plot for Batting, Outliers
ggplot(batting, aes(x=Outliers, y=WAR)) + 
  geom_boxplot(aes(fill =as.factor(Outliers)))+ 
  scale_fill_discrete(name = "Outliers")
# Plot for Batting, Years Below Median
ggplot(batting, aes(x=`Years Below Median`, y=WAR)) + 
  geom_boxplot(aes(fill =as.factor(`Years Below Median`)))+ 
  scale_fill_discrete(name = "Years Below Median")




# ANOVA Pitching
anova_model = aov(ERA ~ Outliers + `Years Below Median`, data = pitching)
summary(anova_model)


# Plots for Pitching, Outliers
ggplot(pitching, aes(x=Outliers, y=ERA)) + 
  geom_boxplot(aes(fill =as.factor(Outliers)))+ 
  scale_fill_discrete(name = "Outliers")
# Plot for Pitching, Years Below Median
ggplot(pitching, aes(x=`Years Below Median`, y=ERA)) + 
  geom_boxplot(aes(fill =as.factor(`Years Below Median`))) + 
  scale_fill_discrete(name = "Years Below Median")




# Model fitting

# Wins above replacement
mlr_war_model = lm(WAR ~ Outliers + `Years Below Median`, data = batting)
summary(mlr_war_model)

# Strikeout Percentage
mlr_k_model = lm(`K%` ~ Outliers + `Years Below Median`, data = batting)
summary(mlr_k_model)

# Offensive runs above average
mlr_off_model = lm(Off ~ Outliers + `Years Below Median`, data = batting)
summary(mlr_off_model)
