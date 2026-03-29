# 08_ph_stratified.R
# This script will check the proportional hazards assumption for the stratified Cox model.
# Load necessary libraries
library(survival)
library(readr)
library(dplyr)

# Load the stratified Cox model fit
stratified_cox_fit <- readRDS("results/models/stratified_cox_model_fit.rds")

# PH test for the stratified Cox model
ph_test_strat <- cox.zph(stratified_cox_fit)
print(ph_test_strat)

# Save the PH test results
ph_table <- data.frame(
  variable = rownames(ph_test_strat$table),
  chisq = ph_test_strat$table[, "chisq"],
  df = ph_test_strat$table[, "df"],
  p_value = ph_test_strat$table[, "p"]
)

dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(ph_table, "results/tables/stratified_cox_ph_test.csv")

cat("Proportional hazards test results saved in results/tables/stratified_cox_ph_test.csv\n")

# Plot Diagnostics
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
png("results/figures/stratified_cox_ph_diagnostics.png", width = 1400, height = 1200, res = 150)

par(mfrow = c(3,2), mar = c(4, 4, 2, 1))
plot(ph_test_strat)

dev.off()
cat("Proportional hazards diagnostic plots saved in results/figures/stratified_cox_ph_diagnostics.png\n")
