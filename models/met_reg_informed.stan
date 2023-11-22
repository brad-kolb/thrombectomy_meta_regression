// bayesian meta-regression using normal approximation with informed priors
// fixed effects for type of trial (large core, small core, late, basilar)
// see chapter 5 of Bayesian Data Analysis by Gelman et al
// or https://statmodeling.stat.columbia.edu/2022/02/28/answering-some-questions-about-meta-analysis-using-ivermectin-as-an-example/

data {
  int<lower=1> J; // number of trials
  int<lower=1> K; // types of trials
  vector[J] est;
  vector[J] se;
  array[J] int<lower=1,upper=K> kk; // covariate for fixed effect of trial type
}
parameters {
  real mu;
  real<lower=0> tau;
  vector[K] beta;
  vector<offset=mu,multiplier=tau>[J] phi;
}
transformed parameters {
  vector[J] theta;
  for (j in 1:J) {
    theta[j] = phi[j] + beta[kk[j]];
  }
}
model {
  beta ~ std_normal();
  mu ~ std_normal();
  tau ~ std_normal();
  est ~ normal(theta, se);
  phi ~ normal(mu, tau);
}
generated quantities {
  vector[K] theta_new;
  for (k in 1:K) {
    theta_new[k] = normal_rng(mu + beta[k], tau);
  }
}
