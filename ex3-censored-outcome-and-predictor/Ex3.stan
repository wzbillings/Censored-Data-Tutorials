//
	// Example 3 Stan Code: censored outcome and censored predictor
	// where both the outcome and predictor have lower and upper limits of
	// detection (that are known and constant).
	// Zane 2023-10-18
//

// Input data for the model
data {
	int<lower=0> N;
	array[N] real y;
	array[N] real y_l;
	array[N] real y_u;
	array[N] real x;
	array[N] real x_l;
	array[N] real x_u;
}

// The parameters accepted by the model.
parameters {
	real alpha;
	real beta;
	real<lower=0> sigma;
}

// The model to be estimated.
model {
	// Define mu vector
	vector[N] mu;
	
	// Priors go here
	sigma ~ exponential(1);
	beta ~ normal(0, 2);
	alpha ~ normal(0, 2);
	
	for (i in 1:N) {
		// Cases for dealing with censored predictor x based on how it is censored
		if (x[i] <= x_l[i]) {
			// If x is left-censored, use the CDF and add contribution to target
			target += normal_lcdf(x_l[i] | 0, 1);
		} else if (x[i] > x_u[i]) {
			// If x is right-censored, use the complimentary CDF to add to target
			target += normal_lccdf(x_u[i] | 0, 1);
		} else {
			// If x is observed, update evrything like normal
			x[i] ~ normal(0, 1);
		}
		
		// Calculate mu now that x is dealt with
		mu[i] = alpha + beta * x[i];
		
		// Dealing with the outcome likelihood
		// if Y is below the lower bound, integrate with lcdf
		if (y[i] <= y_l[i]) {
			target += normal_lcdf(y_l[i] | mu[i], sigma);
			// If Y is above the upper bound, integrate with lccdf
		} else if (y[i] > y_u[i]) {
			target += normal_lccdf(y_u[i] | mu[i], sigma);
			// If Y is in the middle of the censoring bounds, update the likelihood
			// like normal.
		} else {
			y[i] ~ normal(mu[i], sigma);
		}
	}
}

// End of program
