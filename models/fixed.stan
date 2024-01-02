// fixed effects meta-analysis
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
  real theta; // global treatment effect, log odds ratio
}
model {
  // likelihood
  if (compute_likelihood ==1) {
  y[1:J] ~ normal(theta, sigma[1:J]); // likelihood
  }
  // priors
  if (priors == 1) {
    theta ~ std_normal();
  }
}
generated quantities{
  array[J] real y_obs = y;
  array[J] real sigma_obs = sigma;
  real mean_y_obs = mean(y);
  real mean_sigma_obs = mean(sigma);
}


