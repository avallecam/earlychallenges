library(tidyverse)

# read raw data -----------------------------------------------------------

# scenario:
# - pre-processed in excel
# - manually filled cells

raw_data <- tribble(
  ~id_person, ~test_result,        ~food_place,  ~birth_place,
        7177,    "positiv",    "mercado belen",     "Ánchash",
        0177,   "positivo",       "mer. belen",     "huánuco",
        7178,        "pos", "en Mercado Belen", NA_character_
)

raw_data

# clean test_result -------------------------------------------------------

# combo:
# - case_when + str_detect

raw_data %>%
  select(test_result) %>%
  mutate(
    test_result_clean = case_when(
      str_detect(test_result, "pos") ~ "positive",
      TRUE ~ test_result
    )
  )

# clean food_place --------------------------------------------------------

# combo:
# - snakecase
# - case_when + str_detect

raw_data %>%
  select(food_place) %>%
  mutate(food_place = snakecase::to_snake_case(food_place)) %>%
  mutate(food_placet_clean = case_when(
    str_detect(food_place, "belen") ~ "market_belen",
    TRUE ~ food_place
  ))

# clean id_person ---------------------------------------------------------

# combo:
# - as.character
# - case_when + str_length + str_replace + regular expression

raw_data %>%
  select(id_person) %>%
  mutate(id_person = as.character(id_person)) %>%
  mutate(id_person_clean = case_when(
    str_length(id_person) == 3 ~ str_replace(id_person, "(.+)", "0\\1"),
    TRUE ~ id_person
  ))


# clean birth_place -------------------------------------------------------

# simulate an scenario with repeated observations
sim_data <- raw_data %>%
  select(birth_place) %>%
  bind_rows(
    raw_data %>%
      select(birth_place)
  )

# issue:
# - is creates trailing digits per replicate

sim_data %>%
  mutate(birth_place = janitor::make_clean_names(birth_place))

# combo:
# case_when + janitor::make_clean_names + str_replace + regular expression

sim_data %>%
  mutate(birth_place = case_when(
    !is.na(birth_place) ~ janitor::make_clean_names(birth_place),
    TRUE ~ NA_character_
  )) %>%
  mutate(birth_place = str_replace(
    string = birth_place,
    pattern = "(.+)_(\\d+)",
    replacement = "\\1"
  ))
