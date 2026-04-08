# Survival Analysis Project — Learning Journal

This journal documents the full analytical process of a survival analysis project, combining:
- rigorous statistical reasoning  
- step-by-step implementation  
- empirical results  
- critical reflection  

The goal is not just to build models, but to develop a **deep understanding of time-to-event data, model assumptions, and real-world clinical complexity**.

---

# 1. Project Setup & Analytical Framing

## Objective
To establish a structured, reproducible workflow for survival analysis.

## Implementation
I designed a modular pipeline reflecting the natural progression of analysis:
setup → cleaning → classical survival → diagnostics → advanced models → validation


Project structure:
- `/raw` → immutable source data  
- `/clean` → processed datasets  
- `/results` → outputs (plots, tables, models)  

Git was initialized from the start to track:
- data transformations  
- modeling decisions  
- iterative refinements  

## Results
- Clean and reproducible structure  
- Full version control history  
- Clear separation between raw and processed data  

## Interpretation
This ensures:
- **Reproducibility** → every step can be recreated  
- **Data integrity** → raw data remains unchanged  
- **Traceability** → all analytical decisions are documented  

## Critical Reflection
This stage is often underestimated, but it directly affects:
- scientific credibility  
- debugging efficiency  
- collaboration  

Poor setup can lead to:
- irreproducible results  
- data leakage  
- unclear modeling logic  

---

# 2. Data Inspection & Structural Understanding

## Objective
To understand dataset structure, variable types, missingness, and clinical plausibility.

## Implementation
- Loaded and parsed dataset  
- Removed metadata rows (`#`)  
- Examined:
  - dimensions  
  - variable types  
  - summary statistics  
- Identified endpoints:
  - Overall Survival (OS)  
  - Relapse-Free Survival (RFS)  
- Assessed missingness  

## Results
- Dataset: **2509 observations × 24 variables**  
- Event variables stored as text labels  
- Missingness observed in:
  - OS_MONTHS  
  - NPI  
  - lymph node variables  

## Interpretation

Survival analysis requires:
 - (time, event indicator, covariates)


The dataset is suitable, but requires preprocessing before modeling.

## Critical Reflection

Missingness is likely **not random**, meaning:

- certain patient groups may be systematically missing data  
- this can introduce **selection bias**  
- estimates may not generalize to the full population  

---

# 3. Data Cleaning & Transformation

## Objective
To construct analysis-ready survival datasets.

## Implementation
- Converted event variables:
  - OS_STATUS → OS_EVENT (0/1)
  - RFS_STATUS → RFS_EVENT (0/1)
- Standardized variable types:
  - numeric → continuous  
  - categorical → factor  
- Removed observations with missing survival times  
- Created:
  - OS dataset  
  - RFS dataset  

## Results
- Reduced dataset size due to missing values  
- Fully model-ready datasets created  

## Interpretation

The dataset now satisfies survival model requirements:
 - (time, event, covariates)


This enables valid likelihood-based modeling.

## Critical Reflection

Removing missing data:
- simplifies modeling  
- but reduces sample size  
- and may introduce bias  

Alternative approaches:
- multiple imputation  
- inverse probability weighting  

---

# 4. Kaplan–Meier Survival Estimation

## Objective
To estimate survival probabilities without parametric assumptions.

## Concept

Kaplan-Meier estimates survival as:
S(t) = product over event times of (1 - events at time t / individuals at risk at time t)


## Implementation
- Estimated KM curves for:
  - Overall Survival (OS)  
  - Relapse-Free Survival (RFS)  
- Generated plots with confidence intervals  

## Results
- RFS declines faster than OS  
- Confidence intervals widen over time  
- Stepwise drops reflect event timing  

## Interpretation
- Relapse occurs earlier than death  
- Late estimates are unstable due to fewer patients at risk  

## Critical Reflection
Kaplan-Meier is:
- descriptive  
- unadjusted  

It does not:
- control for confounding  
- explain causal relationships  

---

# 5. Log-Rank Test

## Objective
To compare survival distributions across groups.

## Implementation
- Compared:
  - ER status  
  - Hormone therapy  
- Computed log-rank p-values  

## Results
- ER status: not significant  
- Hormone therapy: highly significant  

## Interpretation
Hormone therapy appears associated with improved survival.

## Critical Reflection

This is likely **confounding by indication**:

- higher-risk patients receive more treatment  
- treatment is not randomly assigned  

Log-rank test limitations:
- unadjusted  
- assumes proportional hazards  

---

# 6. Cox Proportional Hazards Model

## Objective
To estimate adjusted effects of predictors on survival.

## Concept

Cox model: hazard(t | X) = baseline hazard × exp(beta × X)


## Implementation
- Fitted multivariable model including:
  - age  
  - NPI  
  - lymph nodes  
  - treatments  

## Results
Strong predictors:
- Age (HR ~ 1.04)  
- Lymph nodes (HR ~ 1.05)  
- NPI (HR ~ 1.20)  

Performance:
- C-index ≈ 0.665  

## Interpretation
- Disease severity dominates survival risk  
- Adjustment changes conclusions from univariate analysis  

## Critical Reflection

Key assumption:
- Effect of each variable is constant over time



This must be tested before trusting results.

---

# 7. Proportional Hazards Diagnostics

## Objective
To test Cox model validity.

## Implementation
- Schoenfeld residual tests  
- Diagnostic plots  

## Results
- Global test highly significant  
- Multiple variables violate assumptions  

## Interpretation
Good ranking ≠ accurate probabilities


## Critical Reflection
Calibration is critical for:
- clinical decision-making  
- risk communication  

---

# Final Insight

The central challenge in survival analysis is: modeling time-dependent risk, not static effects


---

# Future Work

- Time-dependent AUC  
- External validation  
- Causal survival inference  
- Deep learning survival models  
