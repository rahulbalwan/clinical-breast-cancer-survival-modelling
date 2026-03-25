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
