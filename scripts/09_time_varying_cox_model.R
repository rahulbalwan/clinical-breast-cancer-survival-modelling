# 09_time_varying_cox_model.R
# This script will fit a time-varying Cox proportional hazards model to the cleaned data.
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

# Select relevant variables for the time-varying Cox model
model_data <- os_data %>%
    select(OS_MONTHS, OS_EVENT, AGE_AT_DIAGNOSIS, LYMPH_NODES_EXAMINED_POSITIVE, NPI, RADIO_THERAPY, CHEMOTHERAPY, ER_IHC) %>%
    na.omit()

# Fit time-varying Cox proportional hazards model
time_varying_cox_fit <- coxph(Surv(OS_MONTHS, OS_EVENT) ~ LYMPH_NODES_EXAMINED_POSITIVE + tt(NPI) + RADIO_THERAPY + CHEMOTHERAPY + strata(ER_IHC) + tt(AGE_AT_DIAGNOSIS), data = model_data, tt = function(x, t, ...) x * log(t + 1), x = TRUE, y = TRUE)

summary_fit <- summary(time_varying_cox_fit)
print(summary_fit)

# Save summary of the time-varying Cox model
coef_table <- data.frame(
    variable = rownames(summary_fit$coefficients),
    coef = summary_fit$coefficients[, "coef"],
    se_coef = summary_fit$coefficients[, "se(coef)"],
    z = summary_fit$coefficients[, "z"],
    p_value = summary_fit$coefficients[, "Pr(>|z|)"]
)

# Save hazard ratio table
hr_table <- data.frame(
    variable = rownames(summary_fit$conf.int),
    hazard_ratio = summary_fit$conf.int[, "exp(coef)"],
    lower_95_ci = summary_fit$conf.int[, "lower .95"],
    upper_95_ci = summary_fit$conf.int[, "upper .95"],
    p_value = summary_fit$coefficients[, "Pr(>|z|)"]
)

dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
write_csv(coef_table, "results/tables/time_varying_cox_coefficients.csv")
write_csv(hr_table, "results/tables/time_varying_cox_hazard_ratios.csv")
saveRDS(time_varying_cox_fit, "results/models/time_varying_cox_model_fit.rds")
cat("Time-varying Cox model results saved in results/tables/ and results/models/\n")
