// bayesian meta-regression using normal approximation 
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
  vector<offset=mu,multiplier=tau>[J] phi;
  real beta;
  real<lower=0> sigma;
  vector<offset=beta,multiplier=sigma>[K] psi;
}
transformed parameters {
  vector[J] theta;
  for (j in 1:J) {
    theta[j] = phi[j] + psi[kk[j]];
  }
}
model {
  mu ~ std_normal();
  beta ~ std_normal();
  sigma ~ std_normal();
  tau ~ std_normal();
  est ~ normal(theta, se);
  phi ~ normal(mu, tau);
  psi ~ normal(beta, sigma);
}
generated quantities {
  vector[K] theta_new;
  for (k in 1:K) {
    theta_new[k] = normal_rng(mu, tau) + psi[k];
  }
}



