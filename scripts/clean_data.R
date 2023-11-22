#### preamble ####
# purpose: clean manually collected thrombectomy trial data
# author: Bradley Kolb
# date: 18-November-2023
# contact: bradkolb@gmail.com
# references: Bayesian Data Analysis, Gelman et al. (BDA)

#### work space setup ####
# load packages
library(here)
library(tidyverse)

# set input file
# this data was manually entered into a spreadsheet by me
file_in <- here("data", "raw_data.csv")

# set output files
# independent defined as mrs 0, 1, or 2
file_out <- here("data", "independent.csv")

# read in data
data <- read_csv(
  file = file_in
)

# make tibble holding results for independent patients in treatment and control arms
# column names follow the conventions from BDA
independent <- tibble(
  J = data %>% 
    filter(treatment_id == 1) %>% 
    .$trial_id, 
  K = data %>% 
    filter(treatment_id == 1) %>% 
    .$group_id,
  n_0 = data %>% 
    filter(treatment_id == 0) %>% 
    .$tot_actual,
  n_1 = data %>% 
    filter(treatment_id ==1) %>% 
    .$tot_actual,
  y_0 = data %>% 
    filter(treatment_id == 0) %>% 
    .$ind_mrs,
  y_1 = data %>% 
    filter(treatment_id == 1) %>% 
    .$ind_mrs,
)

# add estimates for treatment effect and standard error
# quotes are from BDA
# "Relatively simple Bayesian meta-analysis is possible using the normal-theory results of the previous sections if we summarize the results of each experiment j with an approximate normal likelihood for the parameter theta_j . This is possible with a number of standard analytic approaches that produce a point estimate and standard errors, which can be regarded as approximating a normal mean and standard deviation. One approach is based on empirical logits"
independent <- independent %>% 
  mutate(
# for each study j, one can estimate theta_j by
    est = log(y_1 / (n_1 - y_1)) - log(y_0 / (n_0 - y_0)),
# with approximate sampling variance
    se = 1/y_1 + 1/(n_1 - y_1) + 1/y_0 + 1/(n_0 - y_0)
  )

# save as csv file
independent %>% 
  write_csv(file_out)
