# Survival Analysis Project — Learning Journal

This journal documents the full analytical process of a survival analysis project, combining:
- rigorous statistical theory  
- detailed implementation steps  
- empirical results  
- critical interpretation and reflection  

The objective is not only to build models, but to develop a **deep understanding of time-to-event data, model assumptions, and real-world clinical complexity**.

---

# 1. Project Setup & Analytical Framing

## Objective
To establish a structured, reproducible, and logically sequenced workflow for survival analysis.

---

## Implementation (What I did)
I began by designing a modular pipeline reflecting the natural progression of statistical modeling:

setup → cleaning → classical survival → diagnostics → advanced models → validation  

I created the following directory structure:
- `/raw` → immutable original dataset  
- `/clean` → processed datasets  
- `/results` → outputs, plots, and model summaries  

Git was initialized at the very beginning to track:
- data transformations  
- modeling decisions  
- iterative refinements  

---

## Results (What I got)
- A clean, organized project structure  
- Full version history of all steps  
- Clear separation between raw and processed data  

---

## Interpretation
This setup ensures:
- **reproducibility** → every step can be recreated  
- **data integrity** → raw data is never overwritten  
- **traceability** → all analytical changes are documented  

---

## Critical Reflection
This stage is often treated as administrative, but it directly impacts:
- scientific credibility  
- debugging efficiency  
- collaboration potential  

Poor structure at this stage often leads to:
- irreproducible results  
- accidental data leakage  
- unclear modeling logic  

---

## Next Step
Perform detailed inspection of the dataset

---

# 2. Data Inspection & Structural Understanding

## Objective
To understand the dataset’s structure, variable types, missingness patterns, and clinical plausibility.

---

## Implementation (What I did)
- Loaded dataset into analysis environment  
- Removed metadata rows beginning with `#`  
- Parsed data into a structured dataframe  
- Examined:
  - number of observations and variables  
  - column names and data types  
  - summary statistics (mean, median, ranges)  
- Investigated survival endpoints:
  - OS (Overall Survival)  
  - RFS (Relapse-Free Survival)  
- Quantified missing values across variables  

---

## Results (What I got)
- Dataset size: **2509 observations × 24 variables**  
- Identified key survival fields:
  - OS_MONTHS, OS_STATUS  
  - RFS_MONTHS, RFS_STATUS  
- Event variables stored as text labels (not model-ready)  
- Missing values concentrated in:
  - OS_MONTHS  
  - NPI  
  - lymph node variables  
- Clinical variables (age, NPI) show realistic distributions  

---

## Interpretation
The dataset is appropriate for survival analysis, but requires preprocessing:

- Survival analysis requires:
  \[
  (Y_i, \delta_i, X_i)
  \]

- Text-based event indicators must be converted  
- Missing survival times make observations unusable  

---

## Critical Reflection
The missingness pattern is unlikely to be random:

\[
P(Missing \mid X) \neq P(Missing)
\]

This suggests potential:
- selection bias  
- informative missingness  

Ignoring this could bias hazard estimates and reduce generalizability.

---

## Next Step
Construct analysis-ready survival datasets

---

# 3. Data Cleaning & Transformation

## Objective
To convert raw clinical data into a format suitable for survival modeling.

---

## Implementation (What I did)
- Converted survival status variables into binary indicators:
  - OS_STATUS → OS_EVENT  
  - RFS_STATUS → RFS_EVENT  
- Standardized variable types:
  - numeric → continuous variables  
  - categorical → factors  
- Removed observations with missing survival times  
- Created separate datasets:
  - OS dataset  
  - RFS dataset  
- Saved cleaned datasets to `/clean`

---

## Results (What I got)
- OS dataset reduced in size due to missing follow-up  
- RFS dataset retained more observations  
- Each dataset contains **13 analysis-ready variables**  

---

## Interpretation
The dataset now satisfies survival model requirements:

\[
(Y_i, \delta_i, X_i)
\]

This enables:
- likelihood-based estimation  
- valid hazard modeling  

---

## Critical Reflection
Removing missing data simplifies modeling but introduces trade-offs:
- reduced statistical power  
- potential selection bias  

Alternative approaches (not implemented here):
- multiple imputation  
- inverse probability weighting  

---

## Next Step
Estimate survival functions using Kaplan-Meier

---

