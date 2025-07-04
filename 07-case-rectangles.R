#' ref: https://www.reconverse.org/incidence2/doc/incidence2.html#sec:plotting-in-style-of-european-programme-for-intervention-epidemiology-training-epiet

library(tidyverse)
library(outbreaks)

fluH7N9_china_2013 %>% 
  as_tibble() %>% 
  ggplot(aes(x = date_of_onset)) +
  geom_bar() +
  scale_y_continuous(breaks = scales::pretty_breaks(10)) +
  theme_minimal() + 
  theme(
    panel.grid.major = element_line('white'),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.ontop = TRUE
  )


# use {incidence2} -------------------------------------------------------

fluH7N9_china_2013 %>%
  incidence2::incidence(date_index = "date_of_onset", interval = "epiweek") %>%
  plot(show_cases = TRUE)
