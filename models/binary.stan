// random effects metaanalysis with binary data

data{
  int<lower=1> N;
  int<lower=1> J;
  array[N] int<lower=1,upper=J> jj;
  array[N] int<lower=0,upper=1> x;
  array[N] int<lower=0,upper=1> y;
}
parameters{
  real rho; // population mean chances of success, control
  real<lower=0> sigma; // population sd chances of success, control
  vector[J] z_phi; // chances of success, control (standardized)
  
  real mu; // population mean treatment effect
  real<lower=0> tau; // population sd treatment effect
  vector[J] z_theta; // treatment effect (standardized)
}
model{
  vector[N] p; // chances success each participant
  vector[J] phi;
  vector[J] theta;
  // hyperpriors
  tau ~ normal(0, 0.5); 
  mu ~ normal(0, 1); 
  rho ~ normal(0, 1);
  sigma ~ normal(0, 0.5); 
  // heirarchical priors
  z_theta ~ normal(0, 1); // non-centering 
  z_phi ~ normal(0, 1); // non-centering 
  theta = mu + z_theta * tau; // code to reverse non-centering
  phi = rho + z_phi * sigma; // code to reverse non-centering
  // likelihood 
  for (i in 1:N) {
      p[i] = phi[jj[i]] + theta[jj[i]] * x[i];
      p[i] = inv_logit(p[i]);
      }
  y ~ bernoulli(p);
}
generated quantities{
  //  posterior predictive distribution for treatment effect
  real theta_new = normal_rng(mu,tau); 
}

