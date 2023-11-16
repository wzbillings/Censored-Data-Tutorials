//
	// the b is for Bjorn
	// Implement the "joint modeling" method for dealing with censoring of
	// the x-variable in a regression model
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
	array[N] real y;
	array[N] real x;
	// Indicator variable which is 1 if x is left censored, 0 not censored, 2 RC
	array[N] int x_cens;
	// Variable for the detection limit
	real<lower=min(x)> DL;
}

// The parameters accepted by the model.
//
parameters {
//	array[N_cens] real<upper=DL> x_cens;
	real a;
	real b;
	real<lower=0> s;
	real mu_x;
	real<lower=0> sigma_x;
	array[N] real x_random;
}

transformed parameters {
	array[N] real x_imputed;
	for (r in 1:N) {
		x_imputed[r] = mu_x + x_random[r] * sigma_x;
	}
}

// The model to be estimated.
// ADD EXPLANTION HERE?
//
model {
	// Define mu vector of y's
	vector[N] mu;
	
	// Sampling x random effect
	x_random ~ normal(0, 1);
	
	// Priors go here
	s ~ exponential(1);
	b ~ normal(0, 2);
	a ~ normal(0, 2);
	mu_x ~ normal(0, 10);
	sigma_x ~ exponential(2);
	
	for (r in 1:N) {
		// Cases for dealing with censored predictor x based on how it is censored
		if (x_cens[r] == 1) {
			// If x is left-censored, use the CDF and add contribution to target
			target += normal_lcdf(x_imputed[r] | mu_x, sigma_x);
		} else if (x_cens[r] == 2) {
			// If x is right-censored, use the complimentary CDF to add to target
			target += normal_lccdf(x_imputed[r] | mu_x, sigma_x);
		} else {
			// If x is observed, update evrything like normal
			x[r] ~ normal(x_imputed[r], sigma_x);
		}
		
		// Calculate mu now that x is dealt with
		mu[r] = a + b * x[r];
	}
	
	// Outcome likelihood
	y ~ normal(mu, s);
}

// Consider adding gq block to calculate posterior log likelihood

// End of program
