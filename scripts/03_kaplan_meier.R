# 03_kaplan_meier.R
# This script will perform Kaplan-Meier survival analysis on the cleaned data.
# Load necessary libraries
library(survival)
library(survminer)
library(readr)

# Load the cleaned data
os_data <- read_csv("clean/os_data.csv")
rfs_data <- read_csv("clean/rfs_data.csv")

# Create survival objects
os_surv <- Surv(time = os_data$OS_MONTHS, event = os_data$OS_EVENT)
rfs_surv <- Surv(time = rfs_data$RFS_MONTHS, event = rfs_data$RFS_EVENT)

# Fit Kaplan-Meier models
km_os <- survfit(os_surv ~ 1)
km_rfs <- survfit(rfs_surv ~ 1)

# Plot Kaplan-Meier curves
os_plot <- ggsurvplot(km_os, data = os_data, risk.table = TRUE, pval = TRUE, conf.int = TRUE, title = "Kaplan-Meier Curve for Overall Survival", xlab = "Time (months)", ylab = "Survival Probability")
rfs_plot <- ggsurvplot(km_rfs, data = rfs_data, risk.table = TRUE, pval = TRUE, conf.int = TRUE, title = "Kaplan-Meier Curve for Recurrence-Free Survival", xlab = "Time (months)", ylab = "Survival Probability")

# Save the plots
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
ggsave("results/figures/km_overall_survival.png", os_plot$plot, width = 8, height = 6)
ggsave("results/figures/km_relapse_free_survival.png", rfs_plot$plot, width = 8, height = 6)

cat("Kaplan-Meier plots saved in results/figures/\n")