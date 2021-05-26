# Load Relevant Libraries
library(tidyverse)
library(tidylog)
library(vtable)
library(jtools)

##################
###### Q1:For each the four products, how do the expected scores compare, under varying environmental 
######    conditions?

# Load data
simulation_results_all <- read_csv("../01_Data/simulation_resultsALLAGENTS.csv", col_names = FALSE) %>%
  rename(Agent = X1, Dirt = X2, Wall = X3, Score = X4) %>%
  mutate(Agent = case_when(
    Agent == "NoSenseAgent" ~ "A-Non-Sensing Sucky",
    Agent == "SensingAgent" ~ "Sensing Sucky",
    Agent == "WorldModelAgent" ~ "Memory Sucky",
    Agent == "OmniscientAgent" ~ "Omniscient Sucky"))


# Tidy Data
simResults <- simulation_results_all %>%
  mutate(Agent = factor(Agent)) %>% 
  group_by(Agent, Dirt, Wall) %>%
  # average score per agent per environment 
  summarize(averageScore = mean(Score)) %>%
  ungroup()

# create baseline average scores with NoSenseAgent scores
baseline_all <- simResults %>%
  filter(Agent == "A-Non-Sensing Sucky") %>%
  mutate(baseline_score = averageScore) %>%
  select(-Agent, -averageScore)

# Merge baseline data set into main df
simResults <- left_join(simResults, baseline_all, by = c("Dirt", "Wall")) 

# Create percent change
simResults <- simResults %>%
  # calculate percent change from baseline per environment
  mutate(percentChange = ((averageScore - baseline_score)/baseline_score*100)) %>%
  group_by(Dirt, Wall) %>%
  # identify model with largest improvement in score
  mutate(MostImprovedScore = max(percentChange),
         # identify most improved model
         MostImprovedAgent = case_when(
           percentChange == MostImprovedScore ~ Agent),
         # calculate difference in improvement of scores from most improved model
         DifferenceInPercentChange = 
           ((percentChange - MostImprovedScore)/MostImprovedScore)*100) %>%
  ungroup() 

#### Total Averages Over All Environments
avg_all_models <- simResults %>%
  group_by(Agent) %>%
  # create total average score for each agent over all environments
  mutate(totalavg = mean(averageScore)) %>%
  distinct(Agent, totalavg) %>%
  ungroup()

# create baseline total average score with NoSenseAgent scores
base_all_models <- avg_all_models %>%
  filter(Agent == "A-Non-Sensing Sucky") %>%
  mutate(baseline_score = totalavg) %>%
  select(-Agent, -totalavg)

# create total average score percent change figures
avg_all_models <- avg_all_models %>%
  # add baseline score back to data
  mutate(baseline_score = base_all_models$baseline_score,
         # calculate percent change from baseline
         percentChange = ((totalavg - baseline_score)/baseline_score*100),
         # identify most improved score
         MostImprovedScore = max(percentChange),
         # identify most improved Agent
         MostImprovedAgent = case_when(
           percentChange == MostImprovedScore ~ Agent),
         # calculate difference in improvement of scores from most improved model
         DifferenceInPercentChange = 
           ((percentChange - MostImprovedScore)/MostImprovedScore)*100) %>%
  ungroup() 

## Average Score Regression Analysis
reg1.a <- lm(averageScore ~ Agent, simResults)
reg1.b <- lm(averageScore ~ Agent + Dirt + Wall, simResults)
results1 <- export_summs(reg1.a, reg1.b)
plotResults <- effect_plot(reg1.b, pred = 'Agent', plot.points = TRUE)

results1
plotResults


########### Average Total Average Over ALl Envinronments

average_all_models_bar <- ggplot(avg_all_models, aes(Agent, totalavg)) + 
  geom_bar(aes(fill = Agent), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title = "Total Average Score Over All Envinronments Per Model",
       subtitle = "Over All Environments")

average_all_models_bar

########### Low Dirt, High Walls
low_dirt_high_walls_all <- simResults %>%
  filter(Dirt == .1, Wall == .3)

all_models_low_high_bar <- ggplot(low_dirt_high_walls_all, aes(Agent, averageScore)) + 
  geom_bar(aes(fill = Agent), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title = "Average Scores by Sucky Model",
       subtitle = "Low Dirt, High Walls")

all_models_low_high_bar

########### High Dirt, Low Walls
high_dirt_low_walls_all <- simResults %>%
  filter(Dirt == .3, Wall == .1)

all_models_high_low_bar <- ggplot(high_dirt_low_walls_all, aes(Agent, averageScore)) + 
  geom_bar(aes(fill = Agent), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y= element_blank()) +
  labs(title = "Average Scores by Sucky Model",
       subtitle = "High Dirt, Low Walls")

