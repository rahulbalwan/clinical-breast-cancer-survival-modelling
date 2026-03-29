Hello, Here you can follow my way of learning and working on this project.

## Setup Tasks:

### Completed:
- Created a new project folder
- Initialized Git
- Setup the folder structure
- Added the raw dataset (folder raw contains the data)
- Created basic README file
- Added .gitignore and placeholder tracked folders

### Understanding:
- The pipeline is organized from setup --> cleaning --> classical survival --> diagnostics --> advanced models --> validation
- Git should start from the beginning
- The raw dataset and the cleaned datasets should stay seperated

### Next Step:
- Inspect the raw dataset in detail
- Idenify key survival columns and clinical covariates


## Inspecting the data Task:

### Completed:
- Loaded the raw clinical dataset
- Removed metadata rows begining with '#'
- Parsed the file into a data frame
- Inspected dimensions, column names, structure, and summary statistics
- Checked OS and RFS survival status fields
- Examined missing values and key clinical variables
- Saved a sample CSV in the 'clean/' folder

### Observations:
- The dataset has 2509 observations and 24 columns
- The main survival endpoints are OS and RFS
- 'OS_STATUS' and 'RFS_STATUS' are text-based and need conversion into numeric event indicators
- Several important variables contain missing values,especially 'OS_MONTHS', 'NPI', and lymph node counts
- Predictors are a mix of numeric and categorical variables
- 'OS_STATUS' contains '0:LIVING' and '1:DECREASED'
- 'RFS_STATUS' contains '0:Not Recurred', '1:Recurred', and some missing values
- 'LYMPH_NODES_EXAMINED_POSITIVE' is the correct node burden variable
- Age and NPI distributions look clinically plausible


### Next Step:
- Create a cleaning script to build 'OS_EVENT" and 'RFS_EVENT'
- Create analysis-ready datasets for 0S and RFS
- Standardize categorical and numeric variables


## Cleaning the data

### Completed:
- Created acleaning script for survival analysis
- Converted OS and RFS status variables into numeric event indicators
- Converted key clinical variables to numeric format
- Created seperate datasets for OS and RFS
- Saved analysis-ready csv files

### Understanding:
- Survival analysis required time and event variables in machine-readable form
- Text-based event labels must be converted to binary values
- Missing time values make rows unusable for survival modelling
- Different endpoints require seperate analysis datasets

### Observations:
- The OS dataset has fewer rows than the RFS dataset
- This is expected because OS has more missing follow-up values
- The cleaned datasets now contain 13 variables each

### Next Step:
- Fit Kaplan-Meier survival curves for OS and FRS
- Begin the first real survival analysis step


## Kaplan-Meier Curves

### Completed:
- Implemented KM survival analysis
- Created survival curves for:
 - Overall Survival (OS)
 - Relapse-Free Survival (RFS)
- Saved plots in results/figures

### Understanding:
- Kaplan-Meier estimated survival probability over time
- Survival curves are step functions
- Each drop corresponds to an event
- Confidence intervals widen as sample size decreases

### Observations:
- RFS declines faster than OS
- This suggests relapse occurs earlier than death
- Survival remains substantial over long follow-up
- Late estimates are less reliable due to fewer patients

### Concepts:
- Survival = probability of being event-free
- Event definition differs between OS and RFS
- Time-to-event analysis is different from standard regression

### Next Step:
- Perform log-rank test to compare survival across groups

## Log-rank test
### Completed:
- Performed log-rank tests to compare survival between groups
- Compared:
 - ER status (ER_IHC)
 - Hormone therapy (HORMONE_THERAPY)
- Extracted p-values and saved results

