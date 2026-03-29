# 10_model_comparison.R
# This script will compare survival models
# Load necessary libraries
library(survival)
library(readr)
library(dplyr)

# Load the model fits
cox_fit <- readRDS("results/models/cox_model_fit.rds")
stratified_cox_fit <- readRDS("results/models/stratified_cox_model_fit.rds")
time_varying_cox_fit <- readRDS("results/models/time_varying_cox_model_fit.rds")

# Extract C-index for each model
get_cindex <- function(model) { summary(model)$concordance[1] }

model_comparison <- data.frame(
  model = c("Baseline Cox Model", "Stratified Cox Model", "Time-Varying Cox Model"),
  c_index = c(get_cindex(cox_fit), get_cindex(stratified_cox_fit), get_cindex(time_varying_cox_fit))
)

# Save the results
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(model_comparison, "results/tables/model_comparison.csv")
cat("Model comparison results saved in results/tables/model_comparison.csv\n")

