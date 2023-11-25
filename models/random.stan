// random effects meta-analysis

data {
  int<lower=0> J; // number of trials
  array[J] real y; // observed treatment effect for each trial
  array[J] real<lower=0> sigma; // standard error of observed treatment effect for each trial
}
parameters {
  array[J] real theta; // per-trial treatment effect
  real mu; // mean treatment effect
  real<lower=0> tau; // deviation of treatment effects
}
model {
  y ~ normal(theta, sigma); // likelihood
  theta ~ normal(mu, tau); 
  mu ~ normal(0, 10); // prior on mean treatment effect
  tau ~ cauchy(0, 5);  // prior on deviation of treatment effects
}
generated quantities {
  real y_new = normal_rng(mu, tau); // posterior predictive distribution
}

