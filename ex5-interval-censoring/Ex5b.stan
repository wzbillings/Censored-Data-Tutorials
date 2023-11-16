//
	// Example 5: Weibull regression and interval censoring
	// Zane
	// 2023-10-25
	// Fits a Weibull regression model where the outcome is interval censored
	// and the expected failure time at time zero, lambda_i, is modeled as a
	// linear function of some covariate. The second parameter k is estimated
	// from data but assumed to be constant.
//

// Need a function for weibull cdf to work right
// https://discourse.mc-stan.org/t/interval-censored-data-fails-with-weibull-but-not-gamma/28780
functions {
  real my_weibull_lcdf(real y, real alpha, real sigma) {
    return log1m_exp(-pow(y / sigma, alpha));
  }
}

data {
	int<lower=0> N;
	array[N] real x;
	array[N] real y1;
	array[N] real y2;
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
	alpha ~ normal(0, 2);
	beta ~ normal(0, 2);
	k ~ normal(0, 2);
	
	// Model
	for (i in 1:N) {
		lambda[i] = exp(alpha + beta * x[i]);
		
		u_cdf[i] = my_weibull_lcdf(y2[i] | k, lambda[i]);
		l_cdf[i] = my_weibull_lcdf(y1[i] | k, lambda[i]);
		target += log_diff_exp(u_cdf[i], l_cdf[i]);
	//	y2 ~ weibull(lambda[i], k);
	}
}
