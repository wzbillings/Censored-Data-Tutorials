###
# Common setup operations and shared functions for the code in this section
# Zane Billings
# 2024-03-06
###

# ---- Package Loading ----
# ggplot2 theme setup
library(ggplot2)
ggplot2::theme_set(hgp::theme_ms())

# Necessary to fully attach these packages for them to work right
library(patchwork)
library(cmdstanr)

# Variable for random seed#
S <- 54351231
