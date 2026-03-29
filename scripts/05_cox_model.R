# 05_cox_model.R
# This script will perform Cox proportional hazards regression analysis on the cleaned data.
# Load necessary libraries
library(survival)
library(readr)
library(dplyr)

# Load the cleaned OS data
os_data <- read_csv("clean/os_data.csv", show_col_types = FALSE)

# Convert categorical variables to factors
os_data <- os_data %>%
  mutate(ER_IHC = as.factor(ER_IHC),
         HORMONE_THERAPY = as.factor(HORMONE_THERAPY),
         CHEMOTHERAPY = as.factor(CHEMOTHERAPY),
         RADIO_THERAPY = as.factor(RADIO_THERAPY),
         CHEMOTHERAPY = as.factor(CHEMOTHERAPY),
         HER2_SNP6 = as.factor(HER2_SNP6),
         CELLULARITY = as.factor(CELLULARITY)
         )

# Select relevant variables for the Cox model
model_data <- os_data %>%
  select(OS_MONTHS, OS_EVENT,AGE_AT_DIAGNOSIS, LYMPH_NODES_EXAMINED_POSITIVE, NPI, ER_IHC, HORMONE_THERAPY, CHEMOTHERAPY, RADIO_THERAPY, HER2_SNP6, CELLULARITY) %>%
  na.omit()

# Fit Cox proportional hazards model
cox_fit <- coxph(Surv(OS_MONTHS, OS_EVENT) ~ AGE_AT_DIAGNOSIS + LYMPH_NODES_EXAMINED_POSITIVE + NPI + ER_IHC + HORMONE_THERAPY + CHEMOTHERAPY + RADIO_THERAPY + HER2_SNP6 + CELLULARITY, data = model_data, x = TRUE, y = TRUE, model = TRUE)

# View summary of the Cox model
summary_cox_fit <- summary(cox_fit)
print(summary_cox_fit)

# Create coefficients table
cox_coef_table <- data.frame(
  variable = rownames(summary_cox_fit$coefficients),
  coef = summary_cox_fit$coefficients[, "coef"],
  se_coef = summary_cox_fit$coefficients[, "se(coef)"],
  z = summary_cox_fit$coefficients[, "z"],
  p_value = summary_cox_fit$coefficients[, "Pr(>|z|)"]
)

# Create hazard ratios table
cox_hr_table <- data.frame(
  variable = rownames(summary_cox_fit$conf.int),
  hazard_ratio = summary_cox_fit$conf.int[, "exp(coef)"],
  lower_95_ci = summary_cox_fit$conf.int[, "lower .95"],
  upper_95_ci = summary_cox_fit$conf.int[, "upper .95"],
  p_value = summary_cox_fit$coefficients[, "Pr(>|z|)"]
)

# Save the output tables
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(cox_coef_table, "results/tables/cox_coefficients.csv")
write_csv(cox_hr_table, "results/tables/cox_hazard_ratios.csv")
saveRDS(cox_fit, "results/models/cox_model_fit.rds")

cat("Cox model results saved in results/tables/\n")
