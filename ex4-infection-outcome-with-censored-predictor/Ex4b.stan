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
	// k:
		// a positive integer, the number of treatment groups.
	// t:
		// a 1D integer array of size [N], contained to be in 1, 2, ..., k.
		// t[i] is the treatment group of the i-th individual.
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
	int<lower=1> k;
	array[N] int<lower=0, upper=k> t;
	array[N] int<lower=0, upper=1> y;
	array[N] real x;
	array[N] real x_l;
}

// Model parameters
parameters {
	// Parameters in model for x
	//real alpha_0;
	array[k] real alpha_1;
	real<lower=0> sigma_x;
	
	// Parameters in model for y
	//real beta_0;
	array[k] real beta_1;
	array[k] real beta_2;
}

// The model
model {
	// Declare vectors of p and mu values
	vector[N] p;
	vector[N] mu;
	
	// Priors
	//alpha_0 ~ normal(0, 2);
	alpha_1 ~ normal(0, 2); //Nb we could use MVN dist here if desired
	sigma_x ~ normal(0, 2);
	//beta_0 ~ normal(0, 2);
	beta_1 ~ normal(0, 2);
	beta_2 ~ normal(0, 2);
	
	// Likelihood updating
	for (i in 1:N) {
		// Calculate the mean of x[i] based on alpha distributions
		mu[i] = alpha_1[t[i]];
		
		// Model x, accounting for censoring. Assuming a normal distribution (and
		// thus for our purposes, x is already log-transformed) with mean mu_x and
		// standard deviation sigma_x.
		if (x[i] <= x_l[i]) {
			target += normal_lcdf(x_l[i] | mu[i], sigma_x);
		} else {
			x[i] ~ normal(mu[i], sigma_x);
		}
		
		// Now calculate the linear model part -- we do this explicitly for
		// readability and direct correspondence to the statistical model.
		p[i] = beta_1[t[i]] + beta_2[t[i]] * x[i];
		
		// And finally update the model for y[i].
		y[i] ~ bernoulli_logit(p[i]);
	}
}
