library(tidyverse)
library(janitor)

db <- tibble(a = c("CARRO%", "carra_", "jarro", "gato", "gate"))

db %>%
  # Homogenize all the terms
  mutate(a_clean = janitor::make_clean_names(a)) %>%
  # Categorize according to character detection
  mutate(
    a_fixed = case_when(
      str_detect(a_clean, "carr") ~ "is_car",
      str_detect(a_clean, "jarr") ~ "is_something_else", #jar or jug
      str_detect(a_clean, "gat(o|e)") ~ "is_cat",
      TRUE ~ a_clean
    )
  )
