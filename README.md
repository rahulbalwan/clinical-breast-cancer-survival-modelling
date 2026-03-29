# Clinical Breast Cancer Survival Analysis

## Overview

This repository builds an end-to-end survival analysis pipeline using clinical breast cancer data. The project is being developed incrementally from scratch to understand each stage of a survival analysis workflow in R, from raw data to advanced modeling, diagnostics, and validation.

The analysis focuses on time-to-event outcomes including overall survival and relapse-free survival, integrating statistical rigor with clinical interpretation.

---

## Goal

To develop a deep understanding of survival analysis by rebuilding the pipeline step-by-step, including:

* Data inspection and cleaning
* Kaplan–Meier survival estimation
* Log-rank hypothesis testing
* Cox proportional hazards modeling
* Proportional hazards diagnostics
* Model validation and performance evaluation
* Advanced modeling extensions

---

## Dataset

The project uses clinical breast cancer patient-level data containing:

* Overall Survival (OS)
* Relapse-Free Survival (RFS)
* Treatment variables (chemotherapy, radiotherapy, hormone therapy)
* Prognostic markers (age, lymph nodes, Nottingham Prognostic Index)
* Molecular and clinical subtypes

### Survival Endpoints

* **Overall Survival (OS)**

  * Time: `OS_MONTHS`
  * Event: `OS_EVENT` (1 = death, 0 = censored)

* **Relapse-Free Survival (RFS)**

  * Time: `RFS_MONTHS`
  * Event: `RFS_EVENT` (1 = relapse, 0 = censored)

---

## Current Progress

### Task 1–2: Data Inspection & Cleaning

* Loaded raw clinical dataset
* Removed metadata and structured data
* Identified missing values and variable types
* Created survival-ready datasets:

  * `clean/os_data.csv`
  * `clean/rfs_data.csv`

---

### Task 3: Kaplan–Meier Analysis

* Estimated survival curves for:

  * Overall Survival (OS)
  * Relapse-Free Survival (RFS)

**Key Observations:**

* OS declines gradually over time
* RFS declines faster in early follow-up
* Relapse tends to occur earlier than death

---

### Task 4: Log-Rank Testing

* Compared survival across groups

**Results:**

* ER status: not statistically significant
* Hormone therapy: significant survival difference

**Insight:**

* Treatment effects may be more influential than receptor status alone

---

### Task 5–6: Cox Proportional Hazards Model

Fitted a multivariable Cox model including clinical and treatment variables.

**Significant predictors:**

* Age at diagnosis
* Lymph node involvement
* Nottingham Prognostic Index (NPI)
* Chemotherapy
* Radiotherapy (protective effect)
* HER2 subtype (neutral category protective)

**Model performance:**

* Concordance index ≈ 0.665
* Strong overall model significance

**Clinical insights:**

* Disease severity (NPI, lymph nodes) strongly influences survival
* Chemotherapy associated with higher hazard (likely confounding by indication)
* Radiotherapy shows protective effect

---

### Task 7: Proportional Hazards Diagnostics

* Tested PH assumption using Schoenfeld residuals (`cox.zph`)
* Generated diagnostic plots and statistical tests

**Results:**

* Significant PH violations detected for:

  * Age at diagnosis
  * Lymph nodes
  * NPI
  * ER status
  * Hormone therapy
  * Chemotherapy
  * HER2 subtype

* No strong violation for:

  * Radiotherapy
  * Cellularity

* Global test highly significant → model assumption violated

---

## Key Insights

* The Cox model is statistically strong but **assumptions are violated**
* Several predictors have **time-varying effects**
* Clinical risk is **dynamic, not constant over time**
* Real-world survival data rarely satisfy all model assumptions

---

## Important Finding

> The baseline Cox proportional hazards model is not fully valid as a final model due to violation of the proportional hazards assumption.

### Task 8: Stratified Cox Model
- Addressed PH violations using stratification
- Stratified by:
  - ER status
  - Chemotherapy

### ** Results **
- Improved model performance (C-index ≈ 0.672)
- Stable effects for:
  - Age
  - Lymph nodes
  - NPI
  - Radiotherapy

### Key Insight
- Stratification improved model validity by allowing different baseline hazards
- Some variables are better modeled as strata rather than fixed effects

---

### Task 9: PH Diagnostics After Stratified Cox
- Re-tested proportional hazards assumption after stratification
- Generated Schoenfeld residual plots and statistical tests

