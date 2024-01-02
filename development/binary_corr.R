# fake data simulation
# for multilevel logistic regression
# with correlated features
library(MASS) # library with multivariate normal random number generator
library(rethinking) # library with lkj correlation matrix random number generator

# step 1: generate fake predictors
N <- 1e3 # number of individuals
K <- 2 # number predictors
J <- 20 # number of groups
jj <- sample(1:J, N, replace = TRUE) # group membership
x1 <- rep(1, N) # intercepts
x2 <- matrix(sample(0:1, N * (K - 1), replace = TRUE), N, K - 1) # slopes
x <- cbind(x1, x2) # individual predictors

# step 2: generate fake parameters
mu <- rnorm(K, 0, 1) # population means
omega <- rethinking::rlkjcorr(1, K, 2) # correlation matrix
tau <- rnorm(K, 0, 1) # scales
tau[tau < 0] <- abs(tau[tau < 0]) # enforce positivity
beta <- array(dim = c(J, K)) # placeholder for individual-level coefficients
for (j in 1:J) { 
  tau_mat <- diag(tau) # create a diagonal matrix from tau
  cov_mat <- tau_mat %*% omega %*% tau_mat # construct the covariance matrix
  beta[j, ] <- MASS::mvrnorm(1, mu, cov_mat) # sample correlated features
}

# step 3: generate fake outcomes
y <- rep(NA, N) # placeholder for outcomes
sigma <- 1 # error scale fixed at 1
for (n in 1:N) { # latent-space outcomes
  y[n] <- rlogis(1, beta[jj[n], ] %*% x[n, ], sigma) # linear model via matrix multiplication
}
y_prob <- exp(y) / (1 + exp(y)) # inverse logit transformation
y_obs <- rbinom(N = length(y_prob), size = 1, prob = y_prob) # bernoulli rng
