// random effects meta-analysis with trial-specific covariates ("meta-regression")
// non-centered parameterization

data {
  int<lower=1> J; // number of trials
  int<lower=1> K; // number of trial types
  array[J] int<lower=1, upper=K> x; //trial-specific covariate
  array[J] real y; // observed treatment effect for each trial
  array[J] real<lower=0> sigma; // standard error of observed treatment effect for each trial
}
parameters {
  array[K] real beta; // per-trial-type treatment effect
  
  real mu; // mean treatment effect
  real<lower=0> tau; // deviation of treatment effects
  vector<offset=mu,multiplier=tau>[J] theta; // per-trial treatment effect
}
model {
  // likelihood
  for (j in 1:J) {
  y[j] ~ normal(theta[j] + beta[x[j]], sigma[j]); 
  }
  // priors
  for (j in 1:J) {
  theta[j] ~ normal(mu, tau);
  }
  { mu, tau } ~ normal(0,1);
  beta ~ normal(0,1);
}
generated quantities {
  array[K] real y_new;
  for (k in 1:K) {
  y_new[k] = normal_rng(mu, tau) + beta[k];
  }
}
