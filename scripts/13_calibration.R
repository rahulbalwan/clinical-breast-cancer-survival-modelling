# 13_calibration.R
# This script will evaluate the calibration of the random survival forest model using calibration plots.
# Load necessary libraries
library(survival)
library(readr)
library(dplyr)
library(ggplot2)
library(rms)

# Load the cleaned OS data
os_data <- read_csv("clean/os_data.csv", show_col_types = FALSE)
# Prepare the data for calibration plot
model_data <- os_data %>%
    mutate(ER_IHC = as.factor(ER_IHC),
              CHEMOTHERAPY = as.factor(CHEMOTHERAPY),
              RADIO_THERAPY = as.factor(RADIO_THERAPY)
     ) %>%
     select(OS_MONTHS, OS_EVENT, AGE_AT_DIAGNOSIS, LYMPH_NODES_EXAMINED_POSITIVE, NPI, RADIO_THERAPY, CHEMOTHERAPY, ER_IHC) %>%
        na.omit()

# Setup rms environment
dd <- datadist(model_data)
options(datadist = "dd")

# Fit Cox model for calibration plot (Stratified)
cox_model <- cph(Surv(OS_MONTHS, OS_EVENT) ~ LYMPH_NODES_EXAMINED_POSITIVE + NPI + RADIO_THERAPY + CHEMOTHERAPY + ER_IHC + AGE_AT_DIAGNOSIS, data = model_data, x = TRUE, y = TRUE, surv = TRUE)

# Calibration plot at 5 years (60 months)
time_point <- 60
cal <- calibrate(cox_model, method = "boot", u = time_point, m = 100, B = 200)
# Plot calibration curve
png("results/figures/calibration_plot.png", width = 800, height = 600)
plot(cal, xlim = c(0, 1), ylim = c(0, 1), xlab = "Predicted Probability of Survival at 5 Years", ylab = "Observed Probability of Survival at 5 Years", main = "Calibration Plot for Cox Model at 5 Years")
abline(0, 1, col = "red", lty = 2)
dev.off()
cat("Calibration plot saved in results/figures/calibration_plot.png\n")
