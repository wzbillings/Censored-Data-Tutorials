//
	// Example 5a: Weibull regression
	// Zane
	// 2023-10-25
	// Fits a Weibull regression model where the outcome is NOT censored
	// and the expected failure time at time zero, lambda_i, is modeled as a
	// linear function of some covariate. The second parameter k is estimated
	// from data but assumed to be constant.
//

// Need a function for weibull cdf to work right
// https://discourse.mc-stan.org/t/interval-censored-data-fails-with-weibull-but-not-gamma/28780
data {
	int<lower=0> N;
	array[N] real x;
	array[N] real y;
}

parameters {
	real alpha;
	real beta;
	real<lower=0> k;
}

model {
	array[N] real lambda;
	vector[N] u_cdf;
	vector[N] l_cdf;
	
	// Priors
	alpha ~ normal(0, 10);
	beta ~ normal(0, 10);
	k ~ normal(0, 10);
	
	// Model
	for (i in 1:N) {
		lambda[i] = exp(alpha + beta * x[i]);
		y[i] ~ weibull(k, lambda[i]);
	}
}
