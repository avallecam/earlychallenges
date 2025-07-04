# tidyr::complete() & tidyr::full_seq() -----------------------------------

# Turning implicit missing values into explicit missing values.
# Bonus: Filling in gaps in a date range

library(tidyr)
library(tibble)
library(dplyr)

# Making up some observations from two weather stations. 
# Some fields are nested and shouldn't be crossed e.g. station and id.
# Other observations are missing days with no data.

weather <- tibble(
  weather_station_id = c(123, 123, 123, 123, 456, 456, 456),
  weather_station_name = c("Sydney", "Sydney", "Sydney", "Sydney", "Melbourne", 
                           "Melbourne", "Melbourne"),
  dates = c("2020-01-01", "2020-01-02", "2020-01-04", "2020-01-07", 
            "2020-01-02", "2020-01-04", "2020-01-07"),
  temp = c(29, 31, 27, 24, 32, 34, 35), 
) %>% 
  mutate(dates = as.Date(dates))

weather

# Nesting the id and station name, expand()ing dates, but rather than
# use the dates present in the data we want to fill in the entire date sequence.

weather %>% 
  complete(nesting(weather_station_id, weather_station_name), 
           dates = full_seq(dates, 1))


# use {incidence2} -------------------------------------------------------

# WARNING: assuming "temp" as counts
weather %>%
  incidence2::incidence(
    date_index = "dates",
    counts = "temp",
    complete_dates = TRUE,
    groups = "weather_station_name"
  )
