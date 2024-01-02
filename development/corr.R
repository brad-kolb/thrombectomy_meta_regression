# fake data simulation
# for multilevel logistic regression
# with correlated individual features
# and group-level predictors

set.seed(0)
# step 1: generate fake predictors
N <- 1e3 # number of individuals
K <- 2 # number individual predictors
J <- 20 # number of groups
L <- 1 # number of group predictors
jj <- sample(1:J, N, replace = TRUE) # group membership
u <- matrix(sample(1:4, J*L, replace = TRUE), J, L) # group predictors
x1 <- rep(1, N) # intercepts
x2 <- matrix(sample(0:1, N*(K-1), replace = TRUE), N, K-1) # slopes
x <- cbind(x1, x2) # individual predictors
# step 2: generate fake parameters
omega <- rethinking::rlkjcorr(1, K, 2) # correlation matrix
tau <- rnorm(K, 0, 1) # scales
tau[tau < 0] <- abs(tau[tau < 0]) # enforce positivity
gamma <- matrix(rnorm(L * K, 0, 1), L, K) # group-level coefficients
beta <- array(dim = c(J, K)) # placeholder for individual-level coefficients
for (j in 1:J) { 
  tau_mat <- diag(tau) # create a diagonal matrix from tau
  cov_mat <- tau_mat %*% omega %*% tau_mat # construct the covariance matrix
  beta[j, ] <- MASS::mvrnorm(1, u[j, ] %*% gamma, cov_mat) 
}
# step 3: generate fake outcomes
y <- rep(NA, N) # placeholder for outcomes
sigma <- 1 # scale fixed at 1
for (n in 1:N) { # latent-space outcomes
  y[n] <- rlogis(1, beta[jj[n], ] %*% x[n, ], sigma)
}
y_prob <- exp(y)/(1 + exp(y)) # inverse logit transformation
y_obs <- rethinking::rbern(y_prob)

#### fit ####

dat = list(
  N = N, 
  K = K,
  J = J,
  L = L,
  jj = jj,
  x = x,
  u = t(u),
  y = y_obs
)

# translate and compile stan model to c++
model <- cmdstan_model(here("development", 
                            "corr_binary.stan"))

# run sampler
fit <- model$sample(data = dat, chains = 4, parallel_chains = 4, save_warmup = TRUE)

fit$summary(variables = "tau")
tau
