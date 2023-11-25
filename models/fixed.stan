// fixed effects meta-analysis

data {
  int<lower=0> J; // number of trials
  array[J] real y; // observed log odds ratio for each trial
  array[J] real<lower=0> sigma; // observed standard error for each trial
}
parameters {
  real theta;  // global treatment effect, log odds ratio
}
model {
  y ~ normal(theta, sigma); // likelihood
}


