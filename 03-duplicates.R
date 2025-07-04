#set random seed
set.seed(333)

#load library
library(tidyverse)

#create dataset
df <- tibble(
  x = sample(10, 10, rep = TRUE),
  y = sample(10, 10, rep = TRUE)
)

#number of raw and distinct observations
nrow(df)
nrow(distinct(df))

#do we have duplicates?
#count replicates
df %>% 
  count(x,y,sort = T)

#which observations are replicates?
df %>%   
  group_by(x,y) %>% 
  filter(n()>1)

#which observations are unique?
df %>%   
  group_by(x,y) %>% 
  filter(n()==1)

#if duplicated, then keep only the first observation
df %>% 
  distinct(x,y)


# use {cleanepi} ---------------------------------------------------------

df %>% 
  cleanepi::find_duplicates() %>% 
  cleanepi::remove_duplicates() %>% 
  cleanepi::print_report()
