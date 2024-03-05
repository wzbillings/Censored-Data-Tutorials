###
# Simple Censored Predictor example code
# Zane Billings
# 2024-03-04
# Code for the Quarto file for this case study
###

# Setup ####

# Need to load all of cmdstanr or some things act weird
library(cmdstanr)

# ggplot2 theme setup
library(ggplot2)
ggplot2::theme_set(hgp::theme_ms())

# Set up a variable with the base path for this document
pth_base <- here::here("examples", "simple-censored-predictor")

# Set a constant value for pRNG seed
S <- 370

# Cat weight simulation ####
# Set up the simulation parameters so we can easily display them later
data_gen_parms <- list(
	# Number of observations to generate
	n = 154,
	# Set a static constant value for the lower limit of detection (LoD)
	ulod = 12,
	# Linear model intercept
	beta0 = 0.5,
	# Linear model slope
	beta1 = 0.8,
	# Linear model residual variance
	sigma = 1.05,
	# Mean of normally distributed x values
	x_mu = 13,
	# SD of normally distributed x values
	x_sd = 2
)

# Export the simulation parameters for displaying
cat_weight_parms <-
	data_gen_parms |>
	# Convert list to DF with two columns and flatten
	tibble::enframe(
		name = "Parameter",
		value = "Value"
	) |>
	tidyr::unnest(Value) |>
	# Clean up the parameter names
	dplyr::mutate(
		Parameter = dplyr::case_match(
			Parameter,
			"n" ~ "$n$",
			"ulod" ~ "$w_{\\max}$",
			"beta0" ~ "$\\beta_0$",
			"beta1" ~ "$\\beta_1$",
			"sigma" ~ "$\\sigma$",
			"x_mu" ~ "$\\lambda$",
			"x_sd" ~ "$\\tau$"
		)
	)

# This function generates data from a simple linear model that assumes the
# x values follow a Normal distribution. See the quarto doc for more information
# on the data generating process.
generate_cat_weight_data <- function(
		n = 1000, ulod = 2, beta0 = 1, beta1 = 2, sigma = 5, x_mu = 5, x_sd = 3,
		seed = S
) {
	set.seed(S)
	
	l <- tibble::tibble(
		x_star = rnorm(n, x_mu, x_sd),
		x = ifelse(x_star >= ulod, ulod, x_star),
		mu = beta0 + beta1 * x_star,
		y = rnorm(n, mu, sigma)
	)
	
	o <- dplyr::select(l, x, y)
	
	out <- list("latent" = l, "observed" = o)
}

dat <- do.call(generate_cat_weight_data, data_gen_parms)

dat_l <- dat$latent
dat_o <- dat$observed

simple_model <- lm(y ~ x, data = dat_o)
summary(simple_model)

latent_model <- lm(y ~ x_star, data = dat_l)
summary(latent_model)
