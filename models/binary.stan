// random effects metaanalysis with binary data non-centered parameterization
data {
  // data for posterior estimation
  int<lower=1> N; // observations
  int<lower=1> J; // trials
  array[N] int<lower=1,upper=J> jj; // trial covariate
  array[N] int<lower=0,upper=1> x; // intervention covariate
  array[N] int<lower=0,upper=1> y; // outcome
  // data for predictive simulation
  int<lower=1> N_pred;
  // switch for running model forward (prior predictive simulation) or backward (posterior estimation)
  int<lower=0> compute_likelihood;
}
parameters {
  // control group
  real rho; // population mean log odds of success
  real<lower=0> sigma; // population sd log odds of success
  vector<offset=rho,multiplier=sigma> [J] phi; // per trial log odds of success
  // treatment
  real mu; // population mean treatment effect (log odds ratio)
  real<lower=0> tau; // population sd treatment effect
  vector<offset=mu,multiplier=tau> [J] theta; // per trial treatment effect 
}
model {
  if (compute_likelihood == 1) {
  // linear model
  vector[N] q;
  for (n in 1:N) {
    q[n] = phi[jj[n]] + theta[jj[n]] * x[n];
  }
  // convert log odds to probabilities
  vector[N] p = inv_logit(q[1:N]);
  // likelihood
  y[1:N] ~ bernoulli(p[1:N]);
  }
  // hyperpriors
  phi[1:J] ~ normal(rho, sigma);
  theta[1:J] ~ normal(mu, tau); 
  // priors
  { mu, rho } ~ normal(0, 1); 
  { sigma, tau } ~ normal(0, 1); 
}
generated quantities {
  // posterior predictive distributions
  real phi_new = normal_rng(rho,sigma); // log odds success new trial control
  real theta_new = normal_rng(mu,tau); // treatment effect new trial
  // relative risk
  real or_pred = exp(theta_new); // odds ratio
  // absolute risk
  real arr_pred = inv_logit(phi_new + theta_new) - inv_logit(phi_new); // absolute risk reduction 
  real nnt_pred = 1 / arr_pred + 1e-6; // number needed to treat (small correction factor for numerical stability)
  // posterior predictive simulation
  int y_treat_pred = binomial_rng(N_pred, inv_logit(phi_new + theta_new));
  int y_cont_pred = binomial_rng(N_pred, inv_logit(phi_new));
}

