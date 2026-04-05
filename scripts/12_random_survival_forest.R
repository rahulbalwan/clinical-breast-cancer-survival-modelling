# 12_random_survival_forest.R
# This script will fit a random survival forest model to the cleaned data.
# Load necessary libraries
library(randomForestSRC)
library(readr)
library(dplyr)
library(survival)

# Load the cleaned OS data
os_data <- read_csv("clean/os_data.csv", show_col_types = FALSE)

# Prepare the data for random survival forest model
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

# Save exact dataset for reproducibility
write_csv(model_data, "clean/random_forest_model_data.csv")

# Fit random survival forest model
set.seed(123)
rsf_fit <- rfsrc(Surv(OS_MONTHS, OS_EVENT) ~ ., data = model_data, ntree = 500, importance = TRUE, na.action = "na.impute", seed = 123)

print(rsf_fit)

# Extract performance
rsf_cindex <- 1 - tail(rsf_fit$err.rate, 1)

performance_df <- data.frame(
    model = "Random Survival Forest",
    c_index = rsf_cindex,
    n = nrow(model_data)
)

# Variable importance
vimp_df <- data.frame(
    variable = names(rsf_fit$importance),
    importance = rsf_fit$importance
) %>%
    arrange(desc(importance))
print(vimp_df)

# Save results
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(performance_df, "results/tables/random_forest_performance.csv")
write_csv(vimp_df, "results/tables/random_forest_variable_importance.csv")
saveRDS(rsf_fit, "results/models/random_survival_forest_fit.rds")
cat("Random survival forest results saved in results/tables/ and results/models/\n") 

# Plot variable importance
png("results/figures/random_forest_variable_importance.png", width = 800, height = 600, res = 100)
par(mar = c(8,4, 2, 1))
barplot(height = vimp_df$importance, names.arg = vimp_df$variable, las = 2, main = "Variable Importance from Random Survival Forest", ylab = "Variable Importance")
dev.off()
