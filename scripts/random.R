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

# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "random.stan"))

dat <- list(J = nrow(data),
            n_c = data$n_c,
            r_c = data$r_c,
            n_t = data$n_t,
            r_t = data$r_t,
            compute_likelihood = 1,
            priors = 1
)

# run sampler
random_informed <- model$sample(data = dat, 
                           chains = 4,
                           parallel_chains = 4,
                           save_warmup = TRUE)
dat$priors <- 0

random_flat <- model$sample(data = dat, 
                         chains = 4,
                         parallel_chains = 4,
                         save_warmup = TRUE)

random_informed$summary(variables = c("mu", "mean_y_obs", "tau", "mean_sigma_obs"))
random_flat$summary(variables = c("mu", "mean_y_obs", "tau", "mean_sigma_obs"))


