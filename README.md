# Clinical Breast Cancer Survival Analysis

![R](https://img.shields.io/badge/R-Statistical%20Computing-276DC3?logo=r&logoColor=white)
![Survival Analysis](https://img.shields.io/badge/Analysis-Survival-blueviolet)
![Machine Learning](https://img.shields.io/badge/Modeling-Machine%20Learning-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

## Overview

This repository presents an end-to-end survival analysis pipeline using clinical breast cancer data. The project is developed incrementally from scratch to understand each stage of a survival analysis workflow in R — from raw data preprocessing to advanced modeling, diagnostics, and validation.

The analysis focuses on time-to-event outcomes, integrating statistical rigor with clinically meaningful interpretation.

---

## Representative Result

![Overall Survival Kaplan–Meier Curve](results/figures/km_overall_survival.png)

*Kaplan–Meier estimate of overall survival in the breast cancer cohort.*

---

## Goal

To build a deep, practical understanding of survival analysis by systematically implementing:

- Data inspection and cleaning  
- Kaplan–Meier survival estimation  
- Log-rank hypothesis testing  
- Cox proportional hazards modeling  
- Proportional hazards diagnostics  
- Model comparison and validation  
- Advanced modeling (time-varying effects, penalization, machine learning)

---

## Dataset

Clinical breast cancer patient-level dataset containing:

- Overall Survival (OS)  
- Relapse-Free Survival (RFS)  
- Treatment variables (chemotherapy, radiotherapy, hormone therapy)  
- Prognostic markers (age, lymph nodes, Nottingham Prognostic Index)  
- Molecular and clinical subtypes  

### Survival Endpoints

**Overall Survival (OS)**  
- Time: `OS_MONTHS`  
- Event: `OS_EVENT` (1 = death, 0 = censored)

**Relapse-Free Survival (RFS)**  
- Time: `RFS_MONTHS`  
- Event: `RFS_EVENT` (1 = relapse, 0 = censored)

---

## Analysis Pipeline

### Task 1–2: Data Inspection & Cleaning
- Loaded and structured raw clinical dataset  
- Handled missing values and variable types  
- Created survival-ready datasets:
  - `clean/os_data.csv`
  - `clean/rfs_data.csv`

---

### Task 3: Kaplan–Meier Analysis
- Estimated survival curves for OS and RFS  

**Key Observations:**
- Overall survival declines gradually  
- Relapse occurs earlier than death  
- Early-phase differences are clinically meaningful  

---

### Task 4: Log-Rank Testing
- Compared survival across groups  

**Results:**
- ER status: not statistically significant  
- Hormone therapy: significant  

**Insight:**
- Treatment effects may be more influential than receptor status alone  

---

### Task 5–6: Cox Proportional Hazards Model
- Fitted multivariable Cox model  

**Significant predictors:**
- Age at diagnosis  
- Lymph node involvement  
- Nottingham Prognostic Index (NPI)  
- Chemotherapy  
- Radiotherapy (protective)  
- HER2 subtype  

**Performance:**
- C-index ≈ 0.665  

**Clinical insight:**
- Disease severity dominates survival outcomes  
- Treatment effects are confounded by indication  

---

### Task 7: Proportional Hazards Diagnostics
- Tested PH assumption using Schoenfeld residuals  

**Results:**
- Significant violations for multiple predictors  
- Global test highly significant  

**Conclusion:**
> Baseline Cox model is not fully valid due to PH violations  

---

### Task 8: Stratified Cox Model
- Stratified by ER status and chemotherapy  

**Results:**
- Improved model performance (C-index ≈ 0.672)  
- Better handling of categorical violations  

---

### Task 9: PH Diagnostics After Stratification
- Re-tested PH assumption  

**Findings:**
- Reduced violations  
- Remaining issues in continuous variables (age, NPI)  

---

### Task 10: Time-Varying Cox Model
- Modeled time-dependent effects using `tt()`  

**Results:**
- Significant time-varying effects for:
  - Age  
  - NPI  
- Improved performance:
  - C-index ≈ **0.677** (best model)  

**Key Insight:**
> Hazard ratios are not constant — risk evolves over time  

---

### Task 11: Model Comparison

| Model | C-index |
|------|--------|
| Baseline Cox | ~0.665 |
| Stratified Cox | ~0.672 |
| Time-varying Cox | ~0.677 |

**Insight:**
- Addressing assumptions improves both validity and performance  
- Time-varying Cox provides the most realistic representation  

---

### Task 12: Penalized Cox Regression
- Applied LASSO for feature selection  

**Results:**
- Stable predictors:
  - Age, lymph nodes, NPI  
  - Treatment variables  
  - HER2 subtypes  

**Insight:**
> Core predictors remain stable under regularization  

---

### Task 13: Random Survival Forest
- Applied machine learning survival model  

**Results:**
- Top predictors:
  - Age  
  - Lymph nodes  
  - NPI  
- Performance:
  - C-index ≈ 0.667  

**Insight:**
- ML confirms predictor importance  
- Does not outperform well-specified Cox models  

---

### Task 14: Calibration Analysis
- Evaluated predicted vs observed survival  

**Results:**
- Model overestimates survival probability  
- Calibration curve below ideal line  

**Insight:**
> Good discrimination ≠ good calibration  

---

## Key Takeaways

- Survival data often violate modeling assumptions  
- Risk is dynamic, not constant over time  
- Model validation is as important as model fitting  
- Core predictors are robust across:
  - Cox models  
  - Penalized models  
  - Machine learning models  
- Increased complexity does not guarantee better performance  

---

## Project Structure

```
breast-cancer-survival-analysis/
│
├── scripts/        # R scripts for each step
├── raw/            # raw dataset
├── clean/          # cleaned datasets
├── results/        # outputs (figures, tables, models)
├── notes/          # learning journal + interpretations
├── README.md
```

---


## Learning Approach

This project is built incrementally with a focus on:

- Statistical understanding  
- Reproducible workflows  
- Clinical interpretation  

Each step is documented with:
- Code  
- Reasoning  
- Insights  

---

## Author

**Rahul**

- MSc Medical Statistics & Health Data Science  
  *(University of Bristol, UK – Sept 2026)*  
- MSc Statistics  
  *(Indian Institute of Technology Kanpur, India)*  

---

## Project Vision

This project aims to go beyond textbook survival analysis by:

- Addressing real-world modeling challenges  
- Integrating diagnostics and validation  
- Combining statistical and machine learning approaches  
- Building an interpretable and reproducible pipeline  

---