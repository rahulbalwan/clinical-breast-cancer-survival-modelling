# 11_time_dependent_auc.R
# This script will calculate time-dependent AUC for the fitted Cox models.
# Load necessary libraries

library(survival)
library(survivalROC)
library(readr)
library(dplyr)


# Load cleaned OS data
os_data <- read_csv("clean/os_data.csv", col_types = cols())

# Prepare original patient-level data

model_data <- os_data %>%
 mutate( CHEMOTHERAPY = as.factor(CHEMOTHERAPY),
         RADIO_THERAPY = as.factor(RADIO_THERAPY),
         ER_IHC = as.factor(ER_IHC)) %>%
         select(OS_MONTHS, OS_EVENT, AGE_AT_DIAGNOSIS, CHEMOTHERAPY, RADIO_THERAPY, NPI, LYMPH_NODES_EXAMINED_POSITIVE, ER_IHC) %>%
         na.omit()



  

# Load data
time_varying_cox_model_fit <- readRDS("results/models/time_varying_cox_model_fit.rds")

# Align ER_IHC levels with training model
train_er_levels <- time_varying_cox_model_fit$xlevels$ER_IHC
model_data$ER_IHC <- factor(model_data$ER_IHC, levels = train_er_levels)

# Drop any rows with unseen ER_IHC levels
model_data <- model_data %>% filter(!is.na(ER_IHC))

cat("Rows used for AUC calculation:", nrow(model_data), "\n")
cat("ER_IHC levels in model data:", levels(model_data$ER_IHC), "\n")



# Predict risk scores (linear predictors) for the original patient-level data
risk_scores <- predict(time_varying_cox_model_fit, newdata = model_data, type = "lp")

cat("Length of risk scores:", length(risk_scores), "\n")

# Compute AUC at 60 Months
time_point <- 60
roc_obj <- survivalROC(Stime = model_data$OS_MONTHS, status = model_data$OS_EVENT, marker = risk_scores, predict.time = time_point, method = "NNE")

auc_value <- roc_obj$AUC
cat("Time-dependent AUC at", time_point, "months:", auc_value, "\n")

# Save results
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)

write_csv(data.frame(Time_months = time_point, AUC = auc_value), "results/tables/time_dependent_auc.csv", row.names = FALSE)

cat("Time-dependent AUC results saved to results/tables/time_dependent_auc.csv\n")

