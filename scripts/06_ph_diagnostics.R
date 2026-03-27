# 06_ph_diagnostics.R
# This script will perform diagnostics for the Cox proportional hazards model.
# Load necessary libraries
library(survival)
library(survminer)
library(readr)

# Load the Cox model fit
cox_model <- readRDS("results/tables/cox_model_fit.rds")

# PH test using Schoenfeld residuals
ph_test <- cox.zph(cox_model)
print(ph_test)

# Convert to table
ph_table <- data.frame(
  variable = rownames(ph_test$table),
  chisq = ph_test$table[, "chisq"],
  df = ph_test$table[, "df"],
  p_value = ph_test$table[, "p"]
)
# Save the PH test results
write_csv(ph_table, "results/tables/cox_ph_assumption.csv")

# Plot Schoenfeld residuals
png("results/figures/cox_ph_diagnostics.png", width = 1600, height = 1400, res = 150)
par(mfrow = c(4,4), mar = c(4, 4, 2, 1))
plot(ph_test)
dev.off()

cat("Proportional hazards diagnostics saved in results/tables/cox_ph_assumption.csv and results/figures/cox_ph_diagnostics.png\n") 
