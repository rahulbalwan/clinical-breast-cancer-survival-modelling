## 01_inspect_data.R
# This script is for inspecting the data and understanding its structure.

# Load necessary libraries
library(readr)
library(dplyr)
library(stringr)

# Load the data

file_path <- "raw/data_clinical_patient.txt"
raw_lines <- readLines(file_path)

# Remove metadata lines (those starting with '#')
data_lines <- raw_lines[!grepl("^#", raw_lines)]

# Split the data into a data frame
data <- read.delim(text = paste(data_lines, collapse = "\n"), sep = "\t",
    stringsAsFactors = FALSE )

# Inspect the structure of the data
cat("Dimensions of the data: ", dim(data), "\n")
cat("Column names: ", colnames(data), "\n")
cat("Structure of the data: ", str(data), "\n")
cat("Summary of the data: ", summary(data), "\n")

# Check survival variables
cat("Unique values in 'OS_STATUS' (Overall Survival): ", unique(data$OS_STATUS), "\n")
cat("Unique values in 'RFS_STATUS' (Relapse-Free Survival): ", unique(data$RFS_STATUS), "\n")


# Check for missing values
missing_values <- sapply(data, function(x) sum(is.na(x)))
missing_values <- sort(missing_values, decreasing = TRUE)
cat("Missing values in each column:\n")
print(missing_values)


# Inspect key clinical variables
cat("\nAge distribution:\n")
summary(as.numeric(data$AGE_AT_DIAGNOSIS))
cat("\nNPI distribution:\n")
summary(as.numeric(data$NPI))
cat("\nLymph node status distribution:\n")
summary(as.numeric(data$LYMPH_NODES_EXAMINED_POSITIVE))

# Save the inspected data for further analysis
dir.create("clean", showWarnings = FALSE)
write.csv(head(data,100), "clean/inspected_data_sample.csv", row.names = FALSE)
cat("Sample of the inspected data has been saved to 'clean/inspected_data_sample.csv'\n")

