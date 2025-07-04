# referencias!
# https://epirhandbook.com/working-with-dates.html#epiweek-alternatives
# https://epirhandbook.com/time-series-and-outbreak-detection.html#time-series-and-outbreak-detection
# https://tsibble.tidyverts.org/reference/year-week.html

# install packages --------------------------------------------------------

if(!require("tidyverse")) pak::pak("tidyverse")
if(!require("lubridate")) pak::pak("lubridate")
if(!require("aweek")) pak::pak("aweek")
if(!require("tsibble")) pak::pak("tsibble")
if(!require("remotes")) pak::pak("remotes")
if(!require("cdcper")) pak::pak("avallecam/cdcper")

# why? --------------------------------------------------------------------

# as an answer to stackoverflow question: https://stackoverflow.com/a/57466704/6702544

# packages ----------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(aweek)
library(tsibble)

# create dataset ----------------------------------------------------------------

# not random
set.seed(33)

# create data
data <- tibble(date=seq(ymd('2012-04-07'),
                        ymd('2014-03-22'), 
                        by = '1 day')) %>% 
  print()


# from date to epiweek ----------------------------------------------------


# create new columns from data

data_ts <- data %>% 
  mutate(value = rnorm(n(),mean = 5),
         #using aweek
         
         # from complete date -> create week+daynumber -> 2012-W14-7
         epiweek_d=aweek::date2week(date, week_start = "Sunday"),
         
         # from complete date -> create week -> 2012-W14
         epiweek_w=aweek::date2week(date, week_start = "Sunday", floor_day = TRUE),
         
         #using lubridate
         
         # from complete date -> create number of epiweek
         epiweek_n=lubridate::epiweek(date),
         
         # from complete date -> create name of day of week
         day_of_week=lubridate::wday(date,label = T,abbr = F),
         
         # from complete date -> create month number
         month=lubridate::month(date,label = F,abbr = F),
         # from complete date -> create yearn number
         year=lubridate::year(date)) %>% 
  
  print()

# set start of week ----------------------------------------------------------------

# for aweek
#CORE: Here you set the start of the week!

# get the default
aweek::get_week_start() #default -non-epi-
# set new reference
aweek::set_week_start(7) #sunday -epi-
# get the new result
aweek::get_week_start()


# CUIDADO: errores! --------------------------------------------------------

# los ultimos dias del 2012
# se registran como parte de la primera semana epidemiologica
# del anho 2013!

data_ts %>% filter(year==2012,epiweek_n==1)
#data_ts %>% filter(year==2012,epiweek_n==14)

# summarize ----------------------------------------------------------------

data_ts_v <- data_ts %>% 
  #warning: using only `epiweek_n` separates year and week
  #group_by(year,epiweek_n) %>% 
  group_by(epiweek_w,year,epiweek_n) %>% #cool
  summarise(avg_week_value=mean(value),
            std_week_value=sd(value)*10) %>% 
  ungroup() %>% 
  # arrange(epiweek_w) %>% 
  arrange(year,epiweek_n) %>% 
  print()

# from epiweek to date ----------------------------------------------------

data_ts_w <- data_ts_v %>% 
  
  #TASK: recover a date for that year-week
  
  #using aweek
  mutate(
    #warning: not all week-year generate the correct epiweek
    #epi_date=get_date(week = epiweek_n,year = year), # not useful
    
    # from aweek year-week -> create date of the week-floor-date 
    epi_date=aweek::week2date(epiweek_w),
    
    # from date of the week floor date -> create aweek year-week-daynumber
    wik_date=aweek::date2week(epi_date)
  ) %>% 
  # 
  print()

# data_ts_w %>% arrange(epiweek_w)
# data_ts_w %>% arrange(epi_date)

# output useful for plotting! ---------------------------------------------

#you can use aweek::week2date() output with ggplot
data_ts_w %>% 
  ggplot(aes(x = epi_date, y = avg_week_value)) + 
  geom_line() + 
  scale_x_date(date_breaks="5 week", date_labels = "%Y-%U") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Weekly time serie",
       x="Time (Year - CDC epidemiological week)",
       y="Average of weekly values")

#ggsave("figure/000-timeserie-week.png",height = 3,width = 10)


# replicate real situation ------------------------------------------------

# year and week integers in different columns only!

data_ts_x <- data_ts_w %>%
  select(epiweek_w,avg_week_value,std_week_value) %>% 
  separate(col = epiweek_w, 
           sep = "-W", 
           into = c("year_integer","week_integer"),
           remove = FALSE) %>% 
  mutate(across(.cols = c(year_integer,week_integer),
                .fns = as.numeric)) %>% 
  print()

# use cdcper::cdc_yerasweek_to_date ---------------------------------------
# OR
# use stringr::str_c() -> tsibble::yearweek -------------------------------

data_ts_y <- data_ts_x %>% 
  
  #TASK: recover a date for that year-week
  
  # use cdcper
  # from year + epiweek integers -> create date of the week-floor-date 
  cdcper::cdc_yearweek_to_date(year_integer = year_integer,
                               week_integer = week_integer) %>% 
  
  # use tsibble
  # from year + epiweek character -> create yearweek vector
  mutate(epiweek_c = str_c(year_integer," W",week_integer)) %>%
  mutate(tsibble_w = tsibble::yearweek(epiweek_c, week_start = 7)) %>% 
  
  # remove duplicate [bug]
  distinct(year_integer,week_integer,.keep_all = T) %>% 
  
  print()


# for plotting... aweek, tsibble or cdcper? -------------------------------

# aweek (not)
# data_ts_y %>% 
#   ggplot(aes(x = epiweek_w,y = avg_week_value)) +
#   geom_line()

# cdcper (yes)
data_ts_y %>% 
  ggplot(aes(x = epi_date,y = avg_week_value)) +
  geom_line()


# tsibble (yes)
data_ts_y %>% 
  ggplot(aes(x = tsibble_w,y = avg_week_value)) +
  geom_line()


# ¿como mostrar anhos? ----------------------------------------------------

data_ts_y %>% 
  ggplot(aes(x = epi_date,y = avg_week_value)) +
  geom_line() +
  scale_x_date(date_labels = "%Y-%U",
               date_breaks="4 week") +
  theme(axis.text.x = element_text(angle = 90,  # nuevo 
                                   vjust = 0.5, 
                                   hjust=1))

data_ts_y %>% 
  ggplot(aes(x = epi_date,y = avg_week_value)) +
  geom_line() +
  scale_x_date(date_labels = "%U",
               date_breaks="4 week") +
  facet_grid(~year_integer,
             scales = "free",
             space = "free")

data_ts_y %>% 
  select(epi_date,year_integer,avg_week_value,std_week_value) %>% 
  pivot_longer(cols = -c(epi_date,year_integer),
               names_to = "key",
               values_to = "value") %>% 
  # identity()
  ggplot(aes(x = epi_date,y = value, color = key)) +
  geom_line() +
  scale_x_date(date_labels = "%U",
               date_breaks="4 week") +
  facet_grid(~year_integer,
             scales = "free",
             space = "free")


# use {incidence} --------------------------------------------------------

data %>%
  mutate(value = rnorm(n(), mean = 5)) %>%
  incidence2::incidence(
    date_index = "date",
    counts = "value",
    # interval = "week"
  ) %>%
  mutate(
    rolling_average = data.table::frollmean(count, n = 3L, align = "right")
  ) %>%
  plot(border_colour = "white") +
  geom_line(aes(x = date_index, y = rolling_average))

