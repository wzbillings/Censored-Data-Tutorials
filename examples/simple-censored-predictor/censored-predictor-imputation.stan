//
// Regression model with a single censored predictor
// Censoring handled by constrained imputation
// Zane Billings
// 2024-07-15
//

// The input data consists of:
// N: positive scalar integer. The number of data records.
// y: real vector of length N. The vector of outcome variable observations.
// x: real vector of length N. The vector of predictor variable observations.
// c: integer array of length N, either 0 or 1 for all entries.
//   c[i] = 0 if observation i is observed and c[i] = 1 if observation i is
//   censored.
// u: real vector of length N. The vector of lower limits of detection.
data {
  int<lower=0> N;
  int<lower=0> N_obs;
  array[N] real y;
  array[N_obs] real x_obs;
  real LoD;
}

// Transformed data
// Computed from passed data
transformed data {
  // Number of censored and observed observations
  int<lower=0> N_cens = N - N_obs;
}

// The parameters accepted by the model.
parameters {
  // Regression parameters
  real a, b;
  real<lower = 0> sigma;
  
  // x distribution parameters
  real x_mu;
  real <lower=0> x_sd;
  
  // Vector of censored x values
  array[N_cens] real<upper=LoD> x_cens;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  // x holder
  vector[N] x;
  // mu vector
  vector[N] mu;
  
  // Priors
  a ~ student_t(3, 0, 2);
  b ~ student_t(3, 0, 2);
  sigma ~ student_t(3, 0, 2);
  x_mu ~ student_t(3, 0, 2);
  x_sd ~ student_t(3, 0, 2);
  
  // Likelihood
  x_obs ~ normal(x_mu, x_sd);
  x_cens ~ normal(x_mu, x_sd);
  x = to_vector(append_array(x_obs, x_cens));
  mu = a + b * x;
  y ~ normal(mu, sigma);
}

