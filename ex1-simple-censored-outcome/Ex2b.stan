//
// Ex2a: One censored predictor using the imputation method
// has one lower limit of detection only
// See: https://mc-stan.org/docs/stan-users-guide/censored-data.html
// Zane Billings
// 2023-10-17
//

// The input data consists of:
// - N: 
// - N_cens: an integer, the number of data points where the outcome was below
//   the DL and thus censored.
// - y: real array of observed outcome variable
// - cens: int array; indicator which is 1 if the corresponding measurement of
//   y is censored and 0 otherwise.
// - x: real array of observed predictor variable
// - DL: int, the detection limit of the assay (right now it has to be
//   identical for all observations but we want to change that in future)
data {
	int<lower=0> N;
	int<lower=0, upper=N> N_cens;
	array[N] real y;
	array[N] int cens;
	array[N] real x;
	int<upper=to_int(min(y))> DL;
}

// transformed data are values we can calculate directly from the inputted data.
// - N_cens is an integer equal to N_cens + N_obs.
// transformed data {
// 	int<lower=0 upper=N> N_obs;
// 	N_obs = N_cens - N;
// }

// The parameters accepted by the model. Our model
// accepts the real-valued parameters alpha, beta, (the regression coefs) and
// the positive real-valued parameter sigma (the variance of the outcome
// distribution).
parameters {
	// Regression parameters
	real alpha;
	real beta;
	real<lower=0> sigma;
}

// The model to be estimated.
model {
	// Priors for parameters
	alpha ~ normal(0, 100);
	beta ~ normal(0, 100);
	sigma ~ exponential(0.01);
	
	// Loop through each observation and calculate the mean. If the current
	// y value is observed, treat it like normal. If it is censored, we need to
	// update the likelihood by integrating out the value.
	array[N] real mu;
	for (i in 1:N) {
		mu[i] = alpha + beta * x[i];
		if (cens[i] == 0) {
			y[i] ~ normal(mu[i], sigma);
		} else if (cens[i] == 1) {
			target += normal_lcdf(DL | mu[i], sigma);
		}
	}
}

