//
// Dealing with a censored predictor in linear regression using the
// joint modeling integration approach
// author: Zane Billings
// started: 2024-05-18
//

// The input data consists of:
// - n (positive integer): the number of data records
// - p (positive integer): number of covariates to include.
// - y (vector of real numbers): the outcome, assumed to follow a gamma
//   distribution where the mean is based on a linear model.
// - w (vector of real numbers): the predictor, assumed to follow a normal
//   distribution which we need to estimate the parameters of.
// - c (array of integers that must be 0 or 1): should be 0 if the corresponding
//   observation in **X** is completely observed, or 1 if the observation is
//   censored (below the detection limit).
// - ulod (real scalar): the upper limit of detection for the observed values of
//   the censored predictor x.
data {
	int<lower=1> n;
	vector[n] y;
	vector[n] w;
	array[n] int<lower=0, upper=1> c;
	real ulod;
}

// The parameters accepted by the model.
// - alpha (real scalar): the intercept
// - beta (real vector of length P): vector of slope coefficients
// - k (positive real scalar): the shape parameter of the gamma distribution.
parameters {
	// Linear model parameters
	real alpha;
	real beta;
	real<lower=0> k;
	
	// w distribution parameters
	real mu_w;
	real<lower=0> sigma_w;
}

// The model to be estimated. This is the part where we put priors and
// likelihood calculations.
model {
	// Priors for parameters
	alpha ~ student_t(3, 0, 1);
	beta ~ student_t(3, 0, 1);
	k ~ student_t(3, 0, 3);
	mu_w ~ student_t(3, 0, 3);
	sigma_w ~ student_t(3, 0, 3);
	
	vector[n] mu_y;

	// Apply the likelihood of x to the overall joint likelihood.
	// We need to loop through each observation, and if observation [i] is not
	// censored, use the Gaussian likelihood. If the obs is censored, we need
	// to use the integration correction.
	for (i in 1:n) {
		if (c[i] == 0) {
			w[i] ~ normal(mu_w, sigma_w);
		} else if (c[i] == 1) {
			target += normal_lccdf(ulod | mu_w, sigma_w);
		}
		// Apply the likelihood of y to the overall joint likelihood.
		mu_y[i] = alpha + w[i] * beta;
		y[i] ~ gamma(k, k / mu_y[i]);
	}
}