### Understanding:
- Log-rank test compared survival distrivutions between groups
- A p-value < 0.05 indicates a statistically significant difference
- Log-rank tests are unadjusted (don't control for confounders)

### Key Results:
#### ER Status
- p-value = 0.11
- No statistically significant difference in survival

#### Hormone Therapy
- p-value < 0.001
- Strong evidence of survival difference between groups

### Interpretation
- ER status alone does not significantly seperate survival curves
- Hormone therapy shows significant association with survival
- However, this likely reflects confounding:
 - Higher-risk patients may be more likely to receive treatment

### Understanding:
- Log-rank tests are useful for initial comparisons
- They do not account for other variables
- Multivariate modelling (Cox regression) is required

### Next Step:
- Build Cox Proportional hazards model
- Estimate adjusted effects of predictors on survival

## Cox proportional hazards model

### Completed:
- Fitted multivariate Cox proportional hazards model
- Included demographic, clinical, and treament variables
- Evaluated hazard ratios and statistical significance
- Assessed model performance using concordance index

### Understanding:
- Cox regression estimated independent effects of predictors
- Hazard ratios quantify relative risk
- Adjusted models can change conclusions from univariable tests

### Key results:
#### Strong predictors -
- Age: HR = 1.04 ---- increased risk with age
- Lymph nodes: HR = 1.05 ---- higher tumor burden increases risk
- NPI: HR = 1.20 ---- strong prognostic factor

#### Treatment variables -
- Chemotherapy: HR = 1.54 (higher hazard)
   - Likely confounding by indication
- Radiotherapy: HR = 0.74 (proactive)

#### Non-significant variables -
- ER status
- Hormone therapy
- Cellularity

### Model performance:
- C-index = 0.665
- Indicates moderate predictive ability

### Key insights:
- Log-rank test suggested hormone therapy was significant
- Cox model showed it is not significant after adjustment
- Demonstrates the importance of controlling for confounding 

## Next Step:
- Check proportional hazards assumption

## PH Assumption Diagnostics

### Completed:
- Tested the propotional hazards assumption using Schoenfeld residuals via `cox.zph()`

### Key Findings

The proportional hazards assumption was strongly violated for multiple covariates, including:

- Age at diagnosis
- NPI
- ER status
- Hormone therapy
- Chemotherapy
- HER2 subtype

The global test was highly significant (p < 2e-16), confirming that the Cox model assumption does not hold globally.

### Interpretation of Plots

Schoenfeld residual plots showed clear time-dependent trends:

- Age effect increases over time
- Treatment effects (chemotherapy, hormone therapy) are dynamic
- Biological markers (ER, HER2) exhibit evolving risk patterns

### Clinical Insight

This suggests that:

- Survival risk is not constant over follow-up
- Treatment effects may vary between early and late survival
- Biological factors influence survival differently across time

### Key Learning

- Cox model assumptions must always be tested
- Real-world clinical data often violate proportional hazards
- Advanced models are required for valid inference

### Next Steps

- Fit Stratified Cox model
- Implement time-varying Cox model

## Stratified Cox Model
### Purpose
To address proportional hazards violations observed in the baseline Cox model.

### Approach
Stratified by:
- ER status
- Chemotherapy

### Completed:
- Fitted a stratified Cox model
- Stratified by ER status and chemotherapy
- Estimated adjusted effects for key clinical variables

### Learning:
- Stratification allows different baseline hazards across groups
- It helps handle categorical variables that violate PH assumption
- Stratified variables are no longer interpreted via hazard ratios

### Key results:
- Age, lymph nodes, and NPI remain strong predictors
- Radiotherapy shows a consistent protective effect
- Model performance improved (C-index increased)

### Key insight:
- The baseline Cox model was misspecified due to PH violations
- Stratification improved model validity and interpretability
- Some variables are better treated as strata rather than predictors
- Not all variables should be modeled with fixed hazard ratios, some require flexible baseline risk structures.

## PH Diagnostics After Stratified Cox Model

### Purpose
To evaluate whether stratification successfully addressed proportional hazards (PH) violations observed in the baseline Cox model.

### Approach
- Applied Schoenfeld residual-based PH tests (`cox.zph`)
- Generated diagnostic plots for time-varying effects
- Compared results with baseline Cox model

### Completed:
- Performed PH test on stratified Cox model
- Generated statistical summary table
- Plotted Schoenfeld residuals for visual inspection

### Learning:
- Stratification reduced PH violations for categorical variables (ER status, chemotherapy)
- Continuous variables can still violate PH even after stratification
- Schoenfeld residual plots provide intuitive insight into time-varying effects

### Key results:
- AGE_AT_DIAGNOSIS → significant violation (time-dependent effect)
- NPI → strong violation (major time-varying predictor)
- LYMPH_NODES_EXAMINED_POSITIVE → no strong violation
- RADIO_THERAPY → stable over time
- GLOBAL test → still significant (model not fully valid)

### Interpretation:
- Stratification successfully improved model validity but did not fully resolve PH violations
- Continuous predictors such as age and NPI have effects that change over time
- The assumption of constant hazard ratios does not hold for all variables

### Key insight:
- Stratified Cox models are effective for handling categorical PH violations
- Continuous covariates often require explicit modeling of time-dependent effects
- Real-world clinical risk is dynamic, not constant over time

### Conceptual understanding:
- Cox model assumes:
  - constant hazard ratios over time
- Your data shows:
  - hazard ratios vary with time → violation of PH assumption
- This is a signal to move beyond standard Cox modeling

### Conclusion:
- The current model is improved but still not fully adequate
- A more flexible modeling approach is required

## Time-Varying cox model

### What I did
- Fitted a time-varying Cox model
- Modeled age and NPI as time-dependent covariates
- Used log(time + 1) transformation

### Key results
- AGE_AT_DIAGNOSIS shows strong time-varying effect
- NPI shows significant time-dependent behavior
- Lymph nodes remain stable predictor
- Radiotherapy shows consistent protective effect
- Chemotherapy associated with higher hazard (likely confounding)

### Model performance
- Concordance improved to 0.677

### What I learned
- Continuous predictors often violate PH assumption
- Time-varying Cox models provide more realistic modeling
- Hazard ratios are not always constant over time

### Key insight
- Survival risk is dynamic
- Static Cox models can be misleading if assumptions are violated

### Conclusion
- Time-varying Cox model is the most appropriate model so far

### Next step
- Compare models formally
- Evaluate predictive performance (C-index, AUC)


