# Load Relevant Libraries
library(tidyverse)
library(tidylog)
library(vtable)
library(jtools)

##################
###### Q2: For the most popular Memory Sucky model, what is the effect of raising and lowering the 
######    battery capacity?  Assume that adding more battery capacity does not affect the agent's 
######    performance, e.g. by slowing it down, it is just a matter of the cost of adding the additional
######    battery capacity. 

### Load battery test data
####### 500 Battery Capacity
BatteryCapacity_500 <- read_csv("../01_Data/500BatteryCapacity.csv", col_names = FALSE) %>%
  rename(Agent = X1, Dirt = X2, Wall = X3, Score = X4) %>%
  group_by(Dirt, Wall) %>%
  summarize(average_score = mean(Score)) %>%
  ungroup() %>%
  mutate(battery_capacity = 500)
####### 1000 Battery Capacity
BatteryCapacity_1000 <- read_csv("../01_Data/1000BatteryCapacity.csv", col_names = FALSE) %>%
  rename(Agent = X1, Dirt = X2, Wall = X3, Score = X4)  %>%
  group_by(Dirt, Wall) %>%
  summarize(average_score = mean(Score))  %>%
  ungroup() %>%
  mutate(battery_capacity = 1000)
####### 1500 Battery Capacity
BatteryCapacity_1500 <- read_csv("../01_Data/1500BatteryCapacity.csv", col_names = FALSE) %>%
  rename(Agent = X1, Dirt = X2, Wall = X3, Score = X4)  %>%
  group_by(Dirt, Wall) %>%
  summarize(average_score = mean(Score)) %>%
  ungroup()  %>%
  mutate(battery_capacity = 1500)
####### 2000 Battery Capacity
BatteryCapacity_2000 <- read_csv("../01_Data/2000BatteryCapacity.csv", col_names = FALSE) %>%
  rename(Agent = X1, Dirt = X2, Wall = X3, Score = X4)  %>%
  group_by(Dirt, Wall) %>%
  summarize(average_score = mean(Score)) %>%
  ungroup()  %>%
  mutate(battery_capacity = 2000)
####### 250 Battery Capacity
BatteryCapacity_250 <- read_csv("../01_Data/250BatteryCapacity.csv", col_names = FALSE) %>%
  rename(Agent = X1, Dirt = X2, Wall = X3, Score = X4) %>%
  group_by(Dirt, Wall) %>%
  summarize(average_score = mean(Score)) %>%
  ungroup() %>%
  mutate(battery_capacity = 250)

## Tidy Data
# merge all battery capacity data into one data set
battery_df <- rbind(BatteryCapacity_500, BatteryCapacity_1000, BatteryCapacity_1500, BatteryCapacity_2000, BatteryCapacity_250)

### baseline
baseline2 <- battery_df %>%
  filter(battery_capacity == 500) %>%
  mutate(baseline_score = average_score,
         Agent = "Memory Sucky") %>%
  select(-average_score, -battery_capacity)

battery_df <- left_join(battery_df, baseline2, by = c("Dirt", "Wall"))

battery_df <- battery_df %>%
  mutate(percentChange = ((average_score - baseline_score)/baseline_score*100)) %>%
  group_by(Dirt, Wall) %>%
  # identify model with largest improvement in score
  mutate(MostImprovedScore = max(percentChange),
         # identify most improved model
         MostImprovedAgent = case_when(
           percentChange == MostImprovedScore ~ battery_capacity),
         # calculate difference in improvement of scores from most improved model
         DifferenceInPercentChange = 
           ((percentChange - MostImprovedScore)/MostImprovedScore)*100) %>%
  ungroup() %>%
  mutate(battery_capacity = factor(battery_capacity))



############## Total average over all environments
# total agent average
totalaverage <- battery_df %>%
  group_by(battery_capacity) %>%
  mutate(totalaverage = mean(average_score)) %>%
  distinct(battery_capacity, totalaverage) %>%
  ungroup()

# baseline total agent average
base2 <- totalaverage %>%
  filter(battery_capacity == 500) %>%
  mutate(baseline_totalaverage = totalaverage) %>%
  select(-battery_capacity, -totalaverage)

totalaverage <- totalaverage %>%
  # add baseline score back to data
  mutate(baseline_totalaverage = base2$baseline_totalaverage,
         percentChange = ((totalaverage - baseline_totalaverage)/baseline_totalaverage*100),
         # identify most improved score
         MostImprovedScore = max(percentChange),
         # identify most improved Agent
         MostImprovedAgent = case_when(
           percentChange == MostImprovedScore ~ battery_capacity),
         # calculate difference in improvement of scores from most improved model
         DifferenceInPercentChange = ((percentChange - MostImprovedScore)/MostImprovedScore)*100) %>%
  ungroup() 



## Average Score Regression Analysis
reg2 <- lm(average_score ~ battery_capacity, battery_df)
export_summs(reg2)
plotResults2 <- effect_plot(reg2, pred = 'battery_capacity', plot.points = TRUE, x.label = "Battery Capacity", y.label = "Average Score")
plotResults2



