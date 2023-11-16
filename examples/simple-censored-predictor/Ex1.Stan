//
	// Complete Pooling Model where season is ignored
	// Zane
	// 2022-02-18
//

// Input data for the model
	// Input data is of length N.
	// There are two variables that we will use: y and x.
	// Here x_obs is the vector of actual observed x values. For this method
	// we do not need to include an indicator for missing data, but we have to
	// instead make sure the data are sorted in the correct order.
//
data {
	int<lower=0> N;
	int<lower=0, upper=N> N_obs;
	int<lower=0, upper=N> N_cens;
	vector[N] y;
	vector[N_obs] x_obs;
	real DL;
}

// The parameters accepted by the model.
	// Our model has a variance parameter, s, and two linear model parameters:
	// the intercept a, and the slope b.
	// The array x_cens will be filled with values drawn from a constrained
	// normal distribution.
	// the array x is a dummy variable that will be created by appending the
	// sampled x_cens values to the end of the observed x_obs data vector.
//
parameters {
	array[N_cens] real<upper=DL> x_cens;
	real a;
	real b;
	real<lower=0> s;
	real mu_x;
	real<lower=0> sigma_x;
}

// The model to be estimated.
	// The outcome, y, is normally distributed, where the mean, conditional
	// on x, is fitted to a linear model.
	// First we use the observed x values to update the conditional likelihood
	// based on their priors. (MAKE THIS EXPLANATION BETTER)
	// Then we draw the censored x values from the prior. It does not matter
	// what order we do these two steps because the x_cens values are drawn from
	// the posterior of the previous iteration.
	// Then we append those together into a single x vector, and fit the linear
	// model in the usual way.
//
model {
	// Censored predictor
	array[N] real x;
	x_obs ~ normal(mu_x, sigma_x);
	x_cens ~ normal(mu_x, sigma_x);
	x = append_array(to_array_1d(x_obs), x_cens);

	// Mu calculation and priors
	vector[N] mu;
	s ~ exponential(1);
	b ~ normal(0, 2);
	a ~ normal(0, 2);
	for (i in 1:N) {
		mu[i] = a + b * x[i];
	}

	// Outcome likelihood
	y ~ normal(mu, s);
}

// Consider adding gq block to calculate posterior log likelihood

// End of program
