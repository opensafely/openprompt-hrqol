#' A little script to summarise a big data frame and redact outputs at the same time
#' @description A little script to summarise a big data frame and redact outputs at the same time
#' @param data_in What data do you want summarised?
#' @param filenamebase What do you want the output files to be called
#' @param output_dir relative path to the directory you want results stored
#' @return Two .txt files: one is a skimr output, the other is a more detailed summary of string, numeric, date and categorical variables
#' Adapted from https://github.com/opensafely/mab-av-non-users/blob/7a232197ca16e98c926551ee26e50feb5387007c/analysis/data_properties.R#L1
#' Written by wjchulme & LindaNab

summarise_data <- function(data_in, filenamebase, output_dir = "output/data_properties"){
  # read in the summarise functions 
  source(here::here("analysis/R_fn/redaction.R"))
  
  # skimr to print a summary of the data ------------------------------------
  options(width=200) # set output width for capture.output
  
  dir.create(here(output_dir), showWarnings = FALSE, recursive=TRUE)
  
  ## high-level variable overview ----
  capture.output(
    skimr::skim_without_charts(data_in),
    file = here(output_dir, paste0(filenamebase, "_skim", ".txt")),
    split = FALSE
  )
  
  ## tabulated data ----
  
  # delete file if it exists
  if(file.exists(here(output_dir, paste0(filenamebase, "_tabulate", ".txt")))){
    file.remove(here(output_dir, paste0(filenamebase, "_tabulate", ".txt")))
  }
  
  
  ### categorical and logical ----
  sumtabs_cat <-
    data_in %>%
    select(-ends_with("_id")) %>%
    select(where(is.character), where(is.logical), where(is.factor)) %>%
    map(redacted_summary_cat) %>%
    enframe()
  
  capture.output(
    walk2(sumtabs_cat$value, sumtabs_cat$name, print_cat),
    file = here(output_dir, paste0(filenamebase, "_tabulate", ".txt")),
    append=FALSE
  )
  
  
  ### numeric ----
  sumtabs_num <-
    data_in %>%
    select(-ends_with("_id")) %>%
    select(where(~ {!is.logical(.x) & is.numeric(.x) & !is.Date(.x)})) %>%
    map(redacted_summary_num) %>%
    enframe()
  
  capture.output(
    walk2(sumtabs_num$value, sumtabs_num$name, print_num),
    file = here(output_dir, paste0(filenamebase, "_tabulate", ".txt")),
    append=TRUE
  )
  
  ### dates ----
  
  sumtabs_date <-
    data_in %>%
    select(-ends_with("_id")) %>%
    select(where(is.Date)) %>%
    map(redacted_summary_date) %>%
    enframe()
  
  capture.output(
    walk2(sumtabs_date$value, sumtabs_date$name, print_num),
    file = here(output_dir, paste0(filenamebase, "_tabulate", ".txt")),
    append=TRUE
  )
}

