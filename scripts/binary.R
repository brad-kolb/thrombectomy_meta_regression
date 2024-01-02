#### work space setup ####
# load packages
library(here)
library(cmdstanr)
library(posterior)
library(bayesplot)
library(tidyverse)

# set theme
bayesplot_theme_set(theme_bw())

# read in data
file_in <- here("data", "independent_binary.csv")
data <- read_csv(file = file_in) 

dat <- list(
  N = nrow(data),
  J = length(unique(data$trial)),
  jj = data$trial,
  y = data$outcome,
  x = data$treatment,
  compute_likelihood = 1,
  N_pred = 100
)

# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "binary.stan"))
# run sampler
fit_binary <- model$sample(data = dat, chains = 4, parallel_chains = 4, save_warmup = TRUE)

fit_binary$print(max_rows=111)
``