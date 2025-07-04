
library(tidyverse)
library(janitor)
library(rlang)
library(lubridate)

cdcper_fix_dates_noti <- function(data,variable) {
  
  c_var <- enquo(variable)
  c_var_name_01 <- c_var %>% as_name() %>% paste(collapse = "") %>% str_c("prb_",.)
  c_var_name_02 <- c_var %>% as_name() %>% paste(collapse = "") %>% str_c("sol_",.)
  
  data %>% 
    mutate(fecha_problema_string={{variable}}) %>% 
    mutate(fecha_problema_string=str_replace(fecha_problema_string,"(.+) (.+)","\\1")) %>% 
    
    #classify
    mutate(fecha_problema_tipo=case_when(
      str_detect(fecha_problema_string,"-")~"tipo_raya",
      str_detect(fecha_problema_string,":") & str_detect(fecha_problema_string,"/") ~"tipo_barra_colon",
      str_detect(fecha_problema_string,"/")~"tipo_barra",
      str_detect(fecha_problema_string,"\\.")~"tipo_punto",
      str_detect(fecha_problema_string,"mar|apr|may")~"tipo_texto",
      str_length(fecha_problema_string)==5~"tipo_numero",
      #str_length(fecha_problema_string)==9~"tipo_alfanumero",
      is.na(fecha_problema_string)~"tipo_missing",
      TRUE~"tipo_else"
    )) %>% 
    #convert
    mutate(fecha_solucion=case_when(
      fecha_problema_tipo=="tipo_raya"~ mdy(fecha_problema_string),
      fecha_problema_tipo=="tipo_barra_colon"~ mdy_hm(fecha_problema_string) %>% date(),
      fecha_problema_tipo=="tipo_barra"&
        str_replace(fecha_problema_string,"(.+)\\/(.+)\\/(.+)","\\1") %>% 
        as.numeric()<=12 ~ mdy(fecha_problema_string),
      fecha_problema_tipo=="tipo_barra"&
        str_replace(fecha_problema_string,"(.+)\\/(.+)\\/(.+)","\\2") %>% 
        as.numeric()<=12 ~ dmy(fecha_problema_string),
      fecha_problema_tipo=="tipo_punto" ~ mdy(fecha_problema_string),
      fecha_problema_tipo=="tipo_texto" ~ mdy(fecha_problema_string),
      #fecha_problema_tipo=="tipo_alfanumero" ~ dmy(fecha_problema_string),
      fecha_problema_tipo=="tipo_numero" ~ excel_numeric_to_date(date_num = as.numeric(fecha_problema_string),
                                                                 date_system = "modern")
      
      
    )) %>% 
    select(-fecha_problema_string) %>% 
    rename(!!c_var_name_01 := fecha_problema_tipo,
           !!c_var_name_02 := fecha_solucion)
}



dat <- tibble(issue=c(
  "06-17-2017",
  "44141"))

dat %>% 
  cdcper_fix_dates_noti(variable = issue) %>% 
  mutate(year=year(sol_issue),
         month=month(sol_issue),
         day=day(sol_issue))

# use {cleanepi} ---------------------------------------------------------

# Read data
# e.g.: if path to file is data/simulated_ebola_2.csv then:
raw_ebola_data <- rio::import(
  "https://epiverse-trace.github.io/tutorials-early/data/simulated_ebola_2.csv"
) %>%
  dplyr::as_tibble() # for a simple data frame output

raw_ebola_data %>% 
  cleanepi::standardize_column_names() %>% 
  dplyr::select(date_onset) %>% 
  cdcper_fix_dates_noti(variable = date_onset)
