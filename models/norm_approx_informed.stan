// bayesian meta-analysis using normal approximation and informed priors
// see chapter 5 of Bayesian Data Analysis by Gelman et al
// or https://statmodeling.stat.columbia.edu/2022/02/28/answering-some-questions-about-meta-analysis-using-ivermectin-as-an-example/

data {
  int J;
  vector[J] est;
  vector[J] se;
}
parameters {
  real mu;
  real<lower=0> tau;
  vector<offset=mu, multiplier=tau>[J] theta;
}
model {
  mu ~ normal(0, 1);
  tau ~ normal(0, 1);
  est ~ normal(theta, se);
  theta ~ normal(mu, tau);
}
generated quantities {
  real theta_new = normal_rng(mu, tau);
}

