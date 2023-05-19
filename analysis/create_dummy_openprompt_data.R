library(magrittr)
set.seed(3)
dummy_osop = data.frame(
  patient_id = seq(1:1000),
  sex = sample(c("male", "female"), 1000, replace = TRUE, prob = c(0.42, 0.58)),
  age = round(rnorm(1000, mean = 45, sd = 15)), 
  number_surveys = sample(1:3, 1000, replace = TRUE),
  long_covid_date = as.Date("2020-03-01") + rnbinom(1000, mu = 300, size = 20),
  breathlessness = sample(1:5, 1000, replace = T),
  fatigue = sample(1:5, 1000, replace = T),
  productivity = sample(1:5, 1000, replace = T)
)
dummy_osop$age[dummy_osop$age<18] = dummy_osop$age[dummy_osop$age<18]+18

write.csv(dummy_osop, here::here("output/dummy_openprompt.csv"),row.names = FALSE)
  