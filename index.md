<p align="center" width="100%">
    <img width="999" alt="Screenshot 2021-12-07 at 16 55 48" src="https://user-images.githubusercontent.com/91272463/145072358-121331ed-6119-4218-8da2-8f3652814694.png">
</p>

# Tutorial Aims
1.[Introducing the Rank Abundance Diagram](#rank_abundance)

2. Setting up
   * [RStudio](#setting_up)
   * [Importing data](#import_data)
3. Data Wrangling - using `dpylr`
  * a) [Tidy data](#tidy_data) 
  * b) [Transforming data](#transform_data) - creating new variables, ranking data 
4. [Data Visualisation: Plotting a Rank Abundance Diagram](#data_vis)- using `ggplot` and `ggrepel`
5. [Making a panel](#panel) - `gridExtra`

----
This tutorial is going to take you through the steps to make basic Rank Abundance Diagrams. It is aimed at beginners and whilst some knowledge of dpylr and ggplot2 is helpful, it's not vital. We will run through all the steps to make Rank Abundance Diagrams, from data importation, wrangling and manipulation to visualisation and saving your plots. If you want to understand more about the dpylr functions we are using or make your plots more beautiful, you can check out <a href="https://ourcodingclub.github.io" target="_blank">the Coding Club Tutorials</a>. First, let's download the files you need.  

You can get all of the resources for this tutorial from <a href="https://github.com/EdDataScienceEES/tutorial-darahubert.git" target="_blank">this GitHub repository</a>. Clone and download the repo as a zip file, then unzip it.


<a name="rank_abundance"></a> 
## 1.Introducing the Rank Abundance Diagram 

Global biodiversity is declining meaning ecological communities are changing. Rank Abundance diagrams give us a way to visualise community composition based on the relative abundance of each species, a key component of biodiveristy. Species within the community are ranked based on abundance; most abundant to lowest abundance. We can then easily visualise the community composition and compare communities over time by plotting the rank of each species against its relative abundance.

Let's make a start!


## 2. Setting up 
<a name="setting_up"></a>
### R.Studio
----
Open `RStudio` and create a new script by clicking on `File/ New File/ R Script`. Now we need to set the working directory. This will be where your script and any outputs are saved, and also where `RStudio` will look for datasets. If you haven't done so already, its useful to move the datasets you just downloaded for this tutorial into a new folder. Then set that folder as your working directory. To do this, select `Session/ Set working directory` and then select your folder.

```r
# Set the working directory
setwd("your_filepath")  # enter your own file path here 
getwd() # run this to check that you have set your working directory correctly.
```
To run the code, highlight the line and press `Command`and `Enter` on a Mac or `Ctrl` and `R` on a Windows PC. You can also highlight the code and click the run icon in the top right hand corner.

<p align="center" width="100%">
    <img width="999" alt="Screenshot 2021-12-07 at 16 55 48" src="https://user-images.githubusercontent.com/91272463/145191556-66c0a807-ca09-4c40-a2f4-0216dfee9bb5.png">
</p>

----

We are going to need some packages installed to complete this tutorial - don't panic! It's easy to install them if you haven't done so previously. If you have already used them, you will just need to load the libraries.

We are going to use the `tidyverse` package which includes `dpylr` (for data wrangling) and `ggplot2` for data visualisation. We are also going to need `ggrepel` to tidy our plots up and `gridExtra` to make a final panel. Install these packages if you haven't done so already or go ahead and load the libraries.

#### Load packages
```r
# Load libraries
library(tidyverse)
library(ggplot2)
library(ggrepel)
library(gridExtra)

# To install packages uncomment #install.packages("package name") and then load the libraries.
```
----
<a name="import_data"></a> 
### Importing data

Time to import your dataset. We are going to be working with a fake dataset showing populations of tree species. You can click on _Import Dataset_ and import the dataset you downloaded earlier. Alternatively, use the `read.csv()` command to tell `RStudio` where your dataset is - hopefully in the working directory you specified earlier! If you use the _Import Dataset_ button, copy the code from the console and insert it into your script to save any confusion in the future.

Read in the `trees_messy.csv` and make it a data frame object `trees_messy` using `<-`

```r
# Load the data
trees_messy <- read.csv("~/Desktop/data_science/tutorial-darahubert/trees_messy.csv")  
# Your file path will be different.
```
 Let's explore the data and see what we are working with.

 ```r   
# Preview data
head(trees_messy)  # view the first few observations
str(trees_messy)  # view the types of variables
names(trees_messy)  # view the column names
```

Right, we are ready to start tidying the data. If any of the above doesn't make sesne, have a look at <a href="https://ourcodingclub.github.io/tutorials/intro-to-r/#import" target="_blank">this tutorial</a> on getting started with R and RStudio.

<a name="data_wrangling"></a> 
## 3.Data wrangling
----
<p align="center" width="100%">
    <img width="500" alt="Screenshot 2021-12-07 at 16 55 48" src="https://user-images.githubusercontent.com/91272463/145183857-752593aa-12f5-4f80-9c41-2a0b16f082d8.png">
</p>

<a name="tidy_data"></a> 

Data wrangling involves organising the data in a way that we can easily manipulate and visualise it. We want it to be in a tidy format where each row shows an observation and each column shows a variable. If that doesn't make sense, take a look at <a href="https://ourcodingclub.github.io/tutorials/data-manip-intro/" target="_blank">this Coding Club tutorial</a>. We also may need to clean the data (get rid of n/a values, make sure variable names/classification make sense and are grouped appropriately)or transform the dataset to create appropriate values for our data visualisation. 

The next steps will talk you through how to tidy your data and then transform it ready for data visualisation. 


### 3a) Tidy the data 

----
Let's view the entire dataset.

```r  
view(trees_messy)
```
The dataset itself is in a tidy format but it could do with some cleaning up. 

We need to get rid of the n/a values, change the column names to lower case and get rid of any rows we don't want. Before we start getting rid of data, it's good to think about our final plot and what we want to show. 

The dataset contains data for two years, 1981 and 2021. We want make a plot for each year showing the the relative abundance of each species and the rank of each species. Then we can visualise how the community has changed over time. Let's get rid of the columns for _date_ and _phylum_. We will keep the columns for _year_, _population_ and _species_.

```r  
# Tidy the dataset
trees_tidy <- select(trees_messy, -date, -phylum) %>%  # delete unwanted column showing date and phylum. 
  na.omit()  # delete all n/a values

	# we have used a pipe %>% to pass the function on the right into the dataset on the left. It's a handy command and you can find more about it here.

colnames(trees_tidy) <- c("year", "species", "population") # change column names
head(trees_tidy)  # Check changes have been made
```
Great! Now we want to split our dataset by year. To do this we are going to use the `filter()` command and make a new data frame object `<-` for each year.

```r  
trees_81 <- trees_tidy %>% filter(year == 1981)  # data frame for 1981
trees_21 <- trees_tidy %>% filter(year == 2021)  # data frame for 2021
```
<a name="transform_data"></a>
### 3b) Transform Data 

Perfect. Let's transform the data so  we can plot it in Rank Abundance Diagram. 
The diagrams will show rank of species (x axis) and relative abundance of each species (y axis). Let's deal with the ranking first.  

#### Ranking the data

<p align="center" width="100%">
    <img width="800" alt="Screenshot 2021-12-07 at 16 55 48" src="https://user-images.githubusercontent.com/91272463/145182148-9b90101b-482d-46f7-9190-7a7d7eb0a0aa.png">
</p>

Rank abundance diagrams rank the species with the highest relative abundance as 1. We want to rank species based on their population in desecnding order. 

We will add a new column to each data frame using `$`. Using a `-` before `trees_21$population` ranks in descending order. `ties.method = random` allocates a ranking at random between species who have the same population size (we want all ranks to be unique). 
```r   
# Ranking the data

trees_21$rank <- rank(-trees_21$population, ties.method = "random")

# create a new column in the trees_21 data frame.
# use rank() with - to rank the species in descending order of population size.
# use the ties.random method to allocate each species a unique number and assign any tied values at random.

# Run this code to repeat the steps for tree_81
trees_81$rank <- rank(-trees_81$population, ties.method = "random")
```
#### Relative Abundance
<p align="center" width="100%">
    <img width="500" alt="Screenshot 2021-12-07 at 16 55 48" src="https://user-images.githubusercontent.com/91272463/145187164-baca7673-1263-4776-83f1-30c11a64b1cc.png">
</p>

We now want to know the total population in each year to calculate the relative abundance of each species. We can do this using the `sum()` and `transform` commands.
`transform` makes a new column based on existing values. For each year, we will divide the (population size of each species by the total population)* 100. We will also save our final data frames as `.csv` files.  

```r  
# Save the total population size of each year as a data frame object
total81 <- sum(trees_81$population)

total21 <- sum(trees_21$population)

# Use the transform function to add a new column for relative abundance.
trees_21 <- transform(trees_21,relative_abundance = (population/total21)*100) # make a new column for relative abundance
trees_81 <- transform(trees_81,relative_abundance = (population/total81)*100) # make a new column for relative abundance


# Save the final datasets to your working directory
write.csv(trees_21, file = "trees21_final.csv")
write.csv(trees_81, file = "trees81_final.csv")
```
Great! Now we have our data to plot. Let's move on to data visualisation.

<a name="data_vis"></a> 
## 4. Data Visualisation

<p align="center" width="80%">
    <img width="500" alt="Screenshot 2021-12-08 at 10 56 06" src="https://user-images.githubusercontent.com/91272463/145196680-a938c27e-6446-46eb-9655-e244c7b32785.png"

----
We want to show the relative abundance of each species, plotted against the rank of each species for both 1981 and 2021 and connect the data points.
We will plot a connected scatterplot using `ggplot2`. This uses commands `geom_point` to plot the data points and `geom_line` to connect them. There is so much more you can do with `ggplot2` so if you want to find out more about data visualisation be sure to have a look at <a href="https://ourcodingclub.github.io/tutorials/data-vis-2/" target="_blank">this data visualisation tutorial</a> 

For now, let's make our first Rank Abundance Diagram for 2021, using the `trees_21` data frame. 

```r  
p2021 <- ggplot(trees_21, aes(x=rank, y=relative_abundance)) +  # set x and y axis
  geom_point(shape=21, size=2.25, aes(color=species, fill=species)) + # plot data points and colour them according to species.
  geom_line(colour = "grey") +  # plot line to connect data points
  theme_bw() +  # set theme for plot
  labs(x="Species Rank",y="Relative Abundance (%)", # label the axis
       title = "2021") +  # give your plot a title
  theme(panel.grid.major = element_blank(),  # get rid of grid lines
        panel.grid.minor = element_blank(),
        axis.text = element_text(size = 8),  # set axis font size
        legend.position = "top",  # position the legend at the top
        legend.background = element_rect(colour="black"))  # outline the legend

p2021  # View the plot.
```

![image](https://github.com/EdDataScienceEES/tutorial-darahubert/blob/a1f47a9b332729ba42ebfa8305557e283bf08198/outputs%20/2021%20-%20no%20data%20points.png)

To make the plot clearer, we can add data labels. 

```r 
# Add data labels 
p2021 + geom_text(aes(label=species), size = 3). # add species labels to data points
```
![image](https://github.com/EdDataScienceEES/tutorial-darahubert/blob/be1c38202ced1efdf20082f22d119327b5f919b8/outputs%20/2021%20-%20bad%20data%20labels.png)

That's not very clear. We can use the `geom_text_repel` in the `ggrepel` package to make sure the data labels don't overlap. 

```r
(p2021_labels <- p2021 + geom_text_repel(aes(label=species), size = 3)) # Avoid data points overlapping

# Including the plot code in () means the plot is automatically shown in the plot window. 
```
![image](https://github.com/EdDataScienceEES/tutorial-darahubert/blob/a1f47a9b332729ba42ebfa8305557e283bf08198/outputs%20/2021%20-%20with%20data%20labels.png)

----
Now we can plot the Rank Abundance Diagram for 1981. 

```
# Plot 1981 Rank Abundance Diagram
(p1981 <- ggplot(trees_81, aes(x=rank, y=relative_abundance)) +
    geom_point(shape=21, size=2.25, aes(color=species, fill=species)) +
    geom_text_repel(aes(label=species), size = 3) +. # add data labels 
    geom_line(colour = "grey") +
    theme_bw() + 
    labs(x="Species Rank",y="Relative Abundance", title = "1981") +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          axis.text = element_text(size = 8),
          legend.position = "top",
          legend.background = element_rect(colour="black"))) 
```

<p align="center" width="100%">
    <img width="800" alt="Screenshot 2021-12-07 at 16 55 48" src="https://github.com/EdDataScienceEES/tutorial-darahubert/blob/a1f47a9b332729ba42ebfa8305557e283bf08198/outputs%20/1981%20plot.png">
</p>

#### Now we have our two plots `p2021_labels` and `p1981`, we can format them and make a panel. 

<a name="panel"></a> 
## 5.Making a panel. 

We can display both plots in a panel which allows them to be easily compared. Adding the data labels means we don't need the legend. 

Use the code below to make the final plots and arrange and save them as a panel. 

```r

(p2021_final <- p2021_labels + theme(legend.position = "none")). # Remove legends from plots 
(p1981_final <- p1981 + theme(legend.position = "none"))

panel <- grid.arrange(p1981_final,p2021_final,ncol=1, top = "Tree Rank Abundance Diagrams")  # Make panel using gridExtra and add title. 

ggsave(panel,filename = "Tree Rank Abundance Diagrams.jpg")

```
![image](https://github.com/EdDataScienceEES/tutorial-darahubert/blob/a1f47a9b332729ba42ebfa8305557e283bf08198/outputs%20/Tree%20Rank%20Abundance%20Diagrams%20Final.jpg)

We have our final output! 

Obviously this is a fake dataset, but we can see that the community of tree species has changed since between 1981-2021. The relative abundance of species is more even in 2021 and we can compare how the different species have declined/increased in relative abundance between the communities over time. 


## A summary...

That's the end of the tutorial! In this tutorial we learned:

* How to set a working directory, start new scripts and import data into `Rstudio`. 
* How to wrangle and transform data using some of the `dpylr` functions. 
* How to make a Rank Abundance Diagram. 
* How to make a panel and save the output. 


For more on `ggplot2`, read the official <a href="https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf" target="_blank">ggplot2 cheatsheet</a>.


#### Check out our <a href="https://ourcodingclub.github.io/links/" target="_blank">Useful links</a> page where you can find loads of guides and cheatsheets.

#### If you have any questions about completing this tutorial, please contact us on ourcodingclub@gmail.com

#### <a href="INSERT_SURVEY_LINK" target="_blank">We would love to hear your feedback on the tutorial, whether you did it in the classroom or online!</a>

<ul class="social-icons">
	<li>
		<h3>
			<a href="https://twitter.com/our_codingclub" target="_blank">&nbsp;Follow our coding adventures on Twitter! <i class="fa fa-twitter"></i></a>
		</h3>
	</li>
</ul>

### &nbsp;&nbsp;Subscribe to our mailing list:
<div class="container">
	<div class="block">
        <!-- subscribe form start -->
		<div class="form-group">
			<form action="https://getsimpleform.com/messages?form_api_token=de1ba2f2f947822946fb6e835437ec78" method="post">
			<div class="form-group">
				<input type='text' class="form-control" name='Email' placeholder="Email" required/>
			</div>
			<div>
                        	<button class="btn btn-default" type='submit'>Subscribe</button>
                    	</div>
                	</form>
		</div>
	</div>
</div>
