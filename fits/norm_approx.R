#### preamble ####
# purpose: fit normal approximation meta analysis model to stroke thrombectomy data
# author: Bradley Kolb
# date: 21-November-2023
# contact: bradkolb@gmail.com

#### work space setup ####
# load packages
library(cmdstanr)
library(posterior)
library(bayesplot)
library(tidyverse)

# set theme
bayesplot_theme_set(theme_bw())

# set output files
file_out <- here("fits", "normal_approx.rds")

#### model fit  ####
# import processed data for mrs 0-2
file_in <- here("data", "independent.csv")

# read in data
data <- read_csv(
  file = file_in
) 

# create trimmed data list appropriate for stan
dat <- list(
  J = nrow(data),
  est = data$est,
  se = data$se
)

# translate and compile
model <- cmdstan_model(here("models", "norm_approx.stan"))

# run sampler
fit <- model$sample(data = dat, chains = 4,
                           parallel_chains = 4,
                           save_warmup = TRUE)

# save model fit
fit$save_object(file = file_out)

#### summarize fit ####
# output
fit$print(max_rows=100) 

# 95% intervals 
fit$summary(
  variables = NULL,
#  posterior::default_summary_measures(),
  extra_quantiles = ~posterior::quantile2(., probs = c(.0275, .975))
) %>% print(n=25)

#### diagnostics ####
