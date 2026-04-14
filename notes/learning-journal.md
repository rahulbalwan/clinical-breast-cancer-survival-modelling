# Survival Analysis Project — Learning Journal

This journal documents the full analytical process of a survival analysis project, integrating:

- rigorous statistical reasoning  
- structured, reproducible implementation  
- empirical results  
- critical reflection  

The objective extends beyond model building to developing a **deep understanding of time-to-event data, model assumptions, and real-world clinical complexity**.

---

# 1. Project Setup & Analytical Framing

## Objective
To establish a structured, reproducible, and transparent workflow for survival analysis.

## Implementation
A modular pipeline was designed to reflect the natural progression of analysis:

> setup → data cleaning → exploratory analysis → classical survival methods → diagnostics → advanced modelling → validation

Project structure:
- `/raw` → immutable source data  
- `/clean` → processed, analysis-ready datasets  
- `/results` → outputs (plots, tables, models)  

Version control (Git) was used throughout to track:
- data transformations  
- modelling decisions  
- iterative refinements  

## Results
- Fully reproducible workflow  
- Clear separation between raw and processed data  
- Complete audit trail of analytical decisions  

## Interpretation
This structure ensures:
- **Reproducibility** → results can be independently recreated  
- **Data integrity** → raw data remains unchanged  
- **Traceability** → modelling decisions are transparent  

## Critical Reflection
This stage is often underestimated, but is foundational for:
- scientific credibility  
- debugging and validation  
- collaboration and scalability  

Poor setup risks:
- irreproducibility  
- data leakage  
- ambiguous analytical logic  

---

# 2. Data Inspection & Structural Understanding

## Objective
To understand dataset structure, variable types, missingness, and clinical plausibility.

## Implementation
- Loaded and parsed the dataset  
- Removed metadata rows (`#`)  
- Explored:
  - dataset dimensions  
  - variable types  
  - summary statistics  
- Identified endpoints:
  - Overall Survival (OS)  
  - Relapse-Free Survival (RFS)  
- Assessed missing data patterns  

## Results
- Dataset: **2509 observations × 24 variables**  
- Event variables stored as text labels  
- Missingness present in:
  - OS_MONTHS  
  - NPI  
  - lymph node variables  

## Interpretation
Survival analysis requires:
> (time, event indicator, covariates)

The dataset is structurally suitable, but requires preprocessing before modelling.

## Critical Reflection
Missingness is likely **not completely at random**, implying:

- systematic differences across patient groups  
- potential **selection bias**  
- limited generalisability  

---

# 3. Data Cleaning & Transformation

## Objective
To construct analysis-ready survival datasets.

## Implementation
- Converted event variables:
  - OS_STATUS → OS_EVENT (0/1)  
  - RFS_STATUS → RFS_EVENT (0/1)  
- Standardised variable types:
  - numeric → continuous  
  - categorical → factor  
- Removed observations with missing survival times  
- Created separate datasets for:
  - Overall Survival (OS)  
  - Relapse-Free Survival (RFS)  

## Results
- Reduced dataset size due to missing data removal  
- Fully model-ready datasets created  

## Interpretation
The dataset now satisfies requirements for survival modelling:
> (time, event, covariates)

## Critical Reflection
Complete-case analysis:
- simplifies modelling  
- but may introduce bias and reduce power  

Alternative approaches:
- multiple imputation  
- inverse probability weighting  

---

# 4. Kaplan–Meier Survival Estimation

## Objective
To estimate survival probabilities without parametric assumptions.

## Concept
Kaplan–Meier estimator:

$$
S(t) = \prod_{t_i \le t} \left(1 - \frac{d_i}{n_i}\right)
$$

## Implementation
- Estimated survival curves for:
  - Overall Survival (OS)  
  - Relapse-Free Survival (RFS)  
- Generated plots with confidence intervals  

## Results
- RFS declines more rapidly than OS  
- Confidence intervals widen over time  
- Stepwise decreases correspond to event times  

## Interpretation
- Recurrence occurs earlier than mortality  
- Later estimates are less stable due to fewer patients at risk  

## Critical Reflection
Kaplan–Meier is:
- descriptive  
- unadjusted  

