//
	// Complete Pooling Model where season is ignored
// Zane
// 2022-02-18
//

	// Input data for the model
// Input data is of length N.
// There are two variables that we will use: y and x.
data {
	int<lower=0> N;
	int<lower=0> N_obs;
	int<lower=0> N_cens;
	array[N] int<lower=0> id;
	vector[N] y;
	vector[N_obs] x_obs;
}

// The parameters accepted by the model.
// Our model has a variance parameter, s, and two linear model parameters.
// A slope a, and an intercept b.
parameters {
	array[N_cens] real<upper=DL> x_cens;
	array real x[N];
	real a;
	real b;
	real<lower=0> s;
}

// The model to be estimated.
// The outcome, y, is normally distributed, where the conditional mean
// on x is fitted to a linear model.
model {
	// Censored predictor
	x_obs ~ normal(mu, sigma);
	x_cens ~ normal(mu, sigma);
	x = append_array(x_obs, x_cens);

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

// End of program
