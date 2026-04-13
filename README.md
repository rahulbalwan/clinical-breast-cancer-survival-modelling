# Breast Cancer Survival Analysis

![R](https://img.shields.io/badge/R-Statistical%20Computing-276DC3?logo=r&logoColor=white)
![Survival Analysis](https://img.shields.io/badge/Analysis-Survival-blueviolet)
![Machine Learning](https://img.shields.io/badge/Modeling-Machine%20Learning-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

## Overview

This repository presents an end-to-end survival analysis pipeline using clinical breast cancer data. The project was developed incrementally from scratch to build a practical understanding of each stage of a survival analysis workflow in R — from raw data preprocessing to advanced modeling, diagnostics, validation, and interactive visualization.

The analysis focuses on time-to-event outcomes and combines statistical rigor with clinically meaningful interpretation.

---

## Live Dashboard

Interactive Shiny dashboard:  
**[Breast Cancer Survival Dashboard](https://rrahul.shinyapps.io/breast-cancer-survival-dashboard/)**

The dashboard allows interactive exploration of:
- Overall Survival (OS) and Relapse-Free Survival (RFS)
- Kaplan–Meier curves and log-rank tests
- Adjusted Cox proportional hazards models
- Proportional hazards diagnostics
- Model comparison and validation
- Penalized Cox regression
- Random Survival Forest results
- Calibration analysis
- Filtered cohort-level data summaries

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
- Interactive communication through a Shiny dashboard  

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
- Loaded and structured the raw clinical dataset  
- Handled missing values and variable types  
- Created survival-ready datasets:
  - `clean/os_data.csv`
  - `clean/rfs_data.csv`

---
### Task 3: Kaplan–Meier Analysis
- Estimated survival curves for OS and RFS  

**Key Observations:**
- Overall survival (OS) declines faster than relapse-free survival (RFS)
- This reflects differences in endpoint definitions:
  - OS includes all-cause mortality
  - RFS includes recurrence and disease-specific death, but excludes non-cancer deaths
- As a result, non-cancer deaths contribute to earlier events in OS but not in RFS
- This highlights the presence of competing risks, where patients may die from other causes before experiencing relapse
- Early-phase differences between curves may still be clinically meaningful

---

### Task 4: Log-Rank Testing
- Compared survival across groups  

**Results:**
- ER status: not statistically significant  
- Hormone therapy: statistically significant  

**Insight:**
- In unadjusted analysis, hormone therapy groups showed differences in survival, whereas ER status did not  
- However, these results should be interpreted cautiously, as log-rank tests do not account for confounding  
- In particular, treatment effects in observational data are susceptible to confounding by indication, where patients receiving therapy may differ systematically in baseline risk  
- This highlights the need for multivariable modelling to obtain adjusted estimates of association  
---

### Task 5–6: Cox Proportional Hazards Model
- Fitted a multivariable Cox proportional hazards model to estimate adjusted effects of predictors on overall survival  

**Key Findings:**
- Age at diagnosis, lymph node involvement, and Nottingham Prognostic Index (NPI) were strong predictors of increased hazard  
- These variables reflect underlying disease severity and were consistently associated with poorer survival outcomes  
- Treatment variables (chemotherapy, radiotherapy) showed associations with survival, but these require cautious interpretation  
- HER2 subtype was also associated with differences in survival risk  

**Performance:**
- Model discrimination: C-index ≈ 0.665 (moderate ability to rank patient risk)

**Interpretation:**
- Disease severity appears to be the dominant driver of survival outcomes  
- Treatment-related associations observed in the model are not necessarily causal and may reflect confounding by indication  
- The Cox model provides adjusted estimates of association, improving upon univariate analyses such as log-rank tests  
---

### Task 7: Proportional Hazards Diagnostics
- Assessed the proportional hazards (PH) assumption using Schoenfeld residuals and formal statistical tests  

**Results:**
- Several covariates showed clear time-dependent trends in Schoenfeld residual plots  
- Global test for proportional hazards was highly significant  

**Interpretation:**
- The effects of multiple predictors are not constant over time, indicating violation of the PH assumption  
- This suggests that a standard Cox model may oversimplify the underlying risk structure  

**Conclusion:**
> The baseline Cox model does not fully satisfy the proportional hazards assumption, and extensions such as stratification or time-varying effects are required for more accurate modelling
---

### Task 8: Stratified Cox Model
- Fitted a stratified Cox model to address violations of the proportional hazards assumption  
- Stratified by ER status and chemotherapy, allowing separate baseline hazards across these groups  

**Results:**
- Improved model discrimination (C-index ≈ 0.672)  
- Reduced impact of PH violations for stratified variables  

**Interpretation:**
- Stratification accounts for non-proportional hazards by allowing different baseline risk patterns across groups  
- This improves model validity when the proportional hazards assumption does not hold  

**Limitation:**
- Hazard ratios for stratified variables are not estimated, limiting direct interpretation of their effects   

---

### Task 9: PH Diagnostics After Stratification
- Re-assessed the proportional hazards (PH) assumption after fitting the stratified Cox model using Schoenfeld residuals and formal statistical tests  

**Findings:**
- Violations were reduced for stratified categorical variables (e.g., ER status, chemotherapy), indicating improved model fit  
- However, residual plots for continuous predictors such as age at diagnosis and Nottingham Prognostic Index (NPI) continued to show systematic time-dependent trends  
- The global test remained indicative of residual non-proportionality  

**Interpretation:**
- Stratification successfully addressed PH violations for selected categorical variables by allowing separate baseline hazards across strata  
- Persistent trends in Schoenfeld residuals for continuous variables suggest that their effects on hazard are not constant over time  
- These patterns reflect genuine time-dependent relationships rather than random variation  

**Conclusion:**
> While stratification improved overall model validity, it did not fully resolve proportional hazards violations. The remaining time-dependent effects in continuous predictors motivated the use of time-varying Cox models to better capture the dynamic nature of survival risk.
---

### Task 10: Time-Varying Cox Model
- Extended the Cox proportional hazards model to allow time-dependent effects for selected continuous predictors using `tt()` with a log-time transformation  

**Results:**
- Significant time-varying effects were identified for:
  - Age at diagnosis  
  - Nottingham Prognostic Index (NPI)  
- These predictors exhibited systematic changes in their association with hazard over follow-up time  
- Model performance improved:
  - C-index ≈ **0.677** (best-performing Cox-based model)

**Interpretation:**
- The effects of key continuous predictors were not constant over time, confirming violations of the proportional hazards assumption observed in earlier models  
- Modelling time-dependent effects allowed the impact of age and NPI to evolve over follow-up, providing a better fit to the underlying data  
- This approach captures the dynamic nature of survival risk more realistically than standard Cox models with fixed coefficients  

**Key Insight:**
> The impact of important prognostic factors is time-dependent rather than constant — survival risk evolves over follow-up, and accounting for this improves both model validity and predictive performance  

**Conclusion:**
- Incorporating time-varying effects addressed residual non-proportionality that remained after stratification  
- The time-varying Cox model provided the most appropriate representation of the data among the Cox-based approaches, balancing improved validity with interpretability  
---

### Task 11: Model Comparison

| Model | C-index |
|------|--------|
| Baseline Cox | ~0.665 |
| Stratified Cox | ~0.672 |
| Time-varying Cox | ~0.677 |

**Insight:**
- Progressive improvements in C-index were observed as model assumptions were systematically addressed  
- The baseline Cox model provided a reasonable starting point but violated key assumptions  
- Stratification improved model validity by accounting for non-proportional hazards in categorical variables  
- Incorporating time-varying effects further improved performance by capturing dynamic changes in risk for continuous predictors  

**Interpretation:**
- Improvements in discrimination were modest but consistent, indicating that better alignment between model assumptions and data structure enhances predictive performance  
- The time-varying Cox model provided the most realistic representation of survival risk by allowing key covariate effects to evolve over time  

**Key Takeaway:**
> Model refinement guided by diagnostic checks improves both validity and performance, even when gains in predictive metrics are incremental  

---

### Task 12: Penalized Cox Regression
- Applied LASSO penalized Cox regression to perform feature selection and assess model robustness under regularization  
- Used cross-validation to identify the optimal penalty parameter (λ)

**Results:**
- Key predictors retained after regularization included:
  - Age at diagnosis  
  - Lymph node involvement  
  - Nottingham Prognostic Index (NPI)  
  - Treatment variables (e.g., chemotherapy, radiotherapy)  
  - HER2 subtype  
- Many less informative variables were shrunk towards zero, simplifying the model  

**Interpretation:**
- LASSO regularization reduces overfitting by penalizing model complexity and shrinking coefficients  
- The persistence of core clinical predictors indicates that their association with survival is strong and robust  
- Variable selection was stable, suggesting that the main findings are not sensitive to model specification  

**Key Insight:**
> Core prognostic factors remain consistent even under regularization, reinforcing their importance and improving confidence in the model’s validity  
---
### Task 13: Random Survival Forest
- Applied a Random Survival Forest (RSF) model to capture non-linear relationships and complex interactions in survival data  
- Evaluated model performance and variable importance  

**Results:**
- Top predictors identified by variable importance:
  - Age at diagnosis  
  - Lymph node involvement  
  - Nottingham Prognostic Index (NPI)  
- Additional predictors (e.g., HER2 subtype, treatment variables) showed smaller contributions  
- Model performance:
  - C-index ≈ **0.667**

**Interpretation:**
- The RSF model captured non-linear effects and interactions without requiring proportional hazards assumptions  
- Variable importance rankings were consistent with findings from Cox-based models  
- This indicates that key prognostic factors are robust across both statistical and machine learning approaches  

**Key Insight:**
> Machine learning confirmed the importance of core clinical predictors, but did not outperform a well-specified Cox model in this dataset  

**Conclusion:**
- Increased model complexity did not lead to improved predictive performance  
- A carefully specified Cox model with appropriate handling of assumptions can perform as well as, or better than, more complex machine learning methods  
---
### Task 14: Calibration Analysis
- Assessed model calibration by comparing predicted versus observed survival probabilities at 5 years  
- Evaluated agreement between model predictions and actual outcomes using calibration curves  

**Results:**
- The model systematically overestimated survival probabilities  
- The calibration curve lies below the ideal (45-degree) line, particularly at higher predicted survival levels  
- Deviation from the ideal line increases in regions with fewer observations  

**Interpretation:**
- While the model demonstrates reasonable discrimination (C-index), it is not well calibrated  
- Overestimation of survival probability indicates that predicted risks are overly optimistic  
- This discrepancy suggests that predicted probabilities may not be reliable for clinical decision-making without further adjustment  

**Key Insight:**
> Good discrimination does not guarantee good calibration — a model can rank patients correctly while still producing inaccurate probability estimates  

**Conclusion:**
- Calibration is essential for evaluating the clinical utility of survival models  
- Even well-performing models may require recalibration before being used for risk prediction in practice  
---

## Key Takeaways

- Survival data often violate standard modeling assumptions  
- Risk is dynamic rather than constant over time  
- Model validation is as important as model fitting  
- Core predictors are robust across:
  - Cox models  
  - Penalized models  
  - Machine learning models  
- Increased complexity does not necessarily produce better clinical prediction  

---

## Project Structure

```
breast-cancer-survival-analysis/
│
├── app.R            # Shiny dashboard
├── scripts/         # R scripts for each analysis step
├── raw/             # raw dataset
├── clean/           # cleaned datasets
├── results/         # outputs (figures, tables, models)
├── notes/           # learning journal + interpretations
├── README.md
```
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
  *(University of Bristol, UK)*  
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