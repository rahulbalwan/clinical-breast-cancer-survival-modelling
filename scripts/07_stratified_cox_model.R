# 07_stratified_cox_model.R
# This script will perform stratified Cox proportional hazards regression analysis on the cleaned data.
# Load necessary libraries
library(survival)
library(readr)
library(dplyr)

# Load the cleaned OS data
os_data <- read_csv("clean/os_data.csv", show_col_types = FALSE)

# Convert categorical variables to factors
os_data <- os_data %>%
  mutate(ER_IHC = as.factor(ER_IHC),
         CHEMOTHERAPY = as.factor(CHEMOTHERAPY),
         RADIO_THERAPY = as.factor(RADIO_THERAPY)
  )

# Select relevant variables for the stratified Cox model
model_data <- os_data %>%
  select(OS_MONTHS, OS_EVENT, AGE_AT_DIAGNOSIS, LYMPH_NODES_EXAMINED_POSITIVE, NPI, RADIO_THERAPY, CHEMOTHERAPY, ER_IHC) %>%
    na.omit()

# Fit stratified Cox proportional hazards model
stratified_cox_fit <- coxph(Surv(OS_MONTHS, OS_EVENT) ~ AGE_AT_DIAGNOSIS + LYMPH_NODES_EXAMINED_POSITIVE + NPI + RADIO_THERAPY + strata(CHEMOTHERAPY) + strata(ER_IHC), data = model_data, x = TRUE, y = TRUE, model = TRUE)

# View summary of the stratified Cox model
summary_stratified_cox_fit <- summary(stratified_cox_fit)
print(summary_stratified_cox_fit)   

# Save summary of the stratified Cox model

coef_table <- data.frame(
  variable = rownames(summary_stratified_cox_fit$coefficients),
  coef = summary_stratified_cox_fit$coefficients[, "coef"],
  se_coef = summary_stratified_cox_fit$coefficients[, "se(coef)"],
  z = summary_stratified_cox_fit$coefficients[, "z"],
  p_value = summary_stratified_cox_fit$coefficients[, "Pr(>|z|)"]
)

hr_table <- data.frame(
  variable = rownames(summary_stratified_cox_fit$conf.int),
  hazard_ratio = summary_stratified_cox_fit$conf.int[, "exp(coef)"],
  lower_95_ci = summary_stratified_cox_fit$conf.int[, "lower .95"],
  upper_95_ci = summary_stratified_cox_fit$conf.int[, "upper .95"],
  p_value = summary_stratified_cox_fit$coefficients[, "Pr(>|z|)"]
)

dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
write_csv(coef_table, "results/tables/stratified_cox_coefficients.csv")
write_csv(hr_table, "results/tables/stratified_cox_hazard_ratios.csv")
saveRDS(stratified_cox_fit, "results/models/stratified_cox_model_fit.rds")
cat("Stratified Cox model results saved in results/tables/ and results/models/\n")
