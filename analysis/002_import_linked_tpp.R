library(tidyverse)
library(lubridate)
library(here)
source(here("analysis/R_fn/summarise_data.R"))

op_tpp <- read_csv(here("output/openprompt_linked_tpp.csv.gz"))

summarise_data(data_in = op_tpp, filename = "op_tpp")