//
// Dealing with a censored predictor in linear regression using the
// joint modeling integration approach
// author: Zane Billings
// started: 2024-05-18
//

// Function for integration over the censored predictor
functions {
	real censored_x(real x, real xc, array[] real theta, array[] real x_r,
	                array[] int x_i) {
		real k = theta[1];
		real mu = theta[2];
		real y theta[3];
		real mu_x = theta[4];
		real sigma_x = theta[5];
		
		return exp(gamma_lpdf(y | k, k / mu) + normal_lpdf(x | mu_x, sigma_a))
	}
}

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

// Variables that we don't need that have to be passed to the integrator
transformed data {
  array[0] real x_r;
  array[0] int x_i;
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
			mu_y[i] = alpha + w[i] * beta;
			y[i] ~ gamma(k, k / mu_y[i]);
		} else if (c[i] == 1) {
			mu_y[i] = alpha + w[i] * beta;
			target += (log(1) - normal_lcdf(ulod)) + log(
				integrate_1d(
					censored_x, 0, ulod, {k, mu_y[i], y[i], mu_w, sigma_w}, x_r, x_i
				)
			);
		}
		

	}
}
