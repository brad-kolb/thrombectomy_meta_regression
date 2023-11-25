#### preamble ####
# purpose: clean and prepare manually collected thrombectomy trial data
# author: Bradley Kolb
# date: 18-November-2023
# contact: bradkolb@gmail.com
# references: Bayesian Data Analysis, Gelman et al. (BDA); mc-stan.org/docs part 1 chap 6

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
independent <- tibble(
  J = data %>% # number of trials
    filter(treatment_id == 1) %>% 
    .$trial_id, 
  K = data %>% # types of trials (1=large core, 2=small core early, 3=small core late, 4=basilar)
    filter(treatment_id == 1) %>% 
    .$group_id,
  n_c = data %>% # number of cases, control
    filter(treatment_id == 0) %>% 
    .$tot_actual,
  r_c = data %>% # number of successes, control
    filter(treatment_id == 0) %>% 
    .$ind_mrs,
  n_t = data %>% # number of cases, treatment
    filter(treatment_id ==1) %>% 
    .$tot_actual,
  r_t = data %>% #number of successes, treatment
    filter(treatment_id == 1) %>% 
    .$ind_mrs,
)

# add empirical estimates for the treatment effect of each trial
independent <- independent %>% 
  mutate(
# log odds ratio
    y = log(r_t / (n_t - r_t)) - log(r_c / (n_c - r_c)),
# approximate standard error
    sigma = sqrt(1/r_t + 1/(n_t - r_t) + 1/r_c + 1/(n_c - r_c))
  )

# save as csv file
independent %>% 
  write_csv(file_out)

independent %>% print(n=100)
