# References

## Data source

cBioPortal for Cancer Genomics (2026) METABRIC Breast Cancer dataset. Available at: https://www.cbioportal.org/datasets (Accessed: 16 March 2026).

Curtis, C., Shah, S.P., Chin, S.-F., Turashvili, G., Rueda, O.M., Dunning, M.J., Speed, D., Lynch, A.G., Samarajiwa, S., Yuan, Y., Graf, S., Ha, G., Haffari, G., Bashashati, A., Russell, R., McKinney, S., METABRIC Group, Langerød, A., Green, A., Provenzano, E., Wishart, G., Pinder, S., Watson, P., Markowetz, F., Murphy, L., Ellis, I., Purushotham, A., Børresen-Dale, A.-L., Brenton, J.D., Tavaré, S., Caldas, C. and Aparicio, S. (2012) ‘The genomic and transcriptomic architecture of 2,000 breast tumours reveals novel subgroups’, *Nature*, 486, pp. 346–352.

Pereira, B., Chin, S.-F., Rueda, O.M., Vollan, H.-K.M., Provenzano, E., Bardwell, H.A., Pugh, M., Jones, L., Russell, R., Sammut, S.-J., Tsui, D.W.Y., Liu, B., Dawson, S.-J., Abraham, J., Northen, H., Peden, J.F., Mukherjee, A., Turashvili, G., Green, A.R., McKinney, S., Oloumi, A., Shah, S.P., Rosenfeld, N., Murphy, L., Bentley, D.R., Ellis, I.O., Purushotham, A., Pinder, S.E., Børresen-Dale, A.-L., Earl, H.M., Pharoah, P.D.P., Ross, M.T., Aparicio, S. and Caldas, C. (2016) ‘The somatic mutation profiles of 2,433 breast cancers refine their genomic and transcriptomic landscapes’, *Nature Communications*, 7, 11479.

* * *

## Survival analysis foundations

Kaplan, E.L. and Meier, P. (1958) ‘Nonparametric estimation from incomplete observations’, *Journal of the American Statistical Association*, 53(282), pp. 457–481.

Mantel, N. (1966) ‘Evaluation of survival data and two new rank order statistics arising in its consideration’, *Cancer Chemotherapy Reports*, 50(3), pp. 163–170.

Cox, D.R. (1972) ‘Regression models and life-tables’, *Journal of the Royal Statistical Society: Series B*, 34(2), pp. 187–220.

Therneau, T.M. and Grambsch, P.M. (2000) *Modeling Survival Data: Extending the Cox Model*. New York: Springer.

* * *

## Proportional hazards diagnostics and extended Cox modelling

Grambsch, P.M. and Therneau, T.M. (1994) ‘Proportional hazards tests and diagnostics based on weighted residuals’, *Biometrika*, 81(3), pp. 515–526.

Harrell, F.E. (2015) *Regression Modeling Strategies: With Applications to Linear Models, Logistic and Ordinal Regression, and Survival Analysis*. 2nd edn. Cham: Springer.

Simon, N., Friedman, J., Hastie, T. and Tibshirani, R. (2011) ‘Regularization paths for Cox’s proportional hazards model via coordinate descent’, *Journal of Statistical Software*, 39(5), pp. 1–13.

* * *

## Penalized and machine learning survival models

Ishwaran, H., Kogalur, U.B., Blackstone, E.H. and Lauer, M.S. (2008) ‘Random survival forests’, *The Annals of Applied Statistics*, 2(3), pp. 841–860.

Simon, N., Friedman, J., Hastie, T. and Tibshirani, R. (2011) ‘Regularization paths for Cox’s proportional hazards model via coordinate descent’, *Journal of Statistical Software*, 39(5), pp. 1–13.

* * *

## Breast cancer prognostic context

Haybittle, J.L., Blamey, R.W., Elston, C.W., Johnson, J., Doyle, P.J., Campbell, F.C., Nicholson, R.I. and Griffiths, K. (1982) ‘A prognostic index in primary breast cancer’, *British Journal of Cancer*, 45(3), pp. 361–366.

Elston, C.W. and Ellis, I.O. (1991) ‘Pathological prognostic factors in breast cancer. I. The value of histological grade in breast cancer: experience from a large study with long-term follow-up’, *Histopathology*, 19(5), pp. 403–410.

* * *

## Software and tools

R Core Team (2026) *R: A Language and Environment for Statistical Computing*. Vienna: R Foundation for Statistical Computing. Available at: https://www.r-project.org/

Wickham, H., Averick, M., Bryan, J., Chang, W., McGowan, L.D.A., François, R., Grolemund, G., Hayes, A., Henry, L., Hester, J., Kuhn, M., Pedersen, T.L., Miller, E., Bache, S.M., Müller, K., Ooms, J., Robinson, D., Seidel, D.P., Spinu, V., Takahashi, K., Vaughan, D., Wilke, C., Woo, K. and Yutani, H. (2019) ‘Welcome to the tidyverse’, *Journal of Open Source Software*, 4(43), 1686.

Wickham, H. (2016) *ggplot2: Elegant Graphics for Data Analysis*. 2nd edn. Cham: Springer.

Therneau, T.M. (2026) *survival: A Package for Survival Analysis in R*. Available at: https://CRAN.R-project.org/package=survival

Kassambara, A., Kosinski, M. and Biecek, P. (2026) *survminer: Drawing Survival Curves using 'ggplot2'*. Available at: https://CRAN.R-project.org/package=survminer

Simon, N., Friedman, J., Hastie, T. and Tibshirani, R. (2026) *glmnet: Lasso and Elastic-Net Regularized Generalized Linear Models*. Available at: https://CRAN.R-project.org/package=glmnet

Ishwaran, H. and Kogalur, U.B. (2026) *randomForestSRC: Fast Unified Random Forests for Survival, Regression, and Classification (RF-SRC)*. Available at: https://CRAN.R-project.org/package=randomForestSRC

Harrell, F.E. (2026) *rms: Regression Modeling Strategies*. Available at: https://CRAN.R-project.org/package=rms

* * *

## Conceptual note

The methodology used in this project combines classical and advanced survival analysis approaches, including:

- non-parametric survival estimation using Kaplan–Meier curves
- group comparison using the log-rank test
- semi-parametric regression using the Cox proportional hazards model
- proportional hazards diagnostics using Schoenfeld residuals
- model extension through stratified and time-varying Cox models
- penalized survival modelling using LASSO Cox regression
- non-linear survival prediction using Random Survival Forests
- calibration analysis for assessing agreement between predicted and observed survival

Together, these methods provide a progression from descriptive survival analysis to multivariable inference, model diagnostics, flexible modelling, and validation, allowing the project to address both prognostic interpretation and predictive performance in breast cancer survival data.