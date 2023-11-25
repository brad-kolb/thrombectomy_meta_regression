data {
  int J;
  vector[J] est;
  vector[J] se;
}
parameters {
  real mu;
  real<lower=0> tau;
  vector[J] theta_z;  
}
transformed parameters {
  vector[J] theta = mu + tau * theta_z;  
}
model {
  mu ~ normal(0, 1);
  tau ~ normal(0, 1);
  theta_z ~ normal(0, 1); 
  est ~ normal(theta, se);
}
generated quantities {
  real theta_new = normal_rng(mu, tau);
}

