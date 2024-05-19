//
// Dealing with a censored outcome in linear regression using the
// integration approach
// author: Zane Billings
// started: 2024-05-18
//

// The input data consists of:
// - n (positive integer): the number of data records
// - p (positive integer): number of covariates to include.
// - y (vector of real numbers): the outcome, assumed to follow a normal
//   distribution where the mean is based on a linear model.
// - c (array of integers that must be 0 or 1): should be 0 if the corresponding
//   observation in y is completely observed, or 1 if the observation is
//   censored (below the detection limit).
// - X (n x p matrix where p is the number of predictors): the matrix of
//   covariates to use in the linear model.
// - DL (real scalar): the lower limit of detection for the observed values of
//   the outcome variable, y. This must be less than or equal to the smallest
//   observed value of the outcome.
data {
	int<lower=1> n;
	int<lower=1> p;
	vector[n] y;
	array[n] int<lower=0, upper=1> c;
	matrix[n, p] X;
	real<upper=min(y)> DL;
}

// The parameters accepted by the model.
// - alpha (real scalar): the intercept
// - beta (real vector of length P): vector of slope coefficients
// - sigma (positive real scalar): the residual variance.
parameters {
	real alpha;
	vector[p] beta;
	real<lower=0> sigma;
}

// The model to be estimated. This is the part where we put priors and
// likelihood calculations.
model {
	// Priors for parameters -- note that by specifying priors for beta (a vector)
	// like this, we implicitly assume all beta[j] have independent priors of the
	// same form.
	alpha ~ student_t(3, 0, 3);
	beta ~ student_t(3, 0, 3);
	sigma ~ student_t(3, 0, 3);
	
	// Calculate the mean from the linear model. We can do this in a vectorized
	// way to improve efficeincy.
	vector[n] mu = X * beta + alpha;
	
	// Loop through each observation and update the likelihood as neceeded. If
	// c[i] = 0, update using the typical Normal likelihood function. If c[i] = 1,
	// we need to do the integration thing.
	// For this simple case where all the detection limits are the same, we could
	// vectorize this. But this is easier to read.
	for (i in 1:n) {
		if (c[i] == 0) {
			y[i] ~ normal(mu[i], sigma);
		} else if (c[i] == 1) {
			target += normal_lcdf(DL | mu[i], sigma);
		}
	}
}
