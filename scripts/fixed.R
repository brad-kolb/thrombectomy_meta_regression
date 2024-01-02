#### work space setup ####
# load packages
library(here)
library(cmdstanr)
library(posterior)
library(bayesplot)
library(tidyverse)

# set theme
bayesplot_theme_set(theme_bw())

# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "fixed.stan"))

# data
file_in <- here("data", "independent.csv")
data <- read_csv(file = file_in) 
dat <- list(J = nrow(data),
            n_c = data$n_c,
            r_c = data$r_c,
            n_t = data$n_t,
            r_t = data$r_t,
            compute_likelihood = 1,
            priors = 1
)

# run sampler

# informed priors
fixed_informed <- model$sample(data = dat, 
                             chains = 4,
                             parallel_chains = 4,
                             save_warmup = TRUE)
#flat priors
dat$priors <- 0
fixed_flat <- model$sample(data = dat, 
                         chains = 4,
                         parallel_chains = 4,
                         save_warmup = TRUE)

# get summaries
fixed_informed$summary(variables = c("theta", "mean_y_obs", "mean_sigma_obs"))
fixed_flat$summary(variables = c("theta", "mean_y_obs", "mean_sigma_obs"))
