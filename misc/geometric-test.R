

N_days <- 100
N_inds <- 10
# Need to make the p into a regression with hierarchical parameters
mean_p <- 0.2
var_p <- 0.02
alpha <- (((1 - mean_p) / var_p) - (1 / mean_p)) * (mean_p ^ 2)
beta <- alpha * (1 / mean_p - 1)
mean_c <- 10

if (N_inds == 1) {
	p_vec <- mean_p
	c_vec <- mean_c
} else {
	p_vec <- rbeta(N_inds, alpha, beta)
	c_vec <- rpois(N_inds, mean_c)
}

sim_dat <-
	sapply(1:N_inds, \(x) rgeom(N_days, p_vec[x])) |>
	`colnames<-`(1:N_inds) |>
	tibble::as_tibble() |>
	tibble::rownames_to_column(var = "day") |>
	tidyr::pivot_longer(
		cols = -day,
		names_to = "id",
		values_to = "y",
		names_transform = list(id = as.integer)
	) |>
	dplyr::mutate(
		p = p_vec[id],
		U = c_vec[id],
		c = pmin(y, U),
		# Way to make some things missing
		miss = runif(dplyr::n()) <= 0.15,
		c = ifelse(miss, NA, c)
	)

library(ggplot2)
ggplot2::theme_set(zlib::theme_ms())

sim_dat |>
	dplyr::group_by(id, p, U) |>
	dplyr::count(c) |>
	dplyr::ungroup() |>
	ggplot() +
	aes(x = c, y = n) +
	geom_col(color = "black", fill = "gray") +
	geom_label(
		data = dplyr::distinct(sim_dat, id, p, U),
		aes(label = paste0("p: ", round(p, 2), "\nU: ", U), y = 50, x = 2)
	) +
	scale_x_continuous(breaks = scales::breaks_pretty()) +
	facet_wrap(~id)
