# 00_setup.R
# Project setup script: initializes environment, folders, and packages

cat("Setting up Survival Analysis Project\n")
# Clear workspace
rm(list = ls())

# Set working directory (optional — uncomment and edit if needed)
# setwd("path/to/your/project")

# Create required directories
dir.create("raw", showWarnings = FALSE)
dir.create("clean", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("results/models", recursive = TRUE, showWarnings = FALSE)

cat("Project directories checked/created.\n")

# Required packages
required_packages <- c(
  "readr",
  "dplyr",
  "tidyr",
  "stringr",
  "survival",
  "survminer",
  "glmnet",
  "randomForestSRC",
  "rms",
  "ggplot2"
)

# Install missing packages
installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    cat("Installing package:", pkg, "\n")
    install.packages(pkg)
  }
}

# Load all packages
lapply(required_packages, library, character.only = TRUE)

cat("\nAll required packages are installed and loaded.\n")

# Set global options
options(stringsAsFactors = FALSE)

cat("\nSetup complete. You can now run the pipeline.\n")