# 4. Kaplan-Meier Survival Estimation

## Objective
To estimate survival probabilities without parametric assumptions.

---

## Theory
\[
\hat{S}(t) = \prod_{t_i \le t} \left(1 - \frac{d_i}{n_i} \right)
\]

---

## Implementation (What I did)
- Computed Kaplan-Meier curves for:
  - Overall Survival (OS)  
  - Relapse-Free Survival (RFS)  
- Generated survival plots with confidence intervals  
- Saved figures to `/results/figures`

---

## Results (What I got)
- RFS curve declines more rapidly than OS  
- Confidence intervals widen substantially at later time points  
- Stepwise drops correspond to event occurrences  

---

## Interpretation
- Relapse events occur earlier than mortality  
- Survival probability decreases over time as expected  
- Late-time estimates are unstable due to small risk sets  

---

## Critical Reflection
Kaplan-Meier provides:
- descriptive insight  
- no adjustment for covariates  

Thus, it cannot:
- explain *why* survival differs  
- control for confounding  

---

## Next Step
Compare survival across groups using log-rank test

---

# 5. Log-Rank Test

## Objective
To test whether survival distributions differ between groups.

---

## Implementation (What I did)
- Compared survival curves for:
  - ER status  
  - Hormone therapy  
- Computed log-rank test statistics and p-values  

---

## Results (What I got)
- ER status: p = 0.11 → not statistically significant  
- Hormone therapy: p < 0.001 → strong difference  

---

## Interpretation
Hormone therapy appears associated with improved survival.

---

## Critical Reflection
This result is likely confounded:

\[
\text{Treatment assignment} \neq \text{random}
\]

- High-risk patients are more likely to receive treatment  
- Observed association does not imply causality  

Log-rank test limitations:
- unadjusted  
- assumes proportional hazards  

---

## Next Step
Fit multivariate Cox model

---

# 6. Cox Proportional Hazards Model

## Objective
To estimate adjusted effects of multiple predictors on survival.

---

## Theory
\[
h(t|X) = h_0(t)\exp(\beta^T X)
\]

---

## Implementation (What I did)
- Fitted multivariate Cox model including:
  - age  
  - NPI  
  - lymph nodes  
  - treatment variables  
- Estimated hazard ratios  
- Computed concordance index  

---

## Results (What I got)

Strong predictors:
- Age: HR ≈ 1.04  
- Lymph nodes: HR ≈ 1.05  
- NPI: HR ≈ 1.20  

Treatment effects:
- Chemotherapy: HR ≈ 1.54  
- Radiotherapy: HR ≈ 0.74  

Model performance:
- C-index ≈ 0.665  

---

## Interpretation
- Disease severity variables dominate survival risk  
- Treatment effects reflect confounding by indication  
- Adjustment changes conclusions from univariable analysis  

---

## Critical Reflection
The model assumes:

\[
\beta(t) = \text{constant}
\]

This assumption must be tested before trusting results.

---

## Next Step
Evaluate proportional hazards assumption

---

# 7. PH Assumption Diagnostics

## Objective
To test validity of Cox model assumptions.

---

## Implementation (What I did)
- Applied Schoenfeld residual test  
- Generated residual plots  

---

## Results (What I got)
- Global test: p < 2e-16  
- Multiple variables show time-dependent effects  

---

## Interpretation
\[
\beta(t) \neq \beta
\]

- Hazard ratios are not constant  
- Model is misspecified  

---

## Critical Reflection
This is expected in clinical data:
- biological processes evolve  
- treatment effects change over time  

---

## Next Step
Apply model extensions (stratified and time-varying)

---

# 9. Time-Varying Cox Model

## Implementation (What I did)
- Modeled time interactions:
  - Age × log(t)  
  - NPI × log(t)  

---

## Results (What I got)
- Significant time-dependent effects  
- Best model performance: C-index ≈ 0.677  

---

## Interpretation
- Risk factors evolve dynamically  
- Model better reflects real-world survival processes  

---

## Critical Reflection
This model relaxes unrealistic assumptions and provides:
- more accurate inference  
- better predictive performance  

---

# Final Insight

The central challenge in survival analysis is:

\[
\text{modeling time-dependent risk, not static effects}
\]

---

# Future Work
- Time-dependent AUC  
- External validation  
- Causal survival modeling  
- Deep learning approaches  