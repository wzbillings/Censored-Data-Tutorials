//
// Ex2a: One censored predictor using the imputation method
// See: https://mc-stan.org/docs/stan-users-guide/censored-data.html
// Zane Billings
// 2023-10-17
//

// The input data consists of:
// - N_obs: an integer, the number of data points where the outcome was
//   completely observed.
// - N_cens: an integer, the number of data points where the outcome was below
//   the DL and thus censored.
// - y_obs: a vector of observed values of the response
// - x_cens: the x-values (in order) associated with the censored response
//   values.
// - x_obs: the x-values (in order) associated with the observed values of the
//   response variable.
data {
	int<lower=0> N_cens;
	int<lower=0> N_obs;
	array[N_obs] real y_obs;
	array[N_obs] real x_obs;
	array[N_cens] real x_cens;
	int<upper=to_int(min(y_obs))> DL;
}

// transformed data are values we can calculate directly from the inputted data.
// - N_cens is an integer equal to N_cens + N_obs.
transformed data {
	int<lower=0> N;
	N = N_cens + N_obs;
}

// The parameters accepted by the model. Our model
// accepts the real-valued parameters alpha, beta, (the regression coefs) and
// the positive real-valued parameter sigma (the variance of the outcome
// distribution).
// We also declare the censored values of y as parameters.
parameters {
	// Regression parameters
	real alpha;
	real beta;
	real<lower=0> sigma;
	
	// Censored y values
	array[N_cens] real<upper=DL> y_cens;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
	// Priors for parameters
	alpha ~ normal(0, 100);
	beta ~ normal(0, 100);
	sigma ~ exponential(0.01);
	
	// Calculate mu from the x's and parameter values
	array[N_obs] real mu_obs;
	for (i in 1:N_obs) {
		mu_obs[i] = alpha + beta * x_obs[i];
		y_obs[i] ~ normal(mu_obs[i], sigma);
	}
	
	array[N_cens] real mu_cens;
	for (i in 1:N_cens) {
		mu_cens[i] = alpha + beta * x_cens[i];
		y_cens[i] ~ normal(mu_cens[i], sigma);
	}
}

