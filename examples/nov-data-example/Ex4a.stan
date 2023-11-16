//
// Example 4a: Logitic regression with censored predictor
// Zane
// 2023-10-24
// Similar to our norovirus project problems, this will implement a Bayesian
	// logistic regression model while enforcing a parametric model on the
	// predictor to account for censoring via joint modeling of the likelihood.
	// IMPORTANTLY this model does not allow the effects to vary by treatment
	// group, and thus only really works for an example with one group.
// See example 4b for the model that includes an effect of the treatment group.

// Data that must be passed in by the user
	// N:
		// a positive integer, the number of (X, y) observations.
	// y:
		// a 1D integer array of size [N], constrained to be 0 or 1. This is the
		// binary outcome variable.
	// x:
		// a 1D real array of size [N]. Contains the observed values of the
		// predictor variable.
	// x_l:
		// a 1D real array of size [N]. Contains the lower limit of detection for
		// the corresponding entry in x, therefore allowing the LoD to change across
		// different measurements.
data {
	int<lower=0> N;
	array[N] int<lower=0, upper=1> y;
	array[N] real x;
	array[N] real x_l;
}

// Model parameters
parameters {
	real alpha;
	real beta;
	real mu_x;
	real<lower=0> sigma_x;
}

// The model
model {
	// Declare a vector of p values
	vector[N] p;
	
	// Priors
	alpha ~ normal(0, 2);
	beta ~ normal(0, 2);
	mu_x ~ normal(0, 2);
	sigma_x ~ normal(0, 2);
	
	// Likelihood updating
	for (i in 1:N) {
		// Model x, accounting for censoring. Assuming a normal distribution (and
		// thus for our purposes, x is already log-transformed) with mean mu_x and
		// standard deviation sigma_x.
		if (x[i] <= x_l[i]) {
			target += normal_lcdf(x[i] | mu_x, sigma_x);
		} else {
			x[i] ~ normal(mu_x, sigma_x);
		}
		
		// Now calculate the linear model part -- we do this explicitly for
		// readability and direct correspondence to the statistical model.
		p[i] = alpha + beta * x[i];
	}
	
			// And finally update the model for y[i].
		y ~ bernoulli_logit(p);
}
