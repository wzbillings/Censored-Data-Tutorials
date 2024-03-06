###
# Common setup operations and shared functions for the code in this section
# Zane Billings
# 2024-03-06
###

# ---- Package Loading ----
library(cmdstanr)
# ggplot2 theme setup
library(ggplot2)
ggplot2::theme_set(hgp::theme_ms())
pth_base <- here::here("examples", "nov-data-example")
library(patchwork)

S <- 370
