// "random effects" meta-analysis
data {
  // data for posterior estimation
  int<lower=0> J;
  array[J] int<lower=0> n_t;  // num cases, treatment
  array[J] int<lower=0> r_t;  // num successes, treatment
  array[J] int<lower=0> n_c;  // num cases, control
  array[J] int<lower=0> r_c;  // num successes, control
  // switch for running model forward (prior predictive simulation) or backward (posterior estimation)
  int<lower=0> compute_likelihood;
  // switch for priors
  int<lower=0> priors;
}
transformed data {
  array[J] real y; 
  array[J] real<lower=0> sigma;
  for (j in 1:J) {
    y[j] = log(r_t[j]) - log(n_t[j] - r_t[j]) 
    - (log(r_c[j]) - log(n_c[j] - r_c[j]));
  }
  for (j in 1:J) {
    sigma[j] = sqrt(1.0 / r_t[j] + 1.0 / (n_t[j] - r_t[j]) 
    + 1.0 / r_c[j] + 1.0 / (n_c[j] - r_c[j]));
  }
}
parameters {
  real mu; // mean treatment effect
  real<lower=0> tau; // deviation of treatment effects
  vector<offset=mu,multiplier=tau>[J] theta; // per-trial treatment effect
}
model {
  // likelihood
  if (compute_likelihood == 1) {
  y[1:J] ~ normal(theta[1:J], sigma[1:J]);
  }
  // priors
  theta[1:J] ~ normal(mu, tau); 
  if (priors == 1) {
    mu ~ normal(0, 1); // prior on mean treatment effect
    tau ~ normal(0, 1);  // prior on deviation of treatment effects
  }
}
generated quantities {
  real theta_new = normal_rng(mu, tau); // posterior predictive distribution
  real or_pred = exp(theta_new); // odds ratio
  array[J] real y_obs = y;
  array[J] real sigma_obs = sigma; 
  real mean_y_obs = mean(y);
  real mean_sigma_obs = mean(sigma);
}

