# Tutorial to make Rank Abundance Diagrams 
# Aim: create basic rank abundance diagrams. show how to import data, wrangle data using dpylr, visualise data using gglot2 and ggrepel, make a panel usimg gridExtra.
# Dara Hubert - darahubert@icloud.com
# 06/12/21
# Packages used: dpylr, ggplot2, ggrepel, gridExtra


### Setting up ----

rm(list=ls())

# Set the working directory
setwd("your_filepath")  # enter your own file path here 
getwd() # run this to check that you have set your working directory correctly.

# Set the working directory
setwd(setwd("~/Desktop/data_science/tutorial-darahubert"))
# Enter own filepath. 
getwd() # check your working directory is set correctly 

# Load libraries
library(tidyverse) # load tidyverse package for data wrangling and visualisation. 
library(ggplot2)
library(ggrepel)
library(gridExtra)

### Explore data ----

# Loading data
trees_messy <- read.csv("~/Desktop/data_science/tutorial-darahubert/trees_messy.csv")
# Read in dataset

# Check import and preview data 
head(trees_messy)  # view the first few observations
str(trees_messy)  # view the types of variables
names(trees_messy)  # view the column names 

# Data formatting --- 
# 2021 dataset needs some tidying!
# We also need to group by year. 

view(trees_messy)

# Tidy the dataset 
# Remove n/a values
trees_tidy <- select(trees_messy, -date, -phylum) %>%  # delete unwanted column showing date and phylum.
  na.omit()  # delete all n/a values

colnames(trees_tidy) <- c("year", "species", "population") # change column names 
head(trees_tidy)  # Check changes have been made 

# split the dataset into two data frames by year. 
trees_81 <- trees_tidy %>% filter(year == 1981)
trees_21 <- trees_tidy %>% filter(year == 2021)

# Data manipulation ----

# rank the data according to number of species 
trees_21$rank <- rank(-trees_21$population, ties.method = "random")
trees_81$rank <- rank(-trees_81$population, ties.method = "random")
# use 'ties.method = random' to randomly assign rank if numbers are equal. 
# use - in front of dataset to rank in descending order. i.e allocate the highest species richness as rank 1. 

# Find the total number of trees for each dataset and save this as an value to use in the next stage. 
total81 <- sum(trees_81$population)
total21 <- sum(trees_21$population)


# Calculate the relative abundance of each species 
trees_21 <- transform(trees_21,relative_abundance = (population/total21)*100) # make a new column for relative abundance
trees_81 <- transform(trees_81,relative_abundance = (population/total81)*100) # make a new column for relative abundance

# Save final datasets to working directory
write.csv(trees_21, file = "trees21_final.csv")
write.csv(trees_81, file = "trees81_final.csv")

### Data visualisation ----

# Plot rank abundance diagram for 2021 
p2021 <- ggplot(trees_21, aes(x=rank, y=relative_abundance)) +
  geom_point(shape=21, size=2.25, aes(color=species, fill=species)) +
  geom_line(colour = "grey") +
  theme_bw() + 
  labs(x="Species Rank",y="Relative Abundance (%)", 
       title = "2021") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.text = element_text(size = 8),
        legend.position = "top",
        legend.background = element_rect(colour="black"))

p2021  # view plot 

# Add data labels 
p2021 + geom_text(aes(label=species), size = 3)
# data labels overlap 
# install ggrepel

(p2021_labels <- p2021 + geom_text_repel(aes(label=species), size = 3))

# Plot rank abundance diagram for 1981
# Use () at start and end of code to view plot directly 
(p1981 <- ggplot(trees_81, aes(x=rank, y=relative_abundance)) +
    geom_point(shape=21, size=2.25, aes(color=species, fill=species)) +
    geom_text_repel(aes(label=species), size = 3) +
    geom_line(colour = "grey") +
    theme_bw() + 
    labs(x="Species Rank",y="Relative Abundance (%)", title = "1981") +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          axis.text = element_text(size = 8),
          legend.position = "top",
          legend.background = element_rect(colour="black")))

# Display as a panel - 
# 1.Remove legend from 2021 plot 
(p2021_final <- p2021_labels + theme(legend.position = "none"))
(p1981_final <- p1981 + theme(legend.position = "none"))

# 2.Make panel using gridExtra
panel <- grid.arrange(p1981_final,p2021_final,ncol=1, top = "Tree Rank Abundance Diagrams")

# 3.Save panel using ggsave 
ggsave(panel,filename = "Tree Rank Abundance Diagrams Final.jpg")