all_models_high_low_bar


########################################### Supplemental 
########### Low Dirt, Low Walls
low_dirt_low_walls_all <- simResults %>%
  filter(Dirt == .1, Wall == .1)

all_models_low_low_bar <- ggplot(low_dirt_low_walls_all, aes(Agent, averageScore)) + 
  geom_bar(aes(fill = Agent), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title = "Average Scores by Agent",
       subtitle = "Low Dirt, Low Walls")

all_models_low_low_bar
########### High Dirt, High Walls
high_dirt_high_walls_all <- simResults %>%
  filter(Dirt == .3, Wall == .3)

all_models_high_high_bar <- ggplot(high_dirt_high_walls_all, aes(Agent, averageScore)) + 
  geom_bar(aes(fill = Agent), 
           width = 0.4, 
           position = position_dodge(width=0.5), 
           stat="identity") +  
  theme(legend.position="top", 
        legend.title =element_blank(),
        axis.title.x=element_blank(), 
        axis.title.y=element_blank()) +
  labs(title = "Average Scores by Agent",
       subtitle = "High Dirt, HighWalls")

all_models_high_high_bar


###### percent function
percent <- function(x, digits = 2, format = "f", ...) {      
  paste0(formatC(x, format = format, digits = digits, ...), "%")
}

############################################## Table Generation
############################ Total average scores over all environments per agent
avg_all_models <- avg_all_models %>%
  select(Agent, percentChange, DifferenceInPercentChange) %>%
  mutate('Performance Improvment' = case_when(
    percentChange == 0 ~ "Baseline Model",
    percentChange != 0 ~ percent(percentChange)),
    'Improvement Difference' = case_when(
      DifferenceInPercentChange == 0 ~ "Most Improved Model",
      DifferenceInPercentChange == -100 ~ "Baseline Model",
      DifferenceInPercentChange != 0 ~ percent(DifferenceInPercentChange))) %>%
  select(-percentChange, -DifferenceInPercentChange ) 

#sort based on sucky model
avg_all_models <- avg_all_models %>%
  arrange(Agent = c("Non-Sensing Sucky","Sensing Sucky","Memory Sucky", "Omniscient Sucky"))
# create table
all_models_average_table <- kable(avg_all_models,
                                  caption = "Total Average Results Over All Environments",
                                  booktabs = TRUE) %>% kable_styling(font_size = 7)
# ouptut table
all_models_average_table

############################################## Table Generation
############################# low dirt high walls
lowhigh_all <- low_dirt_high_walls_all %>%
  select(Agent, percentChange, DifferenceInPercentChange) %>%
  mutate('Performance Improvment' = case_when(
    percentChange == 0 ~ "Baseline Model",
    percentChange != 0 ~ percent(percentChange)),
    'Improvement Difference' = case_when(
      DifferenceInPercentChange == 0 ~ "Most Improved Model",
      DifferenceInPercentChange == -100 ~ "Baseline Model",
      DifferenceInPercentChange != 0 ~ percent(DifferenceInPercentChange))) %>%
  select(-percentChange, -DifferenceInPercentChange ) 

#sort based on sucky model
lowhigh_all <- lowhigh_all %>%
  arrange(Agent = c("Non-Sensing Sucky","Sensing Sucky","Memory Sucky", "Omniscient Sucky"))
# create table
all_models_low_high_table <- kable(lowhigh_all,
                                   caption = "Results from Environment with Low Dirt, High Walls",
                                   booktabs = TRUE) %>% kable_styling(font_size = 7)
#output table
all_models_low_high_table

############################################## Table Generation
################################ high dirt low walls
highlow_all <- high_dirt_low_walls_all %>%
  select(Agent, percentChange, DifferenceInPercentChange) %>%
  mutate('Performance Improvment' = case_when(
    percentChange == 0 ~ "Baseline Model",
    percentChange != 0 ~ percent(percentChange)),
    'Improvement Difference' = case_when(
      DifferenceInPercentChange == 0 ~ "Most Improved Model",
      DifferenceInPercentChange == -100 ~ "Baseline Model",
      DifferenceInPercentChange != 0 ~ percent(DifferenceInPercentChange))) %>%
  select(-percentChange, -DifferenceInPercentChange ) 

#sort based on sucky model
highlow_all <- highlow_all %>%
  arrange(Agent = c("Non-Sensing Sucky","Sensing Sucky","Memory Sucky", "Omniscient Sucky"))
# create table
all_models_high_low_table <- kable(highlow_all,
                                   caption = "Results from Environment with High Dirt, Low Walls",
                                   booktabs = TRUE) %>% kable_styling(position = "left", font_size = 7)
# output table
all_models_high_low_table




