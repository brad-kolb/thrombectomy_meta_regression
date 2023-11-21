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
file_out <- here("fits", 
                 "normal_approx.rds")

data_out <- here("results",
                 "normal_approx.csv")

#### model fit  ####
# import processed data for mrs 0-2
file_in <- here("data", 
                "independent.csv")

# read in data
data <- read_csv(file = file_in) 

# create trimmed data list appropriate for stan
dat <- list(J = nrow(data),
            est = data$est,
            se = data$se)

# translate and compile
model <- cmdstan_model(here("models", 
                            "norm_approx.stan"))

# run sampler
fit <- model$sample(data = dat, 
                    chains = 4,
                    parallel_chains = 4,
                    save_warmup = TRUE)

# save model fit
fit$save_object(file = file_out)

#### summarize fit ####
# view output
fit$print(max_rows=100) 
# save output
fit$summary() %>% 
  write_delim(data_out, " ")

# 95% intervals for hyperparameters and posterior predictive distribution
fit$summary(variables = c("mu", "tau", "theta_new"),
            "mean",
            "sd",
            extra_quantiles = ~posterior::quantile2(., probs = c(.0275, .975)))

#### diagnostic plots ####

### r_hat ###
# as total variance shrinks to the average within chain variance, r_hat approaches 1
# a heuristic for convergence of chains. not a test
mcmc_rhat(rhat(fit))

### n_eff ###
# how long would the chain be if each sample was perfectly independent
# due to autocorrelation most values should be less than one
# heuristic is to worry about any values less than 0.1
mcmc_neff(neff_ratio(fit, size = 2))

### trace plot ###
draws <- posterior::as_draws_array(fit) # extract posterior draws
np_fit <- nuts_params(fit) # get NUTS parameters
mcmc_trace(draws, pars = c("mu","tau"),np = np_fit) + 
  xlab("Post-warmup iteration")
