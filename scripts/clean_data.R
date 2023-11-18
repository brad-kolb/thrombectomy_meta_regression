#### preamble ####
# purpose: clean manually collected thrombectomy trial data
# author: Bradley Kolb
# date: 18-November-2023
# contact: bradkolb@gmail.com

#### work space setup ####
# load packages
library(here)
library(tidyverse)

# set input file
# this data was manually entered into a spreadsheet by me
file_in <- here("data/data_raw", "raw_data.csv")

# set output files
# independent defined as mrs 0, 1, or 2
file_out <- here("data/data_processed", "independent.csv")

# read in data
data_raw <- read_csv(
  file = file_in
)

# make tibble for independent
# these definitions follow the nomenclature from Gelman et al., Bayesian Data Analysis
independent <- tibble(
  j = data_raw %>% 
    filter(treatment_id == 1) %>% 
    .$trial_id, 
  n_0j = data_raw %>% 
    filter(treatment_id == 0) %>% 
    .$tot_actual,
  n_1j = data_raw %>% 
    filter(treatment_id ==1) %>% 
    .$tot_actual,
  y_0j = data_raw %>% 
    filter(treatment_id == 0) %>% 
    .$ind_mrs,
  y_1j = data_raw %>% 
    filter(treatment_id == 1) %>% 
    .$ind_mrs,
)

# "Relatively simple Bayesian meta-analysis is possible using the normal-theory results of the previous sections if we summarize the results of each experiment j with an approximate normal likelihood for the parameter theta_j . This is possible with a number of standard analytic approaches that produce a point estimate and standard errors, which can be regarded as approximating a normal mean and standard deviation. One approach is based on empirical logits"
independent <- independent %>% 
  mutate(
    # for each study j, one can estimate theta_j by
    y_j = log(y_1j / (n_1j - y_1j)) - log(y_0j / (n_0j - y_0j)),
    # with approximate sampling variance
    sigma2_j = 1/y_1j + 1/(n_1j - y_1j) + 1/y_0j + 1/(n_0j - y_0j)
  )

# "We use the notation y_j and sigma2_j to be consistent with our earlier expressions for the hierarchical normal model."
