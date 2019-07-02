# code associated with exerpts of the data carpentry lessons
#http://www.datacarpentry.org/R-ecology-lesson/01-intro-to-R.html
#http://www.datacarpentry.org/R-ecology-lesson/02-starting-with-data.html

# R can do math!
3+5           #Prints 8 to the console
12/7          #prints 1.714286 to the console

# The assignment operator (<-): storing values in variables

weight_kg <- 55    # doesn't print anything
(weight_kg <- 53)  # but putting parentheses around the call prints the value of `weight_kg`
weight_kg          # and so does typing the name of the object

# Example: unit conversions
weight_kg*2.2               #Output the weight in pounds to the console
weight_kg<-57.5             #Values of variables can be changed
weight_lb<-weight_kg*2.2    #Results of calculations can be assigned to new variables

## Exercise: operators
#### What are the values of each variable after each statement in the following?

mass <- 47.5            # mass?
age  <- 122             # age?
mass <- mass * 2.0      # mass?
age  <- age - 20        # age?
mass_index <- mass/age  # mass_index?

# Functions and their arguments 
## Functions have:
#   - Names
#   - Arguments - what they need to "know" to run that function; aka input; isn't modified
#   - Output - the result of whatever the function does; default is output to the console, 
#              can be assigned to variables; 

a<-9                 #assigns the value 9 to the variable a
b<-sqrt(a)           # sqrt is the function; value of a is the argument; output is assigned to b

round(3.14159)       #Round is the function, 3.14159 is the argument, output (3) goes to the console

args(round)          #lists the argument of the round function to the console

?round               #loads the documentation for the round function

round(3.14159, digits =2) #Rounds the output to 2 digits

# Determining data types

#Assign a number value to an object
x<-32
class(x) #numeric

#Assign text value to an object
y<-"hi"
class(y) #character

#Assign logical value to an object
z<- TRUE
class(z) #logical

######################### Data wrangling in R ######################
#### Based on the data carpentry ecology lessons: 
####       http://www.datacarpentry.org/R-ecology-lesson/03-dplyr.html

#installing packages
#install.packages("tidyverse")

#loading packages
library("tidyverse")

#read the data as a 'tibble'
surveys <- read_csv('data/complete_surveys.csv')
surveys

# ways to inspect your data
head(surveys) #= look at first 6 rows (all columns)
str(surveys) #= structure # rows, cols, data types
nrow(surveys) #= number of columns
ncol(surveys) #= number of columns
names(surveys) #= column names
summary(surveys) #= does summary stats for each column

#Exercise: inspecting data frames
#Based on the output of str(surveys), can you answer the following questions?
# What is the class of the object surveys?
# How many rows and how many columns are in this object?
# How many species have been recorded during these surveys?

############################## The Verbs! ################################

### Select
select(surveys,      #the data
       weight)       #selects the weight column

#same as
tibble(surveys$weight)

#select multiple columns
select(surveys,      #the data
       plot_id,      #selects the plot_id column
       species_id,   #selects the species_id column
       weight)       #selects the weight column


### Filter
filter(surveys, year == 1995) 

#same as 
surveys[surveys$year == 1995, ]

#filter by multiple attributes

filter(surveys,          #the data
       year == 1995 &    #filter for rows that have 1995 in year column
         sex == "F")       #filter for rows that have F in the sex column

#same as 
surveys[surveys$year == 1995 & surveys$sex == "F", ]

###pipes
surveys %>%                             #the data then
  filter(weight < 5) %>%             #filter for rows where weight is less than 5 then
  select(species_id, sex, weight)  #select the species_id, sex, and weight columns


#Exercise #1: 
### Using pipes, subset the survey data to include individuals collected 
###     before 1995 and retain only the columns year, sex, and weight.

surveys %>%
  filter(year == 1995) %>%
  select(year, sex, weight)

#                   OR
surveys %>%
  select(year, sex, weight) %>%
  filter(year == 1995)

### Mutate
mutate(surveys,                          #the data
       weight_kg = weight / 1000)          #a new column definition
#creates a new column called weight_kg
#that holds the corresponding weight value / 1000

#same as
surveys %>%                              #the data
  mutate(weight_kg = weight / 1000) #see above 

# add 2 new columns at once
surveys %>%                              #the data
  mutate(weight_kg = weight / 1000, #see above
         weight_kg2 = weight_kg *2) #creates a column called weight_kg2
#that holds the value weight_kg*2

##### Exercise 2 
#Create a new data frame from the survey data that meets the following criteria: 
# * contains only the species_id column and a new column called hindfoot_half containing 
# values that are half the hindfoot_length values. 
# * In this hindfoot_halfcolumn, there are no NAs and all values are less than 30.
#Hint: think about how the commands should be ordered to produce this data frame!

surveys%>%
  filter(year>1990)%>%
  mutate(hindfoot_half = hindfoot_length/2) %>%
  select(species_id, hindfoot_half)

# create a summary of the weight variable
surveys_summary<-surveys %>%
  summarize(mean_weight = mean(weight))         #summary statistic
                               
#not very informative w/o group by

#group by then summarize creats a summary table
surveys_summary<-surveys %>%
  group_by(sex) %>%                            #categorical variable
  summarize(mean_weight = mean(weight))         #summary statistic
                              