########### Average over all environments
averageperformance_battery <- ggplot(totalaverage, aes(battery_capacity, totalaverage)) + 
  geom_bar(aes(fill = battery_capacity), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title =  "Memory Sucky's Average Scores by Battery Capacity",
       subtitle = "Over All Environments")

averageperformance_battery

########### Low Dirt, High Walls
low_dirt_high_walls_b <- battery_df %>%
  filter(Dirt == .1, Wall == .3) 

low_high_bat <- ggplot(low_dirt_high_walls_b, aes(battery_capacity, average_score)) + 
  geom_bar(aes(fill = battery_capacity), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title =  "Memory Sucky's Average Scores by Battery Capacity",
       subtitle = "Low Dirt, High Walls")

low_high_bat
########### High Dirt, Low Walls
high_dirt_low_walls_b <- battery_df %>%
  filter(Dirt == .3, Wall == .1)

high_low_bat <- ggplot(high_dirt_low_walls_b,  aes(battery_capacity, average_score)) + 
  geom_bar(aes(fill = battery_capacity), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title =  "Memory Sucky's Average Scores by Battery Capacity",
       subtitle = "High Dirt, Low Walls")

high_low_bat


############################# Supplemental 
########### Low Dirt, Low Walls
low_dirt_low_walls_b <- battery_df %>%
  filter(Dirt == .1, Wall == .1)

low_low_b <- ggplot(low_dirt_low_walls_b,  aes(battery_capacity, average_score)) + 
  geom_bar(aes(fill = battery_capacity), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title =  "Memory Sucky's Average Scores by Battery Capacity",
       subtitle = "Low Dirt, Low Walls")

low_low_b
########### High Dirt, high Walls
high_dirt_high_walls_b <- battery_df %>%
  filter(Dirt == .3, Wall == .3)

high_high_b <- ggplot(high_dirt_high_walls_b, aes(battery_capacity, average_score)) + 
  geom_bar(aes(fill = battery_capacity), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title =  "Memory Sucky's Average Scores by Battery Capacity",
       subtitle = "High Dirt, HighWalls")
high_high_b


###### percent function
percent <- function(x, digits = 2, format = "f", ...) {      
  paste0(formatC(x, format = format, digits = digits, ...), "%")
}

############################################## Table Generation
############################ Total average scores over all environments per agent
avgb <- totalaverage %>%
  group_by(battery_capacity) %>%
  select(battery_capacity, percentChange, DifferenceInPercentChange) %>%
  mutate('Performance Improvment' = case_when(
    percentChange == 0 ~ "Baseline Model",
    percentChange != 0 ~ percent(percentChange)),
    'Improvement Difference' = case_when(
      DifferenceInPercentChange == 0 ~ "Most Improved Model",
      DifferenceInPercentChange == -100 ~ "Baseline Model",
      DifferenceInPercentChange != 0 ~ percent(DifferenceInPercentChange))) %>%
  select(-percentChange, -DifferenceInPercentChange ) 

#sort based on sucky model
# create table
avgtableb <- kable(avgb,
                   caption = "Total Average Results Over All Environments",
                   booktabs = TRUE) %>% kable_styling(position = "left", font_size = 7)
# ouptut table
avgtableb

############################################## Table Generation
############################# low dirt high walls
lowhigh_b <- low_dirt_high_walls_b %>%
  select(battery_capacity, percentChange, DifferenceInPercentChange) %>%
  mutate('Performance Improvment' = case_when(
    percentChange == 0 ~ "Baseline Model",
    percentChange != 0 ~ percent(percentChange)),
    'Improvement Difference' = case_when(
      DifferenceInPercentChange == 0 ~ "Most Improved Model",
      DifferenceInPercentChange == -100 ~ "Baseline Model",
      DifferenceInPercentChange != 0 ~ percent(DifferenceInPercentChange))) %>%
  select(-percentChange, -DifferenceInPercentChange ) 

# create table
lowhightable_b <- kable(lowhigh_b,
                        caption = "Results from Environment with Low Dirt, High Walls",
                        booktabs = TRUE) %>% kable_styling(position = "left", font_size = 7)
#output table
lowhightable_b

############################################## Table Generation
################################ high dirt low walls
highlow_b <- high_dirt_low_walls_b %>%
  select(battery_capacity, percentChange, DifferenceInPercentChange) %>%
  mutate('Performance Improvment' = case_when(
    percentChange == 0 ~ "Baseline Model",
    percentChange != 0 ~ percent(percentChange)),
    'Improvement Difference' = case_when(
      DifferenceInPercentChange == 0 ~ "Most Improved Model",
      DifferenceInPercentChange == -100 ~ "Baseline Model",
      DifferenceInPercentChange != 0 ~ percent(DifferenceInPercentChange))) %>%
  select(-percentChange, -DifferenceInPercentChange ) 

# create table
highlowtable_b <- kable(highlow_b,
                        caption = "Results from Environment with High Dirt, Low Walls",
                        booktabs = TRUE) %>% kable_styling(position = "left", font_size = 7)
# output table
highlowtable_b