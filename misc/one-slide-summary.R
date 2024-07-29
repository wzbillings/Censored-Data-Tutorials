###
# Graphical abstract / one-slide-summary
# Zane
# 2024-07-29
# Show the difference in corrected and uncorrected models in one slide.
###

# Setup code ####
library(cmdstanr)
library(brms)
# ggplot2 theme setup
library(ggplot2)
ggplot2::theme_set(hgp::theme_ms())

# Data simulation ####
# First simulate data -- using the glyphosate level example, simplified.
{
	set.seed(370)
	N <- 448
	res_sd <- 1.5
	LoD <- 0
	L <- LoD
	alpha <- 1
	beta <- -4
	gly_data <-
		tibble::tibble(
			house_x_coord = runif(N, 0, 1),
			house_y_coord = runif(N, 0, 1),
			dist_from_farm = sqrt((house_x_coord - 0.5)^2 + (house_y_coord - 0.5)^2),
			mu = alpha + beta * dist_from_farm,
			y_star = rnorm(N, mu, res_sd),
			censoring_status = ifelse(y_star <= LoD, 1, 0),
			# Create the censored outcome
			glyphosate_reading = ifelse(censoring_status == 1, L, y_star)
		)
}

# Dataset including ONLY the observed variables
gly_data_obs <-
	gly_data |>
	dplyr::select(dist_from_farm, censoring_status, glyphosate_reading)

ggplot(gly_data_obs) +
	aes(x = dist_from_farm, y = (glyphosate_reading)) +
	geom_point()

# model_naive <-
# 	lm(log(glyphosate_reading) ~ dist_from_farm, data = gly_data)
# 
# model_cens <-
# 	survival::survreg(
# 		survival::Surv(
# 			log(pmax(glyphosate_reading, LoD)),
# 			censoring_status == 0,
# 			type = 'left'
# 		) ~ dist_from_farm,
# 		data = gly_data_obs,
# 		dist = "gaussian"
# 	)

my_priors <- c(
	prior(normal(0, 3), class = "b"),
	prior(normal(0, 3), class = "Intercept"),
	prior(student_t(3, 0, 3), class = "sigma", lb = 0)
)

fit_nb <- brms::brm(
	formula = (glyphosate_reading) ~ dist_from_farm,
	data = gly_data_obs,
	family = gaussian(),
	prior = my_priors,
	warmup = 1000,
	iter = 2000,
	chains = 4,
	cores = 4,
	seed = 32134,
	backend = "cmdstanr",
	silent = 2
)

fit_cc <- brms::brm(
	formula = (glyphosate_reading) ~ dist_from_farm,
	data = dplyr::filter(gly_data_obs, censoring_status == 0),
	family = gaussian(),
	prior = my_priors,
	warmup = 1000,
	iter = 2000,
	chains = 4,
	cores = 4,
	seed = 32134,
	backend = "cmdstanr",
	silent = 2
)

brms_data <-
	gly_data_obs |>
	dplyr::mutate(
		# Transform censoring indicator
		censored = ifelse(censoring_status == 1, -1, 0),
		# Transform the outcome
		outcome = pmax((glyphosate_reading), (LoD)),
		# Only keep the variables we plan to give to brms
		.keep = "unused"
	)

fit_cb <- brms::brm(
	formula = outcome | cens(censored) ~ dist_from_farm,
	data = brms_data,
	family = gaussian(),
	prior = my_priors,
	warmup = 1000,
	iter = 2000,
	chains = 4,
	cores = 4,
	seed = 32134,
	backend = "cmdstanr",
	silent = 2
)

gly_data_plot <-
	tidyr::expand_grid(
		dist_from_farm = seq(0, 0.7, 0.005)
	)

epreds_naive <-
	gly_data_plot |>
	tidybayes::add_epred_draws(fit_nb) |>
	tidybayes::mode_hdci(.width = c(0.5, 0.8, 0.95))

epreds_cens <-
	gly_data_plot |>
	tidybayes::add_epred_draws(fit_cb) |>
	tidybayes::mode_hdci(.width = c(0.5, 0.8, 0.95))

epreds_cc <-
	gly_data_plot |>
	tidybayes::add_epred_draws(fit_cc) |>
	tidybayes::mode_hdci(.width = c(0.5, 0.8, 0.95))

epreds_data <-
	dplyr::bind_rows(
		"2. Without censoring correction" = epreds_naive,
		"4. With censoring correction" = epreds_cens,
		"3. Complete case analysis" = epreds_cc,
		.id = "model"
	) |>
	dplyr::mutate(
		dplyr::across(c(.epred, .lower, .upper), identity),
		.width = forcats::fct_rev(ordered(.width))
	)

ggplot(epreds_data) +
	aes(x = dist_from_farm, y = .epred, ymin = .lower, ymax = .upper,
			color = model, fill = after_scale(color),
			group = .width) +
	geom_point(
		data = gly_data,
		aes(x = dist_from_farm, y = y_star),
		color = "lightgray",
		inherit.aes = FALSE
	) +
	geom_point(
		data = gly_data_obs,
		aes(x = dist_from_farm, y = glyphosate_reading),
		inherit.aes = FALSE
	) +
	ggdist::geom_lineribbon(alpha = 0.3) +
	geom_line(
		data = tibble::tibble(
			dist_from_farm = gly_data_plot$dist_from_farm,
			y = alpha + beta * dist_from_farm
		),
		aes(color = "1. Latent model", x = dist_from_farm, y = y),
		inherit.aes = FALSE,
		lwd = 1.5, lty = 2
	) +
	scale_color_manual(values = c("dodgerblue2", "sienna1", "springgreen3", "palevioletred3"), name = NULL) +
	#facet_wrap(~model) +
	labs(
		x = "Predictor", y = "Outcome"
	)

