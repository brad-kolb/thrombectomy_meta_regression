// random effects metaanalysis with binary data
data{
  int<lower=1> N;
  int<lower=1> J;
  array[N] int<lower=1,upper=J> jj;
  array[N] int<lower=0,upper=1> x;
  array[N] int<lower=0,upper=1> y;
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
  // priors
  { mu, rho } ~ normal(0, 1); 
  { sigma, tau } ~ normal(0, 1); 
  z_phi ~ normal(0, 1); 
  z_theta ~ normal(0, 1); 
  // likelihood
  vector[N] p; 
  for (n in 1:N) {
  p[n] = (rho + z_phi[jj[n]] * sigma) + ((mu + z_theta[jj[n]] * tau) * x[n]);
  p[n] = inv_logit(p[n]);
  }
  y ~ bernoulli(p);
}
generated quantities{
  // population log odds of success
  vector[J] phi = rho + z_phi * sigma;
  // population treatment effect (log odds ratio)
  vector[J] theta = mu + z_theta * tau;  
  //  posterior predictive distribution for treatment effect in new trial
  real theta_new = normal_rng(mu,tau); 
}

