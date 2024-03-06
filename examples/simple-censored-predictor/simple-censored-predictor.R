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
	ulod = 15,
	# Linear model intercept
	beta0 = 0.5,
	# Linear model slope
	beta1 = 0.2,
	# Linear model residual variance
	sigma = 0.5,
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

# Plot the censored cat data ####
dat_l |>
	ggplot() +
	geom_vline(
		xintercept = data_gen_parms$ulod,
		linetype = "dashed",
		color = "gray"
	) +
	geom_line(
		aes(
			x = x_star,
			y = data_gen_parms$beta0 + data_gen_parms$beta1 * x_star
		), color = "red", linetype = "dashed",
		linewidth = 1
	) +
	geom_segment(
		aes(
			x = x_star, xend = x,
			y = y, yend = y
		),
		color = "gray"
	) +
	geom_point(aes(x = x_star, y = y), color = "gray", size = 2) +
	geom_point(aes(x = x, y = y), color = "black", size = 2) +
	labs(x = "Weight", y = "Cholesterol")
