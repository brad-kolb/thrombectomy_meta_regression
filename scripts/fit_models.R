#### preamble ####
# purpose: fit models to stroke thrombectomy data
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

# read in data
file_in <- here("data", "independent.csv")
data <- read_csv(file = file_in) 
# create trimmed data list appropriate for stan
dat <- list(J = nrow(data),
            y = data$y,
            sigma = data$sigma)

#### fixed effects model #### 
file_out <- here("fits", 
                 "fixed.rds")
data_out <- here("results",
                 "fixed.csv")

# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "fixed.stan"))

# run sampler
fit_fixed <- model$sample(data = dat, 
                    chains = 4,
                    parallel_chains = 4,
                    save_warmup = TRUE)
# save model fit
fit_fixed$save_object(file = file_out)
# save model summary
fit_fixed$summary() %>% 
  write_csv(data_out)

#### random effects model #### 
file_out <- here("fits", 
                 "random.rds")
data_out <- here("results",
                 "random.csv")

# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "random.stan"))

# run sampler
fit_random <- model$sample(data = dat, 
                          chains = 4,
                          parallel_chains = 4,
                          save_warmup = TRUE)
# save model fit
fit_random$save_object(file = file_out)
# save model summary
fit_random$summary() %>% 
  write_csv(data_out)

#### meta-regression model ####
# read in data
file_in <- here("data", "independent.csv")
data <- read_csv(file = file_in) 
# data <- data %>% 
#   filter(K == 1 | K == 2 | K == 3) %>% 
#   mutate(K = if_else(K == 3, 2, K))
# create trimmed data list appropriate for stan
dat <- list(J = nrow(data),
            K = max(data$K),
            x = data$K,
            y = data$y,
            sigma = data$sigma)
# set up paths
file_out <- here("fits", 
                 "meta_regression.rds")
data_out <- here("results",
                 "meta_regression.csv")
# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "meta_regression.stan"))
# run sampler
fit_meta_regression <- model$sample(data = dat, 
                           chains = 4,
                           parallel_chains = 4,
                           save_warmup = TRUE)
# save model fit
fit_meta_regression$save_object(file = file_out)
# save model summary
fit_meta_regression$summary() %>% 
  write_csv(data_out)

#### binary ####
# read in data
file_in <- here("data", "independent_binary.csv")
data <- read_csv(file = file_in) 

dat <- list(
  N = nrow(data),
  J = max(data$trial),
  jj = data$trial,
  y = data$outcome,
  x = data$treatment
)

# set up paths
file_out <- here("fits", 
                 "binary.rds")
data_out <- here("results",
                 "binary.csv")
# translate and compile stan model to c++
model <- cmdstan_model(here("models", 
                            "binary.stan"))
# run sampler
fit_binary <- model$sample(data = dat, chains = 4, parallel_chains = 4, save_warmup = TRUE)
# save model fit
fit_binary$save_object(file = file_out)
# save model summary
fit_binary$summary() %>% 
  write_csv(data_out)



# view summaries
fit_fixed$print(max_rows=100) 
fit_random$print(max_rows=100)
fit_meta_regression$print(max_rows=100)
fit_binary$print(max_rows=111)


#### diagnostic plots ####

### r_hat ###
# as total variance shrinks to the average within chain variance, r_hat approaches 1
# a heuristic for convergence of chains. not a test
mcmc_rhat(rhat(fit_fixed))
mcmc_rhat(rhat(fit_random))
mcmc_rhat(rhat(fit_meta_regression))

### n_eff ###
# how long would the chain be if each sample was perfectly independent
# due to autocorrelation most values should be less than one
# heuristic is to worry about any values less than 0.1
mcmc_neff(neff_ratio(fit_fixed, size = 2))
mcmc_neff(neff_ratio(fit_random, size = 2))
mcmc_neff(neff_ratio(fit_meta_regression, size = 2))

### trace plot ###
draws <- posterior::as_draws_array(fit_fixed) # extract posterior draws
np_fit <- nuts_params(fit_fixed) # get NUTS parameters
mcmc_trace(draws, pars = c("theta"),np = np_fit) + 
  xlab("Post-warmup iteration")

draws <- posterior::as_draws_array(fit_random) # extract posterior draws
np_fit <- nuts_params(fit_random) # get NUTS parameters
mcmc_trace(draws, pars = c("mu","tau"),np = np_fit) + 
  xlab("Post-warmup iteration")

draws <- posterior::as_draws_array(fit_meta_regression) # extract posterior draws
np_fit <- nuts_params(fit_meta_regression) # get NUTS parameters
mcmc_trace(draws, pars = c("mu","tau"),np = np_fit) + 
  xlab("Post-warmup iteration")
mcmc_trace(draws, pars = c("beta[1]", "beta[2]", "beta[3]", "beta[4]"),np = np_fit) + 
  xlab("Post-warmup iteration")
