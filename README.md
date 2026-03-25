# Clinical Breast Cancer Survival Analysis

## Overview

This repository builds an end-to-end survival analysis pipeline using clinical breast cancer data. The project is being developed step-by-step from scratch to understand each stage of a survival analysis workflow in R, from raw data to advanced modeling and validation.

---

## Goal

To develop a deep understanding of survival analysis by rebuilding the pipeline incrementally, including:

- Data inspection and cleaning  
- Kaplan–Meier survival estimation  
- Cox proportional hazards modeling  
- Model diagnostics (proportional hazards testing)  
- Model validation and performance evaluation  
- Machine learning approaches (penalized Cox, random survival forest)  

---

## Dataset

The project uses clinical breast cancer patient-level data containing:

- Overall Survival (OS)
- Relapse-Free Survival (RFS)
- Treatment variables (chemotherapy, radiotherapy, hormone therapy)
- Prognostic markers (age, lymph nodes, NPI)
- Molecular and clinical subtypes

### Survival Endpoints

- **Overall Survival (OS)**
  - Time: `OS_MONTHS`
  - Event: `OS_EVENT` (1 = death, 0 = censored)

- **Relapse-Free Survival (RFS)**
  - Time: `RFS_MONTHS`
  - Event: `RFS_EVENT` (1 = relapse, 0 = censored)

---

## Current Progress

- Raw data loaded and inspected  
- Metadata removed and structure understood  
- Survival event variables created (`OS_EVENT`, `RFS_EVENT`)  
- Cleaned datasets created:
  - `clean/os_data.csv`
  - `clean/rfs_data.csv`  
- Generated survival curves for OS and RFS
- Observed:
  - Gradual decline in overall survival
  - Faster early decline in relapse-free survival
- Identified clinical insight:
  - Relapse occurs earlier than death

---

## Project Structure
- scripts/ - R scripts for each stage
- Raw/ - raw clinical dataset
- clean/ - cleaned survival analysis datasets
- results/ - outputs (figures, tables, models)
- notes/ - learning journal and notes

---



## Next Steps

- Log-rank tests for group comparisons  
- Cox proportional hazards modeling  
- Model diagnostics and validation 

---

## Learning Approach

This project is being developed incrementally over multiple days, with version control tracking each step. The focus is on understanding both the statistical concepts and their practical implementation in R. Each step is documented with:
- code implementation
- statistical reasoning
- clinical interpretation


---

## Author

Rahul
- MSc Medical Statistics and Health Data Science (University of Bristol, UK)
- MSc Statistics (Indian Institute of Technology Kanpur, India)