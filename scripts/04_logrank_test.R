# 04_logrank_test.R
# This script will perform log-rank tests to compare survival curves between different groups.
# Load necessary libraries
library(survival)
library(readr)
library(dplyr)

# Load the cleaned OS data
os_data <- read_csv("clean/os_data.csv", show_col_types = FALSE)

# Convert grouping variable
os_data <- os_data %>%
  mutate(ER_IHC = as.factor(ER_IHC),
   HORMONE_THERAPY = as.factor(HORMONE_THERAPY))

# Create survival object
surv_object <- Surv(time = os_data$OS_MONTHS, event = os_data$OS_EVENT)

# Perform log-rank test for ER status
logrank_er <- survdiff(surv_object ~ ER_IHC, data = os_data)
p_er <- 1 - pchisq(logrank_er$chisq, df = length(logrank_er$n) - 1)

logrank_er_df <- data.frame(variable = "ER_IHC", p_value = p_er, chisq = logrank_er$chisq, df = length(logrank_er$n) - 1)

write_csv(logrank_er_df, "results/tables/logrank_os_by_er.csv")
cat("Log-rank test for ER status:\n")
print(logrank_er)
cat("p-value for ER status: ", p_er, "\n\n")

# Perform log-rank test for hormone therapy
logrank_ht <- survdiff(surv_object ~ HORMONE_THERAPY, data = os_data)
p_ht <- 1 - pchisq(logrank_ht$chisq, df = length(logrank_ht$n) - 1)
logrank_ht_df <- data.frame(variable = "HORMONE_THERAPY", p_value = p_ht, chisq = logrank_ht$chisq, df = length(logrank_ht$n) - 1)

write_csv(logrank_ht_df, "results/tables/logrank_os_by_hormone.csv")
cat("Log-rank test for hormone therapy:\n")
print(logrank_ht)
cat("p-value for hormone therapy: ", p_ht, "\n\n")

cat("Log-rank test results saved in results/tables/\n")