#group by multiple variables
surveys_summary<- surveys %>%
  group_by(sex, species_id) %>%                #two categoriacl variables
  summarize(mean_weight = mean(weight))         #summary statistic

# count observation in each category
surveys %>%              #the data
  count(sex)             #variable to count by

#Same as
surveys %>%                 #the data
  group_by(sex) %>%         #the variable to coutn by
  summarize(count = n())    #summarize with the count function

# group by multiple variables
surveys %>%                 #the data
  count(sex,  species)      #count by 2 variables

#group by 2 things
surveys %>%                      #the data
  count(sex,  species) %>%       #count by 2 variables
  
################################# Exercise 3 ####################################################################
# 1. How many individuals were caught in each plot_type surveyed?

# 2. Use group_by() and summarize() to find the mean, min, and max 
#hindfoot length for each species (using species_id).

#Individuals per plot type
surveys %>%
  count(plot_type) #count the number of records for each plot type

#hfl by species
surveys %>%
  group_by(species_id) %>%            # group by species id
  filter(!is.na(hindfoot_length))%>%  # filter out missing values
  summarize(mean_hfl = mean(hindfoot_length), #calculate
            min_hfl = min(hindfoot_length),       #summary
            max_hfl = max(hindfoot_length))         #statistics

################################# Exporting data #######################################################
write_csv(surveys_summary, 
          path = "data/surveys_summary.csv")

###### Making graphs with the ggplot package
## Code obtained from Data Carpentry Ecology Lesson
####  http://www.datacarpentry.org/R-ecology-lesson/04-visualization-ggplot2.html

## Plotting numerical data 
#Basic graph elements

# the simplest ggplot: data, aesthetic mappings, and geometry
ggplot(data = surveys, 
       aes(x = weight, 
           y = hindfoot_length)) + 
  geom_point()

# Break it down into component parts

# Step 1: Initialize the plot
#- specify data
#- creates a blank plot

ggplot(data = surveys)

# Step 2: specify variales on each axis
#- specify the "aesthetic mappings"
#- start with the aes function
#-opens a plot window and draws axes

ggplot(data = surveys, 
       mapping = aes(x = weight, 
                     y = hindfoot_length))

# Step 3: specify the geometry 
#- use a geom function to specify how the data should be plotted
# "add" aesthetics to the ggplot function with + operator
# whitespace matters here 
# adds data points to the plot

ggplot(data = surveys, 
       mapping = aes(x = weight, 
                     y = hindfoot_length)) + 
  geom_point()

# Adding arguments to the geom to change appearance:

# Add transparency with the alpha argument to geom_pont
ggplot(surveys, 
       aes(x = weight, 
           y = hindfoot_length)) +
  geom_point(alpha = 0.1)

# Add color with the color argument to geom_point
ggplot(surveys, 
       aes(x = weight, 
           y = hindfoot_length)) +
  geom_point(alpha = 0.1, 
             color = "blue")

# Add color by species with color argument to aes
ggplot(surveys, 
       aes(x = weight, 
           y = hindfoot_length)) +
  geom_point(alpha = 0.1, 
             aes(color=species_id))
#aes in geom_point specifies only for the point

# aes argument to ggplot specifies for the whole graph, 
ggplot(surveys, 
       aes(x = weight,
           y = hindfoot_length,
           color=species_id)) +
  geom_point(alpha = 0.1)

################## Exercise 1 #################################################
#Use the previous example as a starting point.

#Add color to the data points according to the plot from which the sample was 
#taken (plot_id).

#Hint: Check the class for plot_id. Consider changing the class of plot_id from 
#integer to factor. Why does this change how R makes the graph?

#creates a color gradient because plot_id is a number, not character
ggplot(surveys, 
       aes(x = weight,
           y = hindfoot_length,
           color=plot_id)) +
  geom_point(alpha = 0.1)

#you can tell ggplot to read it as a character rather than a number
# using as.character
ggplot(surveys, 
       aes(x = weight,
           y = hindfoot_length,
           color=as.character(plot_id))) +
  geom_point(alpha = 0.1)
###############################################################################

## plotting categorical variables

ggplot(surveys, 
       aes(x = species_id,         # factor variable
           y = hindfoot_length)) + # numeric variable
  geom_point()

# try a new geom: geom_jitter()
ggplot(surveys, 
       aes(x = species_id,         # factor variable
           y = hindfoot_length)) + # numeric variable
  geom_jitter(alpha = 0.1)


# Make a boxplot 
ggplot(surveys, 
       aes(x = species_id,         # factor variable
           y = hindfoot_length)) + # numeric variable
  geom_boxplot()

# Overlay points on a boxplot
ggplot(surveys, 
       aes(x = species_id, 
           y = hindfoot_length)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.1, 
              color = "tomato")

#order is important
ggplot(surveys, 
       aes(x = species_id, 
           y = hindfoot_length)) +
  geom_jitter(alpha = 0.1, 
              color = "tomato")+
  geom_boxplot() 

################### Exercise 2 ############################################
# Plot the same data as in the previous example, but as a Violin plot
# Hint: see geom_violin().

# What information does this give you about the data that a box plot does?

ggplot(data = surveys, 
       aes(x = species_id, 
           y = hindfoot_length)) +
  geom_violin() 

###########################################################################

