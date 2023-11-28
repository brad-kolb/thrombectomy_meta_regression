// random effects metaanalysis with binary data, non-centered parameterization
data{
  int<lower=1> N; // observations
  int<lower=1> J; // trials
  array[N] int<lower=1,upper=J> jj; // trial covariate
  array[N] int<lower=0,upper=1> x; // intervention covariate
  array[N] int<lower=0,upper=1> y; // outcome
}
parameters{
  real rho; // population mean log odds of success, control
  real<lower=0> sigma; // population sd log odds of success, control
  vector[J] z_phi; // per trial log odds of success, control (standardized)
  real mu; // population mean treatment effect (log odds ratio)
  real<lower=0> tau; // population sd treatment effect
  vector[J] z_theta; // per trial treatment effect (standardized)
}
model{
  // likelihood
  vector[N] p; 
  for (n in 1:N) {
  p[n] = (rho + z_phi[jj[n]] * sigma) + ((mu + z_theta[jj[n]] * tau) * x[n]);
  p[n] = inv_logit(p[n]);
  }
  y ~ bernoulli(p);
  // priors
  { mu, rho } ~ normal(0, 1); 
  { sigma, tau } ~ normal(0, 1); 
  z_phi ~ normal(0, 1); 
  z_theta ~ normal(0, 1); 
}
generated quantities{
  // marginal posterior distributions
  vector[J] phi = rho + z_phi * sigma; // population log odds of success
  vector[J] theta = mu + z_theta * tau; // population treatment effect
  // posterior predictive distributions
  real phi_new = normal_rng(rho,sigma); // control group log odds of success in a new trial
  real theta_new = normal_rng(mu,tau); // treatment effect in new trial
}