### **Results**
- Reduced PH violations compared to baseline Cox model
- Remaining violations:
  - Age at diagnosis
  - Nottingham Prognostic Index (NPI)
- No strong violation observed for:
  - Lymph nodes
  - Radiotherapy
- Global test still significant → PH assumption not fully satisfied

### Key Insight
- Stratification successfully handled categorical variables
- Continuous predictors still exhibit time-varying effects
- A more flexible modeling approach is required

---

## Current Understanding

The modeling pipeline now demonstrates:

- Baseline Cox model → violated PH assumption  
- Stratified Cox model → partially improved validity  
- Remaining issue → time-dependent effects in continuous variables  

 - This reflects a realistic clinical scenario where risk factors evolve over time.

---

### Task 10: Time-Varying Cox Model
- Addressed remaining PH violations using time-dependent covariates
- Modeled dynamic effects for:
  - Age at diagnosis
  - Nottingham Prognostic Index (NPI)
- Implemented using `tt()` with log(time + 1) interaction

### **Results**
- Significant time-varying effects observed for:
  - AGE_AT_DIAGNOSIS
  - NPI
- Stable predictors:
  - Lymph node involvement
  - Radiotherapy
- Chemotherapy associated with increased hazard (likely confounding by indication)
- Improved model performance:
  - C-index ≈ **0.677** (best so far)

### Key Insight
- Continuous predictors do not have constant effects over time
- Time-varying Cox model provides a more realistic representation of survival dynamics
- Hazard ratios in clinical data are often **time-dependent, not fixed**

---

## Updated Understanding

The modeling pipeline now demonstrates:

- Baseline Cox model → violated PH assumption  
- Stratified Cox model → partially improved validity  
- Time-varying Cox model → most appropriate and realistic model  

This reflects a real-world clinical scenario where:
- Risk factors evolve over time  
- Disease progression and treatment effects are dynamic  
- Static models may oversimplify survival behavior  

---

## Next Steps

- Model comparison (Baseline vs Stratified vs Time-Varying)  
- Time-dependent ROC and AUC  
- Calibration analysis  
- Penalized Cox regression (feature selection)  
- Random Survival Forest (machine learning approach)  

### Task 11: Model Comparison
- Compared performance of:
  - Baseline Cox model  
  - Stratified Cox model  
  - Time-varying Cox model  
- Evaluated using:
  - Concordance index (C-index)
  - Model validity (PH assumption diagnostics)

### **Results**
- Baseline Cox Model → C-index ≈ 0.665  
- Stratified Cox Model → C-index ≈ 0.672  
- Time-Varying Cox Model → C-index ≈ 0.677  

### Key Insight
- Addressing PH violations improves both:
  - model validity  
  - predictive performance  
- Time-varying Cox model provides the most realistic representation of survival dynamics

---

## Updated Understanding

The modeling pipeline now demonstrates:

- Baseline Cox model →  violated PH assumption  
- Stratified Cox model →  partially improved validity  
- Time-varying Cox model →  most appropriate and realistic model  

This reflects a real-world clinical scenario where:
- Risk factors evolve over time  
- Disease progression is dynamic  
- Constant hazard ratios are often unrealistic  

---

## Note on Time-dependent AUC

Time-dependent AUC was not included in this workflow because:
- The preferred final model (time-varying Cox) uses time-dependent covariates (`tt()`)
- Standard fixed-time AUC methods are not directly compatible with this model structure

Model comparison was therefore based primarily on:
- Concordance (C-index)
- Assumption validity

---

## Next Steps

- Penalized Cox regression (feature selection and stability)
- Random Survival Forest (machine learning approach)
- Calibration analysis (prediction accuracy)
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

This project is built incrementally with version control, focusing on:

* statistical understanding
* reproducible code
* clinical interpretation

Each stage is documented with:

* code implementation
* statistical reasoning
* clinical insights

---

## Author

Rahul

* MSc Medical Statistics & Health Data Science (University of Bristol, UK – Sept 2026)
* MSc Statistics (Indian Institute of Technology Kanpur, India)

---

##  Project Vision

This project aims to go beyond textbook survival analysis by:

* integrating diagnostics and validation
* addressing real-world model violations
* combining statistical and machine learning approaches
* building an interpretable and reproducible pipeline

---
