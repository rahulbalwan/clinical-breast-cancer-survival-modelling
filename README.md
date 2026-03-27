# Clinical Breast Cancer Survival Analysis

## Overview

This repository builds an end-to-end survival analysis pipeline using clinical breast cancer data. The project is developed step-by-step from scratch to understand each stage of a survival analysis workflow in R, from raw data to statistical modeling and clinical interpretation.

---

## Goal

To develop a deep understanding of survival analysis by rebuilding the pipeline incrementally, including:

- Data inspection and cleaning  
- Kaplan–Meier survival estimation  
- Log-rank hypothesis testing  
- Cox proportional hazards modeling  
- Model diagnostics (proportional hazards testing)  
- Model validation and performance evaluation  
- Machine learning extensions (planned)  

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

### Data Preparation
- Raw data loaded and inspected  
- Metadata removed  
- Variable structure and missingness analyzed  
- Survival event variables created:
  - `OS_EVENT`
  - `RFS_EVENT`  
- Cleaned datasets created:
  - `clean/os_data.csv`
  - `clean/rfs_data.csv`

---

### Kaplan–Meier Survival Analysis
- Estimated survival curves for OS and RFS  
- Key observations:
  - Gradual decline in overall survival  
  - Faster early decline in relapse-free survival  
- Clinical insight:
  - Relapse occurs earlier than death  

---

### Log-rank Tests
- Compared survival across groups:
  - ER status → not statistically significant (p ≈ 0.11)  
  - Hormone therapy → significant (p < 0.001)  

### Insight:
- Log-rank tests are unadjusted  
- Observed differences may be confounded  

---

### Cox Proportional Hazards Model

A multivariable Cox model was fitted to estimate **independent effects** of clinical and treatment variables.

#### Model Performance
- Concordance index (C-index): **0.665**  
  → moderate predictive ability  
- Global model tests: **p < 0.001**

---

### Key Findings

#### Strong Prognostic Factors
- **Age at diagnosis**
  - HR ≈ 1.04 → increasing age increases risk  
- **Lymph node involvement**
  - HR ≈ 1.05 → higher tumor burden increases risk  
- **Nottingham Prognostic Index (NPI)**
  - HR ≈ 1.20 → strongest predictor  

---

#### Treatment Effects
- **Chemotherapy**
  - HR ≈ 1.54 (higher hazard)  
  - likely reflects *confounding by indication*  

- **Radiotherapy**
  - HR ≈ 0.74 (protective effect)  

---

#### Non-significant Variables (after adjustment)
- ER status  
- Hormone therapy  
- Cellularity  

---

###  Key Insight

There is a clear difference between:

- **Log-rank test (unadjusted)**  
- **Cox model (adjusted)**  

 Example:
- Hormone therapy appeared significant in log-rank  
- Not significant after adjustment in Cox model  

This demonstrates:
> the importance of controlling for confounding in observational clinical data

---
## Project Structure
- scripts/ - R scripts for each stage
- Raw/ - raw clinical dataset
- clean/ - cleaned survival analysis datasets
- results/ - outputs (figures, tables, models)
- notes/ - learning journal and notes

---



---

## Outputs

- Kaplan–Meier survival plots  
- Log-rank test result tables  
- Cox model:
  - coefficient table  
  - hazard ratio table  
  - saved model object  

---

## Next Steps

- Proportional hazards diagnostics (Schoenfeld residuals)  
- Stratified Cox models  
- Time-varying Cox models  
- Model validation (train/test split, C-index)  
- Machine learning models (LASSO, Random Survival Forest)  

---

## Learning Approach

This project is developed incrementally with version control tracking each step.

Each stage includes:
- code implementation  
- statistical reasoning  
- clinical interpretation  

---

##  Author

Rahul  
- MSc Medical Statistics & Health Data Science (University of Bristol, UK)  
- MSc Statistics (IIT Kanpur, India)  