It does not:
- control for confounding  
- provide causal interpretation  

---

# 5. Log-Rank Test

## Objective
To compare survival distributions between groups.

## Implementation
- Compared:
  - ER status  
  - Hormone therapy  
- Performed log-rank tests  

## Results
- ER status: not statistically significant  
- Hormone therapy: statistically significant  

## Interpretation
Hormone therapy appears associated with improved survival.

## Critical Reflection
This result likely reflects **confounding by indication**:

- treatment is not randomly assigned  
- higher-risk patients may be more likely to receive therapy  

Limitations of log-rank test:
- unadjusted  
- assumes proportional hazards  

---

# 6. Cox Proportional Hazards Model

## Objective
To estimate adjusted associations between predictors and survival.

## Concept
\[
h(t | X) = h_0(t) \exp(\beta X)
\]

## Implementation
Fitted a multivariable Cox model including:
- age  
- NPI  
- lymph nodes  
- treatment variables  

## Results
Significant predictors:
- Age (HR ~ 1.04)  
- Lymph nodes (HR ~ 1.05)  
- NPI (HR ~ 1.20)  

Performance:
- C-index ≈ 0.665  

## Interpretation
- Disease severity is a dominant determinant of survival  
- Adjustment alters conclusions from univariate analysis  

## Critical Reflection
Key assumption:
> Hazard ratios are constant over time (proportional hazards)

This assumption must be validated.

---

# 7. Proportional Hazards Diagnostics

## Objective
To assess validity of the Cox model.

## Implementation
- Schoenfeld residual tests  
- Visual diagnostic plots  

## Results
- Global test highly significant  
- Multiple variables show time-dependent patterns  

## Interpretation
- The proportional hazards assumption is violated  
- Effects of predictors are not constant over time  

## Critical Reflection
- Good discrimination does not imply model validity  
- Model assumptions must be explicitly tested  

---

# 8–10. Model Refinement: Stratification & Time-Varying Effects

## Objective
To address violations of the proportional hazards assumption.

## Implementation
- Stratified Cox model for categorical variables (e.g., ER status)  
- Time-varying Cox model using `tt()` for continuous predictors (age, NPI)  

## Results
- Improved model performance:
  - Baseline Cox: ~0.665  
  - Stratified Cox: ~0.672  
  - Time-varying Cox: ~0.677  
- Significant time-dependent effects for:
  - Age  
  - NPI  

## Interpretation
- Risk is not static — it evolves over time  
- Time-varying modelling provides a more realistic representation of survival processes  

## Critical Reflection
- Different types of variables require different modelling strategies  
- Model refinement should be guided by diagnostics, not assumptions  

---

# 11–13. Model Robustness & Machine Learning Comparison

## Objective
To assess robustness and compare modelling approaches.

## Implementation
- LASSO penalised Cox regression  
- Random Survival Forest (RSF)  

## Results
- Core predictors consistently identified:
  - Age  
  - Lymph nodes  
  - NPI  
- RSF performance:
  - C-index ≈ 0.667  
- No improvement over time-varying Cox model  

## Interpretation
- Core predictors are stable across methods  
- Increased model complexity did not improve performance  

## Critical Reflection
- Machine learning does not guarantee better performance  
- Model choice should be guided by data structure, not complexity  

---

# 14. Calibration Analysis

## Objective
To evaluate agreement between predicted and observed survival probabilities.

## Results
- Model overestimates survival probability  
- Calibration curve lies below the ideal line  

## Interpretation
- Model predictions are overly optimistic  
- Discrimination and calibration capture different aspects of performance  

## Critical Reflection
- A model can rank patients correctly but still produce inaccurate probabilities  
- Calibration is essential for clinical usefulness  

---

# Final Insight

> The central challenge in survival analysis is modelling **time-dependent, dynamic risk**, rather than assuming static effects.

This project demonstrates that:
- model assumptions must be tested and addressed  
- increased complexity does not guarantee better performance  
- robust conclusions require consistency across methods  
- calibration is critical for real-world applicability  

---

# Future Work

- Time-dependent AUC  
- External validation  
- Causal survival analysis  
- Joint modelling / deep learning approaches  
