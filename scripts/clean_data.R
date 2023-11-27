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

#### convert to long format ####
file_out <- here("data", "independent_binary.csv")

trial_control_success <- unlist(map2(independent$J, independent$r_c, function(x,y) rep(x,y)))
trial_control_fail <- unlist(map2(independent$J, independent$n_c - independent$r_c, function(x,y) rep(x,y)))
success_control <- unlist(map(independent$r_c, function(x) rep(1, x)))
failure_control <- unlist(map(independent$n_c - independent$r_c, function(x) rep(0, x)))
binary_control <- tibble(
  trial = c(trial_control_success, trial_control_fail),
  outcome = c(success_control, failure_control),
  treatment = 0
)

trial_treatment_success <- unlist(map2(independent$J, independent$r_t, function(x,y) rep(x,y)))
trial_treatment_fail <- unlist(map2(independent$J, independent$n_t - independent$r_t, function(x,y) rep(x,y)))
success_treatment <- unlist(map(independent$r_t, function(x) rep(1, x)))
failure_treatment <- unlist(map(independent$n_t - independent$r_t, function(x) rep(0, x)))
binary_treatment <- tibble(
  trial = c(trial_treatment_success, trial_treatment_fail),
  outcome = c(success_treatment, failure_treatment),
  treatment = 1
)

binary <- rbind(binary_control, binary_treatment)

binary %>% 
  write_csv(file_out)

binary %>% print(n=100)

