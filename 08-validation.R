library(tidyverse)

# data -------------------------------------------------------------------

sample_dat <- tribble(
  ~id, ~date_report, ~type_visit,
  "1", "29/07/2019", "discharge",
  "2", "30/07/2019",  "referral"
)

next_dat <- tribble(
  ~id, ~date_report, ~type_visit,
  "1", "2019-08-08",           1,
  "2", "2019-08-09",           3
)

# on dates ---------------------------------------------------------------

sample_dat %>%
  dplyr::mutate(date_report = lubridate::dmy(date_report))

# stop working
next_dat %>% 
  dplyr::mutate(date_report = lubridate::dmy(date_report))

# more resilient to external change
next_dat %>% 
  cleanepi::standardize_dates(target_columns = "date_report")

# on outcome -------------------------------------------------------------

sample_dat %>%
  linelist::make_linelist(
    id = "id",
    outcome = "type_visit"
  ) %>%
  linelist::validate_linelist()

# validation detected 
# type_visit requires explicit categories
next_dat %>%
  linelist::make_linelist(
    id = "id",
    outcome = "type_visit"
  ) %>%
  linelist::validate_linelist()

# you can solve this using cleanepi::clean_using_dictionary()