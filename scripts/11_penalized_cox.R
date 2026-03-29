# 11_penalized_cox.R
# This script will fit a penalized Cox proportional hazards model to the cleaned data.
# Load necessary libraries
library(survival)
library(glmnet)
library(readr)
library(dplyr)
# Load the cleaned OS data
os_data <- read_csv("clean/os_data.csv", show_col_types = FALSE)

# Prepare the data for penalized Cox model
model_data <- os_data %>%
 mutate(ER_IHC = as.factor(ER_IHC),
        CHEMOTHERAPY = as.factor(CHEMOTHERAPY),
        RADIO_THERAPY = as.factor(RADIO_THERAPY),
        HORMONE_THERAPY = as.factor(HORMONE_THERAPY),
        HER2_SNP6 = as.factor(HER2_SNP6),
        CELLULARITY = as.factor(CELLULARITY)
 ) %>%
    select(OS_MONTHS, OS_EVENT, AGE_AT_DIAGNOSIS, LYMPH_NODES_EXAMINED_POSITIVE, NPI, RADIO_THERAPY, CHEMOTHERAPY, HORMONE_THERAPY, HER2_SNP6, CELLULARITY, ER_IHC) %>%
    na.omit()

# Create model matrix for penalized Cox model
x <- model.matrix( ~ AGE_AT_DIAGNOSIS + LYMPH_NODES_EXAMINED_POSITIVE + NPI + RADIO_THERAPY + CHEMOTHERAPY + HORMONE_THERAPY + HER2_SNP6 + CELLULARITY + ER_IHC, data = model_data)[, -1]
y <- Surv(model_data$OS_MONTHS, model_data$OS_EVENT)

# Cross-validation LASSO Cox model
set.seed(123)
cv_fit <- cv.glmnet(x, y, alpha = 1, family = "cox", nfolds = 10)

# Fit final LASSO Cox model with optimal lambda
lasso_cox_fit <- glmnet(x, y, alpha = 1, family = "cox", lambda = cv_fit$lambda.min)

# Extract coefficients of the final model
coef_vec <- as.matrix(coef(lasso_cox_fit))
coef_df <- data.frame(
    variable = rownames(coef_vec),
    coefficient = coef_vec[, 1]
) %>%
    filter(coefficient != 0) %>%
    arrange(desc(abs(coefficient)))

print(coef_df)

# Save coefficients of the penalized Cox model
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(coef_df, "results/tables/penalized_cox_coefficients.csv")
saveRDS(lasso_cox_fit, "results/models/penalized_cox_model_fit.rds")
saveRDS(cv_fit, "results/models/penalized_cox_cv_fit.rds")
png("results/figures/penalized_cox_coefficients.png", width = 800, height = 600)
plot(cv_fit)
dev.off()
cat("Penalized Cox model results saved in results/figures/, results/tables/ and results/models/\n")
