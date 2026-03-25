# 02_clean_data.R
# This script will clean the data and prepare it for analysis.
# Load necessary libraries
library(dplyr)
library(tidyr)
library(stringr)

# Load the raw data
file_path <- "raw/data_clinical_patient.txt"
raw_lines <- readLines(file_path)

data_lines <- raw_lines[!grepl("^#", raw_lines)]

data <- read.delim(text = paste(data_lines, collapse = "\n"), sep = "\t", stringsAsFactors = FALSE)

# Create OS_EVENT
data$OS_EVENT <- ifelse(grepl("^1", data$OS_STATUS), 1, 0)
# Create RFS_EVENT
data$RFS_EVENT <- ifelse(grepl("^1", data$RFS_STATUS), 1, 0)

# Convert numeric variables

data <- data%>% 
 mutate(
    AGE_AT_DIAGNOSIS = as.numeric(AGE_AT_DIAGNOSIS),
    NPI = as.numeric(NPI),
    LYMPH_NODES_EXAMINED_POSITIVE = as.numeric(LYMPH_NODES_EXAMINED_POSITIVE),
    OS_MONTHS = as.numeric(OS_MONTHS),
    RFS_MONTHS = as.numeric(RFS_MONTHS)
  )
# Select relevant columns
selected_data <- data %>%
  select(
    AGE_AT_DIAGNOSIS,
    LYMPH_NODES_EXAMINED_POSITIVE,
    NPI,
    CHEMOTHERAPY,
    HORMONE_THERAPY,
    ER_IHC,
    HER2_SNP6,
    RADIO_THERAPY,
    CELLULARITY,
    OS_MONTHS,
    OS_EVENT,
    RFS_MONTHS,
    RFS_EVENT
  )

  # Create OS dataset
os_data <- selected_data %>%
 filter(!is.na(OS_MONTHS) & !is.na(OS_EVENT))

# Create RFS dataset
rfs_data <- selected_data %>%
    filter(!is.na(RFS_MONTHS) & !is.na(RFS_EVENT))  

# Save the cleaned datasets
dir.create("clean", showWarnings = FALSE)

write.csv(os_data, "clean/os_data.csv", row.names = FALSE)
write.csv(rfs_data, "clean/rfs_data.csv", row.names = FALSE)

cat("Clean datasets saved:\n")
cat(" - clean/os_data.csv\n")
cat(" - clean/rfs_data.csv\n")

# Check output
cat("\nOS dataset size:\n")
print(dim(os_data))

cat("\nRFS dataset size:\n")
print(dim(rfs_data))


