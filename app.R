library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(survival)
library(survminer)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
library(scales)
library(htmltools)


# Helpers

safe_read_csv <- function(path) {
  tryCatch({
    if (file.exists(path)) read_csv(path, show_col_types = FALSE) else NULL
  }, error = function(e) {
    NULL
  })
}

safe_factorize <- function(df) {
  if (is.null(df)) return(df)

  factor_cols <- intersect(
    c("ER_IHC", "HORMONE_THERAPY", "CHEMOTHERAPY", "RADIO_THERAPY", "HER2_SNP6", "CELLULARITY"),
    names(df)
  )

  df %>% mutate(across(all_of(factor_cols), as.factor))
}

safe_label <- function(x) gsub("_", " ", x)

get_dataset <- function(endpoint, os_data, rfs_data) {
  if (endpoint == "OS") os_data else rfs_data
}

get_time_var <- function(endpoint) {
  if (endpoint == "OS") "OS_MONTHS" else "RFS_MONTHS"
}

get_event_var <- function(endpoint) {
  if (endpoint == "OS") "OS_EVENT" else "RFS_EVENT"
}

get_endpoint_label <- function(endpoint) {
  if (endpoint == "OS") "Overall Survival (OS)" else "Relapse-Free Survival (RFS)"
}

fmt_p <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 0.001) return("< 0.001")
  format(round(p, 4), nsmall = 4)
}

safe_value <- function(x, default = NA) {
  if (length(x) == 0 || all(is.na(x))) default else x[1]
}

safe_meaningful_name <- function(x) {
  x <- gsub("`", "", x)
  x <- gsub("_", " ", x)
  x
}

file_status_box <- function(title, ok = TRUE, detail = "") {
  box(
    width = 4,
    status = if (ok) "success" else "danger",
    solidHeader = TRUE,
    title = title,
    p(if (ok) "Loaded" else "Missing / unreadable"),
    if (nzchar(detail)) p(detail)
  )
}

normalize_rsf_perf <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(NULL)

  nm <- names(df)

  if (!"c_index" %in% nm) {
    alt <- nm[tolower(nm) %in% c("cindex", "c_index", "concordance", "concordance_index")]
    if (length(alt) > 0) names(df)[names(df) == alt[1]] <- "c_index"
  }

  if (!"model" %in% names(df)) df$model <- "Random Survival Forest"

  if (!"c_index" %in% names(df)) return(NULL)
  df
}

normalize_rsf_vimp <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(NULL)

  nm <- names(df)

  if (!"variable" %in% nm) {
    alt_var <- nm[tolower(nm) %in% c("variable", "feature", "features", "predictor")]
    if (length(alt_var) > 0) names(df)[names(df) == alt_var[1]] <- "variable"
  }

  if (!"importance" %in% nm) {
    alt_imp <- nm[tolower(nm) %in% c("importance", "vimp", "variable_importance", "score")]
    if (length(alt_imp) > 0) names(df)[names(df) == alt_imp[1]] <- "importance"
  }

  if (!all(c("variable", "importance") %in% names(df))) return(NULL)
  df
}

variable_dictionary <- tibble(
  Variable = c(
    "OS_MONTHS",
    "OS_EVENT",
    "RFS_MONTHS",
    "RFS_EVENT",
    "AGE_AT_DIAGNOSIS",
    "LYMPH_NODES_EXAMINED_POSITIVE",
    "NPI",
    "ER_IHC",
    "HORMONE_THERAPY",
    "CHEMOTHERAPY",
    "RADIO_THERAPY",
    "HER2_SNP6",
    "CELLULARITY"
  ),
  Definition = c(
    "Follow-up time in months for overall survival.",
    "Overall survival event indicator: typically 1 = death/event, 0 = censored.",
    "Follow-up time in months for relapse-free survival.",
    "Relapse-free survival event indicator: typically 1 = relapse/event, 0 = censored.",
    "Age in years at the time of diagnosis.",
    "Number of pathologically positive lymph nodes.",
    "Nottingham Prognostic Index, a composite prognostic score reflecting tumour size, nodal status, and grade.",
    "Estrogen receptor status measured by immunohistochemistry.",
    "Indicator of receipt of endocrine/hormone therapy.",
    "Indicator of receipt of chemotherapy.",
    "Indicator of receipt of radiotherapy.",
    "HER2-related measurement/status from SNP6-derived data.",
    "Approximate tumour cellularity or tumour cell proportion in the specimen."
  ),
  Clinical_Significance = c(
    "Longer OS indicates longer survival after diagnosis or treatment initiation.",
    "Defines mortality outcome for time-to-event modeling.",
    "Longer RFS indicates longer time without recurrence or relapse.",
    "Defines recurrence outcome for survival modeling.",
    "Older age is often associated with frailty, comorbidity burden, and competing mortality risk.",
    "Higher nodal burden usually reflects more advanced regional disease and worse prognosis.",
    "Higher NPI generally indicates poorer prognosis and greater disease severity.",
    "ER-positive disease often has therapeutic implications and may be associated with endocrine responsiveness.",
    "Reflects systemic endocrine treatment exposure; interpretation in observational data requires caution because treatment assignment is not random.",
    "Reflects systemic cytotoxic treatment exposure; associations may be confounded by disease severity.",
    "Reflects local-regional treatment exposure and may relate to recurrence control.",
    "HER2 biology is clinically important because it can influence tumour aggressiveness and treatment strategy.",
    "May reflect tumour content and specimen biology, potentially influencing molecular interpretation and prognosis."
  )
)

interpret_hr <- function(hr) {
  if (is.na(hr)) return("No clear interpretation.")
  if (hr > 1.2) {
    "Associated with a meaningfully higher hazard, suggesting worse prognosis after adjustment."
  } else if (hr < 0.8) {
    "Associated with a meaningfully lower hazard, suggesting a potentially protective or lower-risk profile after adjustment."
  } else {
    "Associated with a relatively modest effect size after adjustment."
  }
}

interpret_var_clinical <- function(var_name) {
  if (grepl("AGE", var_name, ignore.case = TRUE)) {
    return("Age is clinically relevant because older patients may carry greater frailty, competing risk, and reduced treatment tolerance.")
  }
  if (grepl("LYMPH", var_name, ignore.case = TRUE)) {
    return("Lymph node burden is a core marker of regional spread and usually signals more advanced disease.")
  }
  if (grepl("NPI", var_name, ignore.case = TRUE)) {
    return("NPI is a well-known composite prognostic score, so strong effects are clinically plausible.")
  }
  if (grepl("ER", var_name, ignore.case = TRUE)) {
    return("ER status is biologically and therapeutically important because it can guide endocrine treatment strategy.")
  }
  if (grepl("HER2", var_name, ignore.case = TRUE)) {
    return("HER2-related biology can reflect tumour aggressiveness and treatment selection.")
  }
  if (grepl("CHEMO", var_name, ignore.case = TRUE)) {
    return("Chemotherapy effects in observational data can reflect confounding by indication because higher-risk patients are often more likely to receive it.")
  }
  if (grepl("HORMONE", var_name, ignore.case = TRUE)) {
    return("Hormone therapy often tracks endocrine-responsive disease and treatment allocation rather than pure causal effect.")
  }
  if (grepl("RADIO", var_name, ignore.case = TRUE)) {
    return("Radiotherapy is clinically important for local-regional control, but observed associations may also reflect baseline disease severity.")
  }
  if (grepl("CELLULARITY", var_name, ignore.case = TRUE)) {
    return("Cellularity may capture specimen composition and underlying tumour biology.")
  }
  "This variable may carry prognostic information, but interpretation should remain tied to both biology and study design."
}


# Data loading
 
os_data <- safe_factorize(safe_read_csv("clean/os_data.csv"))
rfs_data <- safe_factorize(safe_read_csv("clean/rfs_data.csv"))

cox_ph <- safe_read_csv("results/tables/cox_ph_assumption.csv")
strat_ph <- safe_read_csv("results/tables/stratified_cox_ph_test.csv")
model_comp <- safe_read_csv("results/tables/model_comparison.csv")
penalized_coef <- safe_read_csv("results/tables/penalized_cox_coefficients.csv")
rsf_perf <- normalize_rsf_perf(safe_read_csv("results/tables/random_forest_performance.csv"))
rsf_vimp <- normalize_rsf_vimp(safe_read_csv("results/tables/random_forest_variable_importance.csv"))

available_os <- !is.null(os_data)
available_rfs <- !is.null(rfs_data)

base_data <- if (available_os) os_data else rfs_data

if (is.null(base_data)) {
  stop("No cleaned dataset found. Expected clean/os_data.csv and/or clean/rfs_data.csv")
}

default_endpoint <- if (available_os) "OS" else "RFS"

age_rng <- range(base_data$AGE_AT_DIAGNOSIS, na.rm = TRUE)
npi_rng <- range(base_data$NPI, na.rm = TRUE)
ln_rng <- range(base_data$LYMPH_NODES_EXAMINED_POSITIVE, na.rm = TRUE)


# UI

ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(
    title = "Breast Cancer Survival Dashboard"
  ),

  dashboardSidebar(
    width = 320,

    sidebarMenu(
      id = "tabs",
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Variable Definitions", tabName = "dictionary", icon = icon("book")),
      menuItem("Methods", tabName = "methods", icon = icon("flask")),
      menuItem("Kaplan-Meier", tabName = "km", icon = icon("line-chart")),
      menuItem("Adjusted Cox Model", tabName = "cox", icon = icon("table")),
      menuItem("PH Diagnostics", tabName = "ph", icon = icon("heartbeat")),
      menuItem("Model Evaluation", tabName = "compare", icon = icon("balance-scale")),
      menuItem("Penalized Cox", tabName = "lasso", icon = icon("sliders")),
      menuItem("Machine Learning Model", tabName = "rsf", icon = icon("sitemap")),
      menuItem("Calibration", tabName = "calibration", icon = icon("bullseye")),
      menuItem("Data Explorer", tabName = "data", icon = icon("database"))
    ),

    hr(),

    selectInput(
      "endpoint",
      "Endpoint",
      choices = c("OS", "RFS"),
      selected = default_endpoint
    ),

    selectInput(
      "group_var",
      "Grouping variable",
      choices = c("ER_IHC", "HORMONE_THERAPY", "CHEMOTHERAPY", "RADIO_THERAPY", "HER2_SNP6", "CELLULARITY"),
      selected = "ER_IHC"
    ),

    selectInput(
      "color_var",
      "Color variable",
      choices = c("ER_IHC", "HORMONE_THERAPY", "CHEMOTHERAPY", "RADIO_THERAPY", "HER2_SNP6", "CELLULARITY"),
      selected = "ER_IHC"
    ),

    sliderInput(
      "age_range",
      "Age at diagnosis",
      min = floor(age_rng[1]),
      max = ceiling(age_rng[2]),
      value = c(floor(age_rng[1]), ceiling(age_rng[2]))
    ),

    sliderInput(
      "npi_range",
      "NPI",
      min = floor(npi_rng[1]),
      max = ceiling(npi_rng[2]),
      value = c(floor(npi_rng[1]), ceiling(npi_rng[2])),
      step = 0.1
    ),

    sliderInput(
      "ln_range",
      "Positive lymph nodes",
      min = floor(ln_rng[1]),
      max = ceiling(ln_rng[2]),
      value = c(floor(ln_rng[1]), ceiling(ln_rng[2]))
    ),

    checkboxInput(
      "complete_case",
      "Use complete cases",
      TRUE
    ),

    checkboxGroupInput(
      "treatment_filters",
      "Restrict to treatment = YES",
      choices = c("CHEMOTHERAPY", "HORMONE_THERAPY", "RADIO_THERAPY"),
      selected = character(0)
    ),

    conditionalPanel(
      condition = "input.tabs == 'km'",
      checkboxInput("show_risktable", "Show risk table", TRUE),
      checkboxInput("show_ci", "Show confidence intervals", TRUE)
    ),

    hr(),

    actionButton("refresh_calibration", "Refresh calibration image", icon = icon("refresh")),
    br(), br(),
    downloadButton("download_filtered_data", "Download filtered data"),
    br(), br(),
    downloadButton("download_cox_results", "Download Cox results")
  ),

  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side { background-color: #f4f6f9; }
        .small-box h3 { font-size: 28px; }
        .box { border-radius: 10px; }
        .section-note { font-size: 13px; color: #555; margin-top: 6px; }
        .title-card {
          background: linear-gradient(135deg, #1f4e79, #2c7fb8);
          color: white;
          padding: 24px;
          border-radius: 12px;
          margin-bottom: 20px;
          box-shadow: 0 4px 10px rgba(0,0,0,0.08);
        }
        .title-card h2 {
          margin-top: 0;
          font-weight: 700;
        }
        .title-card p {
          margin-bottom: 0;
          font-size: 15px;
          opacity: 0.95;
        }
        .app-footer {
          text-align: center;
          padding: 14px;
          color: #444;
          font-size: 14px;
          border-top: 1px solid #ddd;
          margin-top: 20px;
          background: #fff;
        }
        .app-footer a {
          color: #2c7be5;
          text-decoration: none;
          font-weight: 600;
        }
        .app-footer a:hover {
          text-decoration: underline;
        }
        .method-box, .interpret-box {
          background: white;
          border-radius: 10px;
          padding: 18px;
          margin-bottom: 15px;
          box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }
        .empty-panel {
          padding: 30px;
          text-align: center;
          color: #666;
          font-size: 15px;
        }
        .clinical-note {
          background: #fffdf2;
          border-left: 4px solid #f0ad4e;
          padding: 12px 14px;
          border-radius: 6px;
          margin-top: 10px;
        }
      "))
    ),

    tabItems(
      tabItem(
        tabName = "overview",
        fluidRow(
          box(
            width = 12,
            class = "title-card",
            title = NULL,
            solidHeader = FALSE,
            status = NULL,
            h2("Breast Cancer Survival Analysis Dashboard"),
            p("Interactive exploration of survival outcomes, prognostic variables, Kaplan-Meier estimation, adjusted Cox modeling, proportional hazards diagnostics, penalized survival regression, random survival forests, and calibration of survival predictions.")
          )
        ),
        fluidRow(
          valueBoxOutput("n_patients", width = 3),
          valueBoxOutput("n_events", width = 3),
          valueBoxOutput("event_rate", width = 3),
          valueBoxOutput("median_followup", width = 3)
        ),
        fluidRow(
          file_status_box("OS dataset", available_os, "clean/os_data.csv"),
          file_status_box("RFS dataset", available_rfs, "clean/rfs_data.csv"),
          file_status_box(
            "RSF outputs",
            !is.null(rsf_perf) && !is.null(rsf_vimp),
            "results/tables/rsf_performance.csv and rsf_variable_importance.csv"
          )
        ),
        fluidRow(
          box(
            width = 6, title = "Event profile", status = "primary", solidHeader = TRUE,
            withSpinner(plotlyOutput("event_bar", height = 300))
          ),
          box(
            width = 6, title = "Age distribution", status = "primary", solidHeader = TRUE,
            withSpinner(plotlyOutput("age_hist", height = 300))
          )
        ),
        fluidRow(
          box(
            width = 6, title = "NPI vs lymph node burden", status = "info", solidHeader = TRUE,
            withSpinner(plotlyOutput("scatter_plot", height = 320))
          ),
          box(
            width = 6, title = "Clinical summary", status = "info", solidHeader = TRUE,
            DTOutput("summary_table"),
            div(
              class = "section-note",
              "These summaries reflect the actively filtered cohort and should be interpreted as cohort-level context rather than causal evidence."
            )
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Clinical and statistical framing", status = "warning", solidHeader = TRUE,
            htmlOutput("overview_notes")
          )
        )
      ),

      tabItem(
        tabName = "dictionary",
        fluidRow(
          box(
            width = 12, title = "Variable definitions and clinical relevance", status = "primary", solidHeader = TRUE,
            p("This section defines the main variables used throughout the dashboard and explains why they matter clinically."),
            DTOutput("variable_dictionary_table")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Variable Interpretation", status = "info", solidHeader = TRUE,
            htmlOutput("variable_notes")
          )
        )
      ),

      tabItem(
        tabName = "methods",
        fluidRow(
          box(
            width = 12, title = "Project methods", status = "primary", solidHeader = TRUE,
            div(class = "method-box",
                h4("1. Data preparation"),
                p("Clinical records were transformed into survival-ready datasets by defining follow-up time and event indicators for overall survival (OS) and relapse-free survival (RFS). Survival modeling requires clear definition of event occurrence, censoring, and clinically interpretable covariates. Observations with missing values in required fields may be excluded under complete-case analysis.")
            ),
            div(class = "method-box",
                h4("2. Kaplan-Meier estimation"),
                p("Kaplan-Meier estimators provide non-parametric estimates of survival probability over time while accounting for right censoring. They are useful for initial descriptive understanding of time-to-event patterns in different subgroups.")
            ),
            div(class = "method-box",
                h4("3. Log-rank testing"),
                p("The log-rank test compares survival curves between groups. It is useful for unadjusted group comparisons but should not be interpreted as establishing causality, especially in observational clinical data.")
            ),
            div(class = "method-box",
                h4("4. Multivariable Cox proportional hazards modeling"),
                p("Cox models estimate adjusted hazard ratios to quantify the association between each covariate and the instantaneous event rate, holding other variables constant. This allows more clinically meaningful interpretation than unadjusted subgroup comparisons.")
            ),
            div(class = "method-box",
                h4("5. Proportional hazards diagnostics"),
                p("Schoenfeld residual-based diagnostics assess whether each hazard ratio remains approximately constant over time. Violations suggest that a fixed-effect Cox model may be too simplistic.")
            ),
            div(class = "method-box",
                h4("6. Penalized and machine learning survival models"),
                p("LASSO-penalized Cox models identify variables that remain important after coefficient shrinkage. Random Survival Forests provide a flexible benchmark capable of modeling non-linear relationships and interactions without assuming proportional hazards.")
            ),
            div(class = "method-box",
                h4("7. Model evaluation"),
                p("Discrimination is summarized using the concordance index, which measures how well a model ranks patients by risk. Calibration evaluates whether predicted survival probabilities agree with observed outcomes. A strong clinical model should ideally demonstrate both.")
            )
          )
        )
      ),

      tabItem(
        tabName = "km",
        fluidRow(
          box(
            width = 12, title = "Kaplan-Meier survival curves", status = "primary", solidHeader = TRUE,
            withSpinner(plotOutput("km_plot", height = 620))
          )
        ),
        fluidRow(
          box(
            width = 6, title = "Log-rank test", status = "warning", solidHeader = TRUE,
            verbatimTextOutput("logrank_text")
          ),
          box(
            width = 6, title = "Group counts", status = "warning", solidHeader = TRUE,
            DTOutput("group_count_table")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Detailed interpretation", status = "info", solidHeader = TRUE,
            htmlOutput("km_notes")
          )
        )
      ),

      tabItem(
        tabName = "cox",
        fluidRow(
          box(
            width = 12, title = "Adjusted multivariable Cox model", status = "primary", solidHeader = TRUE,
            DTOutput("cox_table")
          )
        ),
        fluidRow(
          box(
            width = 7, title = "Hazard ratio forest plot", status = "info", solidHeader = TRUE,
            withSpinner(plotlyOutput("cox_forest", height = 500))
          ),
          box(
            width = 5, title = "Detailed model interpretation", status = "info", solidHeader = TRUE,
            htmlOutput("cox_notes")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Clinical interpretation of significant predictors", status = "warning", solidHeader = TRUE,
            htmlOutput("cox_clinical_interpretation")
          )
        )
      ),

      tabItem(
        tabName = "ph",
        fluidRow(
          box(
            width = 6, title = "Baseline Cox PH test", status = "danger", solidHeader = TRUE,
            DTOutput("ph_table")
          ),
          box(
            width = 6, title = "Stratified Cox PH test", status = "danger", solidHeader = TRUE,
            DTOutput("ph_strat_table")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Diagnostics interpretation", status = "warning", solidHeader = TRUE,
            htmlOutput("ph_interpretation")
          )
        )
      ),

      tabItem(
        tabName = "compare",
        fluidRow(
          box(
            width = 6, title = "Model comparison", status = "primary", solidHeader = TRUE,
            DTOutput("comparison_table")
          ),
          box(
            width = 6, title = "C-index comparison", status = "primary", solidHeader = TRUE,
            withSpinner(plotlyOutput("comparison_plot", height = 320))
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Interpretation", status = "info", solidHeader = TRUE,
            htmlOutput("comparison_notes")
          )
        )
      ),

      tabItem(
        tabName = "lasso",
        fluidRow(
          box(
            width = 12, title = "Retained variables from penalized Cox model", status = "primary", solidHeader = TRUE,
            DTOutput("lasso_table")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Coefficient magnitude", status = "info", solidHeader = TRUE,
            withSpinner(plotlyOutput("lasso_plot", height = 420))
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Detailed interpretation", status = "info", solidHeader = TRUE,
            htmlOutput("lasso_notes")
          )
        )
      ),

      tabItem(
        tabName = "rsf",
        fluidRow(
          valueBoxOutput("rsf_cindex_box", width = 4),
          valueBoxOutput("best_model_box", width = 4),
          valueBoxOutput("top_rsf_variable_box", width = 4)
        ),
        fluidRow(
          box(
            width = 5, title = "RSF performance", status = "primary", solidHeader = TRUE,
            uiOutput("rsf_perf_ui")
          ),
          box(
            width = 7, title = "Variable importance", status = "primary", solidHeader = TRUE,
            uiOutput("rsf_plot_ui")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Detailed interpretation", status = "info", solidHeader = TRUE,
            htmlOutput("rsf_notes")
          )
        )
      ),

      tabItem(
        tabName = "calibration",
        fluidRow(
          box(
            width = 12, title = "Calibration analysis", status = "primary", solidHeader = TRUE,
            uiOutput("calibration_ui")
          )
        ),
        fluidRow(
          box(
            width = 12, title = "Interpretation", status = "warning", solidHeader = TRUE,
            htmlOutput("calibration_notes")
          )
        )
      ),

      tabItem(
        tabName = "data",
        fluidRow(
          box(
            width = 6, title = "Filtered data preview", status = "success", solidHeader = TRUE,
            DTOutput("data_table")
          ),
          box(
            width = 6, title = "Distributions by selected variable", status = "success", solidHeader = TRUE,
            withSpinner(plotlyOutput("explorer_plot", height = 420))
          )
        )
      )
    ),

    tags$footer(
      class = "app-footer",
      HTML('Developed by <b>Rahul</b> | <a href="https://github.com/rahulbalwan" target="_blank">GitHub</a>')
    )
  )
)

# =========================
# Server
# =========================
server <- function(input, output, session) {

  addResourcePath("figures", "results/figures")

  observe({
    if (!available_rfs) {
      updateSelectInput(session, "endpoint", selected = "OS", choices = "OS")
    }
  })

  calibration_refresh <- reactiveVal(as.integer(Sys.time()))

  observeEvent(input$refresh_calibration, {
    calibration_refresh(as.integer(Sys.time()))
  })

  filtered_data <- reactive({
    dat <- get_dataset(input$endpoint, os_data, rfs_data)
    req(!is.null(dat))

    dat <- dat %>%
      filter(
        AGE_AT_DIAGNOSIS >= input$age_range[1],
        AGE_AT_DIAGNOSIS <= input$age_range[2],
        NPI >= input$npi_range[1],
        NPI <= input$npi_range[2],
        LYMPH_NODES_EXAMINED_POSITIVE >= input$ln_range[1],
        LYMPH_NODES_EXAMINED_POSITIVE <= input$ln_range[2]
      )

    for (trt in input$treatment_filters) {
      if (trt %in% names(dat)) {
        dat <- dat %>% filter(as.character(.data[[trt]]) == "YES")
      }
    }

    dat
  })

  analysis_data <- reactive({
    dat <- filtered_data()

    if (!isTRUE(input$complete_case)) return(dat)

    need_cols <- unique(c(
      get_time_var(input$endpoint),
      get_event_var(input$endpoint),
      "AGE_AT_DIAGNOSIS",
      "LYMPH_NODES_EXAMINED_POSITIVE",
      "NPI",
      input$group_var,
      input$color_var,
      "ER_IHC",
      "HORMONE_THERAPY",
      "CHEMOTHERAPY",
      "RADIO_THERAPY",
      "HER2_SNP6",
      "CELLULARITY"
    ))

    need_cols <- intersect(need_cols, names(dat))
    dat %>% drop_na(all_of(need_cols))
  })

  cox_results_reactive <- reactive({
    dat <- analysis_data() %>%
      select(any_of(c(
        get_time_var(input$endpoint),
        get_event_var(input$endpoint),
        "AGE_AT_DIAGNOSIS",
        "LYMPH_NODES_EXAMINED_POSITIVE",
        "NPI",
        "ER_IHC",
        "HORMONE_THERAPY",
        "CHEMOTHERAPY",
        "RADIO_THERAPY",
        "HER2_SNP6",
        "CELLULARITY"
      ))) %>%
      na.omit()

    req(nrow(dat) > 20)

    form <- as.formula(
      paste0(
        "Surv(",
        get_time_var(input$endpoint),
        ", ",
        get_event_var(input$endpoint),
        ") ~ AGE_AT_DIAGNOSIS + LYMPH_NODES_EXAMINED_POSITIVE + NPI + ER_IHC + HORMONE_THERAPY + CHEMOTHERAPY + RADIO_THERAPY + HER2_SNP6 + CELLULARITY"
      )
    )

    fit <- coxph(form, data = dat)
    s <- summary(fit)

    tibble(
      Variable = rownames(s$coefficients),
      HR = s$conf.int[, "exp(coef)"],
      Lower_95_CI = s$conf.int[, "lower .95"],
      Upper_95_CI = s$conf.int[, "upper .95"],
      P_value = s$coefficients[, "Pr(>|z|)"],
      Z = s$coefficients[, "z"]
    )
  })

  output$n_patients <- renderValueBox({
    valueBox(
      format(nrow(analysis_data()), big.mark = ","),
      "Filtered patients",
      icon = icon("users"),
      color = "aqua"
    )
  })

  output$n_events <- renderValueBox({
    dat <- analysis_data()
    ev <- sum(dat[[get_event_var(input$endpoint)]], na.rm = TRUE)

    valueBox(
      format(ev, big.mark = ","),
      "Observed events",
      icon = icon("heartbeat"),
      color = "red"
    )
  })

  output$event_rate <- renderValueBox({
    dat <- analysis_data()
    rate <- mean(dat[[get_event_var(input$endpoint)]], na.rm = TRUE)

    valueBox(
      percent(rate, accuracy = 0.1),
      "Event proportion",
      icon = icon("percent"),
      color = "yellow"
    )
  })

  output$median_followup <- renderValueBox({
    dat <- analysis_data()
    med <- median(dat[[get_time_var(input$endpoint)]], na.rm = TRUE)

    valueBox(
      round(med, 1),
      paste(input$endpoint, "median time (months)"),
      icon = icon("clock-o"),
      color = "green"
    )
  })

  output$event_bar <- renderPlotly({
    dat <- analysis_data() %>% count(.data[[get_event_var(input$endpoint)]])
    names(dat) <- c("Event", "Count")
    dat$Event <- ifelse(dat$Event == 1, "Event", "Censored")

    p <- ggplot(dat, aes(x = Event, y = Count, text = paste("Count:", Count))) +
      geom_col() +
      theme_minimal(base_size = 13) +
      labs(
        x = NULL,
        y = "Patients",
        title = paste("Distribution of", get_endpoint_label(input$endpoint), "events")
      )

    ggplotly(p, tooltip = "text")
  })

  output$age_hist <- renderPlotly({
    p <- ggplot(analysis_data(), aes(x = AGE_AT_DIAGNOSIS)) +
      geom_histogram(bins = 30) +
      theme_minimal(base_size = 13) +
      labs(
        x = "Age at diagnosis",
        y = "Count",
        title = "Age distribution in filtered cohort"
      )

    ggplotly(p)
  })

  output$scatter_plot <- renderPlotly({
    dat <- analysis_data()
    req(nrow(dat) > 1)

    p <- ggplot(
      dat,
      aes(
        x = NPI,
        y = LYMPH_NODES_EXAMINED_POSITIVE,
        color = .data[[input$color_var]],
        text = paste0(
          safe_label(input$color_var), ": ", .data[[input$color_var]],
          "<br>NPI: ", round(NPI, 2),
          "<br>Positive lymph nodes: ", LYMPH_NODES_EXAMINED_POSITIVE
        )
      )
    ) +
      geom_point(alpha = 0.7) +
      theme_minimal(base_size = 13) +
      labs(
        x = "Nottingham Prognostic Index (NPI)",
        y = "Positive lymph nodes",
        color = safe_label(input$color_var)
      )

    ggplotly(p, tooltip = "text")
  })

  output$summary_table <- renderDT({
    dat <- filtered_data()

    numeric_vars <- intersect(
      c("AGE_AT_DIAGNOSIS", "NPI", "LYMPH_NODES_EXAMINED_POSITIVE", get_time_var(input$endpoint)),
      names(dat)
    )

    out <- bind_rows(lapply(numeric_vars, function(v) {
      x <- dat[[v]]
      tibble(
        Variable = v,
        Mean = round(mean(x, na.rm = TRUE), 2),
        Median = round(median(x, na.rm = TRUE), 2),
        SD = round(sd(x, na.rm = TRUE), 2),
        Missing = sum(is.na(x))
      )
    }))

    datatable(out, options = list(dom = "t", paging = FALSE, scrollX = TRUE))
  })

  output$overview_notes <- renderUI({
    ep <- get_endpoint_label(input$endpoint)
    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Endpoint currently selected:</b> ", ep, ".</p>",
      "<p><b>Clinical framing:</b> breast cancer prognosis is often shaped by a combination of host factors, tumour burden, nodal spread, and biology. In this dashboard, age, lymph node burden, receptor status, treatment exposure, and the Nottingham Prognostic Index are used to understand both outcome patterns and adjusted risk.</p>",
      "<p><b>Statistical framing:</b> the dashboard progresses from descriptive estimation to adjusted multivariable modeling, assumption checking, model refinement, and predictive benchmarking. Each method answers a slightly different question.</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> repeated prominence of age, nodal burden, or NPI across multiple methods usually suggests that disease severity is a dominant driver of prognosis in the cohort.</div>",
      "</div>"
    ))
  })

  output$variable_dictionary_table <- renderDT({
    datatable(
      variable_dictionary,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })

  output$variable_notes <- renderUI({
    HTML(
      "<div class='interpret-box'>
        <p><b>How to read these variables:</b> some variables describe outcomes, some describe baseline disease severity, some reflect tumour biology, and some represent treatment exposure.</p>
        <p><b>Disease severity variables:</b> NPI and positive lymph nodes are especially important because they summarize how advanced the cancer may be at baseline.</p>
        <p><b>Biology variables:</b> ER and HER2-related markers often matter because they influence both prognosis and therapeutic decision-making.</p>
        <p><b>Treatment variables:</b> chemotherapy, hormone therapy, and radiotherapy are clinically meaningful, but their estimated effects in observational data may not be causal because sicker patients may be selected for more intensive treatment.</p>
      </div>"
    )
  })

  output$km_plot <- renderPlot({
    dat <- analysis_data()
    req(nrow(dat) > 3)
    req(input$group_var %in% names(dat))

    time_var <- get_time_var(input$endpoint)
    event_var <- get_event_var(input$endpoint)

    dat <- dat %>%
      mutate(
        .time = .data[[time_var]],
        .event = .data[[event_var]],
        .group = as.factor(.data[[input$group_var]])
      ) %>%
      filter(!is.na(.time), !is.na(.event), !is.na(.group))

    req(nrow(dat) > 3)

    fit <- survfit(Surv(.time, .event) ~ .group, data = dat)

    g <- ggsurvplot(
      fit,
      data = dat,
      risk.table = isTRUE(input$show_risktable),
      conf.int = isTRUE(input$show_ci),
      pval = TRUE,
      ggtheme = theme_minimal(base_size = 13),
      title = paste(get_endpoint_label(input$endpoint), "by", safe_label(input$group_var)),
      xlab = "Time (months)",
      ylab = "Survival probability",
      legend.title = safe_label(input$group_var),
      legend.labs = levels(dat$.group)
    )

    if (isTRUE(input$show_risktable)) {
      print(g)
    } else {
      print(g$plot)
    }
  })

  output$logrank_text <- renderPrint({
    dat <- analysis_data()
    req(nrow(dat) > 3)
    req(input$group_var %in% names(dat))

    time_var <- get_time_var(input$endpoint)
    event_var <- get_event_var(input$endpoint)

    dat <- dat %>%
      mutate(
        .time = .data[[time_var]],
        .event = .data[[event_var]],
        .group = as.factor(.data[[input$group_var]])
      ) %>%
      filter(!is.na(.time), !is.na(.event), !is.na(.group))

    req(nrow(dat) > 3)

    lr <- survdiff(Surv(.time, .event) ~ .group, data = dat)
    p <- 1 - pchisq(lr$chisq, df = length(lr$n) - 1)

    cat("Log-rank comparison for", input$group_var, "on", input$endpoint, "\n\n")
    print(lr)
    cat("\nDerived p-value:", signif(p, 4), "\n")

    if (p < 0.05) {
      cat("Interpretation: there is statistical evidence that the survival distributions differ across the selected groups.\n")
    } else {
      cat("Interpretation: there is no strong statistical evidence of a survival difference across the selected groups.\n")
    }
  })

  output$group_count_table <- renderDT({
    dat <- analysis_data()
    req(input$group_var %in% names(dat))

    dat <- dat %>%
      mutate(.group = as.factor(.data[[input$group_var]])) %>%
      filter(!is.na(.group)) %>%
      count(.group, name = "n")

    names(dat)[1] <- "Group"

    datatable(dat, options = list(dom = "t", paging = FALSE, scrollX = TRUE))
  })

  output$km_notes <- renderUI({
    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Statistical interpretation:</b> Kaplan-Meier curves estimate survival probability over time while accounting for censoring. The log-rank test assesses whether the entire survival experience differs between groups, but it does not adjust for confounding.</p>",
      "<p><b>Clinical interpretation:</b> if one group shows earlier or steeper decline, that group may have a worse prognosis or more aggressive disease profile. However, observed differences may also reflect differences in case mix, biology, or treatment selection.</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> in breast cancer, visible separation by receptor status or treatment groups may highlight clinically distinct risk trajectories, but adjusted models are needed before drawing stronger conclusions.</div>",
      "</div>"
    ))
  })

  output$cox_table <- renderDT({
    datatable(
      cox_results_reactive() %>% mutate(across(where(is.numeric), ~ round(.x, 4))),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$cox_forest <- renderPlotly({
    tab <- cox_results_reactive() %>% arrange(HR)

    p <- ggplot(
      tab,
      aes(
        x = reorder(Variable, HR),
        y = HR,
        ymin = Lower_95_CI,
        ymax = Upper_95_CI,
        text = paste0(
          "Variable: ", Variable,
          "<br>HR: ", round(HR, 3),
          "<br>95% CI: ", round(Lower_95_CI, 3), " - ", round(Upper_95_CI, 3),
          "<br>p: ", signif(P_value, 3)
        )
      )
    ) +
      geom_pointrange() +
      geom_hline(yintercept = 1, linetype = 2) +
      coord_flip() +
      theme_minimal(base_size = 13) +
      labs(x = NULL, y = "Hazard ratio")

    ggplotly(p, tooltip = "text")
  })

  output$cox_notes <- renderUI({
    tab <- cox_results_reactive()
    sig_tab <- tab %>% filter(P_value < 0.05)
    risky <- sig_tab %>% filter(HR > 1)
    protective <- sig_tab %>% filter(HR < 1)

    top_risk <- if (nrow(risky) > 0) risky$Variable[which.max(risky$HR)] else "None"
    top_protective <- if (nrow(protective) > 0) protective$Variable[which.min(protective$HR)] else "None"

    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Purpose of this model:</b> the multivariable Cox model estimates adjusted hazard ratios, allowing the association of each predictor with outcome to be interpreted while accounting for the others.</p>",
      "<p><b>Significant predictors:</b> ", nrow(sig_tab), ".</p>",
      "<p><b>Largest adjusted risk signal:</b> ", safe_meaningful_name(top_risk), ".</p>",
      "<p><b>Strongest protective signal:</b> ", safe_meaningful_name(top_protective), ".</p>",
      "<p><b>Statistical interpretation:</b> hazard ratios above 1 indicate increased instantaneous event risk; hazard ratios below 1 indicate reduced risk relative to the reference level or per-unit increase.</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> strong adjusted effects for age, NPI, or lymph node burden usually reinforce the idea that baseline disease severity remains central to prognosis even after accounting for tumour biology and treatment exposure.</div>",
      "</div>"
    ))
  })

  output$cox_clinical_interpretation <- renderUI({
    tab <- cox_results_reactive() %>%
      arrange(P_value, desc(abs(log(HR)))) %>%
      filter(P_value < 0.05)

    if (nrow(tab) == 0) {
      return(HTML(
        "<div class='interpret-box'>
          <p>No statistically significant predictors were identified at the conventional 0.05 threshold in the current filtered analysis.</p>
          <p>This may reflect limited sample size, filtering choices, collinearity, weak effects, or endpoint-specific differences.</p>
        </div>"
      ))
    }

    items <- lapply(seq_len(min(nrow(tab), 6)), function(i) {
      row <- tab[i, ]
      paste0(
        "<li><b>", safe_meaningful_name(row$Variable), ":</b> HR = ", round(row$HR, 3),
        " (95% CI ", round(row$Lower_95_CI, 3), " to ", round(row$Upper_95_CI, 3), "), p = ", fmt_p(row$P_value), ". ",
        interpret_hr(row$HR), " ",
        interpret_var_clinical(row$Variable),
        "</li>"
      )
    })

    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Most important significant predictors in the current model:</b></p>",
      "<ul>", paste(items, collapse = ""), "</ul>",
      "<p><b>Interpretive caution:</b> treatment-related coefficients should not automatically be read as treatment efficacy estimates in observational data because allocation is not randomized.</p>",
      "</div>"
    ))
  })

  output$ph_table <- renderDT({
    validate(need(!is.null(cox_ph), "cox_ph_assumption.csv not found."))
    datatable(
      cox_ph %>% mutate(across(where(is.numeric), ~ round(.x, 4))),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$ph_strat_table <- renderDT({
    validate(need(!is.null(strat_ph), "stratified_cox_ph_test.csv not found."))
    datatable(
      strat_ph %>% mutate(across(where(is.numeric), ~ round(.x, 4))),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$ph_interpretation <- renderUI({
    global_p <- NA
    strat_global_p <- NA

    if (!is.null(cox_ph) && "variable" %in% names(cox_ph)) {
      row <- cox_ph %>% filter(variable == "GLOBAL")
      if (nrow(row) == 1 && "p_value" %in% names(row)) global_p <- row$p_value
    }

    if (!is.null(strat_ph) && "variable" %in% names(strat_ph)) {
      row2 <- strat_ph %>% filter(variable == "GLOBAL")
      if (nrow(row2) == 1 && "p_value" %in% names(row2)) strat_global_p <- row2$p_value
    }

    baseline_msg <- if (!is.na(global_p) && global_p < 0.05) {
      "The baseline Cox model shows evidence against the proportional hazards assumption."
    } else {
      "The baseline Cox model does not show strong global evidence of non-proportional hazards."
    }

    strat_msg <- if (!is.na(strat_global_p) && strat_global_p < 0.05) {
      "The stratified Cox model improves validity, but residual non-proportionality remains."
    } else {
      "The stratified Cox model appears to resolve most global proportional hazards concerns."
    }

    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Why this matters:</b> the Cox model assumes that hazard ratios stay roughly constant over follow-up time. If that assumption fails, a single fixed hazard ratio can oversimplify the clinical story.</p>",
      "<p><b>Baseline global PH p-value:</b> ", ifelse(is.na(global_p), "Not available", fmt_p(global_p)), "</p>",
      "<p><b>Stratified global PH p-value:</b> ", ifelse(is.na(strat_global_p), "Not available", fmt_p(strat_global_p)), "</p>",
      "<p>", baseline_msg, "</p>",
      "<p>", strat_msg, "</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> non-proportional hazards may mean that the impact of a risk factor changes over time, which can be clinically important when early and late risk behave differently.</div>",
      "</div>"
    ))
  })

  output$comparison_table <- renderDT({
    validate(need(!is.null(model_comp), "model_comparison.csv not found."))
    datatable(
      model_comp %>% mutate(c_index = round(c_index, 4)),
      options = list(dom = "t", paging = FALSE, scrollX = TRUE)
    )
  })

  output$comparison_plot <- renderPlotly({
    validate(need(!is.null(model_comp), "model_comparison.csv not found."))

    p <- ggplot(
      model_comp,
      aes(
        x = reorder(model, c_index),
        y = c_index,
        text = paste0(model, "<br>C-index: ", round(c_index, 3))
      )
    ) +
      geom_col() +
      coord_flip() +
      theme_minimal(base_size = 13) +
      labs(x = NULL, y = "C-index")

    ggplotly(p, tooltip = "text")
  })

  output$comparison_notes <- renderUI({
    req(!is.null(model_comp))
    best <- model_comp %>% arrange(desc(c_index)) %>% slice(1)

    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Best-performing model:</b> ", best$model, " (C-index = ", round(best$c_index, 3), ").</p>",
      "<p><b>Interpretation of the C-index:</b> this metric reflects discrimination, meaning how well the model correctly ranks lower-risk versus higher-risk patients. Higher is better, but it does not assess calibration.</p>",
      "<p><b>Methodological significance:</b> performance gains may arise from better handling of time-varying effects, non-linearity, or variable shrinkage rather than complexity alone.</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> a model with stronger discrimination may be more useful for risk stratification, triage, or identifying patients who may warrant closer follow-up, provided calibration is also acceptable.</div>",
      "</div>"
    ))
  })

  output$lasso_table <- renderDT({
    validate(need(!is.null(penalized_coef), "penalized_cox_coefficients.csv not found."))
    datatable(
      penalized_coef %>% mutate(across(where(is.numeric), ~ round(.x, 4))),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$lasso_plot <- renderPlotly({
    validate(need(!is.null(penalized_coef), "penalized_cox_coefficients.csv not found."))
    tab <- penalized_coef %>% arrange(abs(coefficient))

    p <- ggplot(
      tab,
      aes(
        x = reorder(variable, abs(coefficient)),
        y = coefficient,
        text = paste0(variable, "<br>Coefficient: ", round(coefficient, 4))
      )
    ) +
      geom_col() +
      coord_flip() +
      theme_minimal(base_size = 13) +
      labs(x = NULL, y = "LASSO coefficient")

    ggplotly(p, tooltip = "text")
  })

  output$lasso_notes <- renderUI({
    req(!is.null(penalized_coef))
    top_vars <- paste(head(penalized_coef$variable, 5), collapse = ", ")

    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Purpose of LASSO:</b> LASSO-penalized Cox regression shrinks weaker coefficients toward zero and highlights variables that remain relevant under regularization.</p>",
      "<p><b>Top retained signals:</b> ", safe_meaningful_name(top_vars), ".</p>",
      "<p><b>Methodological meaning:</b> variables that survive penalization are often more stable and less likely to reflect model-specific noise.</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> if age, nodal burden, or NPI persist after penalization, this supports the idea that these factors are robust drivers of prognosis rather than artifacts of one particular model.</div>",
      "</div>"
    ))
  })

  output$rsf_cindex_box <- renderValueBox({
    if (is.null(rsf_perf) || !"c_index" %in% names(rsf_perf) || nrow(rsf_perf) == 0) {
      return(valueBox("NA", "RSF C-index", icon = icon("sitemap"), color = "light-blue"))
    }

    valueBox(
      round(rsf_perf$c_index[1], 3),
      "RSF C-index",
      icon = icon("sitemap"),
      color = "purple"
    )
  })

  output$best_model_box <- renderValueBox({
    if (is.null(model_comp) || nrow(model_comp) == 0) {
      return(valueBox("NA", "Best survival model", icon = icon("trophy"), color = "light-blue"))
    }

    best <- model_comp %>% arrange(desc(c_index)) %>% slice(1)

    valueBox(
      best$model,
      "Best survival model",
      icon = icon("trophy"),
      color = "olive"
    )
  })

  output$top_rsf_variable_box <- renderValueBox({
    if (is.null(rsf_vimp) || nrow(rsf_vimp) == 0) {
      return(valueBox("NA", "Top RSF variable", icon = icon("star"), color = "light-blue"))
    }

    top_var <- rsf_vimp %>% arrange(desc(importance)) %>% slice(1)

    valueBox(
      safe_value(top_var$variable, "NA"),
      "Top RSF variable",
      icon = icon("star"),
      color = "teal"
    )
  })

  output$rsf_perf_ui <- renderUI({
    if (is.null(rsf_perf) || nrow(rsf_perf) == 0) {
      div(
        class = "empty-panel",
        HTML("<b>RSF performance file is missing or malformed.</b><br>Expected: results/tables/rsf_performance.csv with a c_index column.")
      )
    } else {
      DTOutput("rsf_perf_table")
    }
  })

  output$rsf_perf_table <- renderDT({
    req(!is.null(rsf_perf), nrow(rsf_perf) > 0)
    datatable(
      rsf_perf %>% mutate(across(where(is.numeric), ~ round(.x, 4))),
      options = list(dom = "t", paging = FALSE, scrollX = TRUE)
    )
  })

  output$rsf_plot_ui <- renderUI({
    if (is.null(rsf_vimp) || nrow(rsf_vimp) == 0) {
      div(
        class = "empty-panel",
        HTML("<b>RSF variable importance file is missing or malformed.</b><br>Expected: results/tables/rsf_variable_importance.csv with variable and importance columns.")
      )
    } else {
      withSpinner(plotlyOutput("rsf_plot", height = 420))
    }
  })

  output$rsf_plot <- renderPlotly({
    req(!is.null(rsf_vimp), nrow(rsf_vimp) > 0)

    tab <- rsf_vimp %>% arrange(importance)

    p <- ggplot(
      tab,
      aes(
        x = reorder(variable, importance),
        y = importance,
        text = paste0(variable, "<br>Importance: ", round(importance, 4))
      )
    ) +
      geom_col() +
      coord_flip() +
      theme_minimal(base_size = 13) +
      labs(x = NULL, y = "Variable importance")

    ggplotly(p, tooltip = "text")
  })

  output$rsf_notes <- renderUI({
    if (is.null(rsf_vimp) || is.null(rsf_perf) || nrow(rsf_vimp) == 0 || nrow(rsf_perf) == 0) {
      return(HTML(
        "<div class='interpret-box'>
          <p><b>RSF interpretation unavailable.</b> The machine learning result files are missing, empty, or malformed.</p>
          <p>Check that <code>results/tables/rsf_performance.csv</code> contains <code>c_index</code> and <code>results/tables/rsf_variable_importance.csv</code> contains <code>variable</code> and <code>importance</code>.</p>
        </div>"
      ))
    }

    top3 <- rsf_vimp %>% arrange(desc(importance)) %>% slice_head(n = min(3, nrow(rsf_vimp)))
    top3_txt <- paste(top3$variable, collapse = ", ")
    rsf_c <- round(rsf_perf$c_index[1], 3)

    HTML(paste0(
      "<div class='interpret-box'>",
      "<p><b>Role of RSF:</b> the Random Survival Forest is a flexible non-parametric survival model that can capture non-linear effects and interactions without relying on proportional hazards.</p>",
      "<p><b>Top RSF predictors:</b> ", safe_meaningful_name(top3_txt), ".</p>",
      "<p><b>RSF discrimination:</b> C-index = ", rsf_c, ".</p>",
      "<p><b>Methodological interpretation:</b> if RSF meaningfully outperforms Cox-based models, that suggests the survival signal may involve non-linearity or interactions not well represented by simpler models.</p>",
      "<div class='clinical-note'><b>Clinical significance:</b> if the same core variables dominate both RSF and Cox models, then the prognostic structure of the dataset is likely stable and clinically coherent across modeling frameworks.</div>",
      "</div>"
    ))
  })

  output$calibration_ui <- renderUI({
    calibration_refresh()
    cal_path <- "results/figures/calibration_plot.png"

    if (file.exists(cal_path)) {
      tags$img(
        src = paste0("figures/calibration_plot.png?v=", calibration_refresh()),
        style = "width:100%; border-radius:8px;"
      )
    } else {
      div(
        class = "empty-panel",
        HTML("<b>Calibration plot not found.</b><br>Run your calibration script first and save the file to <code>results/figures/calibration_plot.png</code>.")
      )
    }
  })

  output$calibration_notes <- renderUI({
    HTML(
      "<div class='interpret-box'>
        <p><b>Interpretation:</b> this panel displays a calibration plot evaluating agreement between predicted and observed survival probability.</p>
        <p>A well-calibrated model should lie close to the 45-degree reference line. Deviation from that line indicates that predicted absolute risk or predicted survival probability does not perfectly match observed outcomes.</p>
        <p>If the curve lies below the diagonal, the model is overestimating survival probability and is optimistic in absolute prediction. If it lies above the diagonal, the model may be underestimating survival probability.</p>
        <p><b>Important lesson:</b> discrimination and calibration are different. A model may rank patients reasonably well while still providing inaccurate absolute probabilities.</p>
        <div class='clinical-note'><b>Clinical significance:</b> calibration matters whenever predicted probabilities may be used for patient counseling, clinical decision support, or risk communication.</div>
      </div>"
    )
  })

  output$data_table <- renderDT({
    datatable(
      filtered_data(),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$explorer_plot <- renderPlotly({
    dat <- filtered_data()
    req(nrow(dat) > 1)

    p <- ggplot(
      dat,
      aes(
        x = .data[[input$color_var]],
        y = .data[[get_time_var(input$endpoint)]],
        fill = .data[[input$color_var]]
      )
    ) +
      geom_boxplot(alpha = 0.7) +
      theme_minimal(base_size = 13) +
      labs(
        x = safe_label(input$color_var),
        y = paste(input$endpoint, "time (months)"),
        fill = safe_label(input$color_var)
      )

    ggplotly(p)
  })

  output$download_filtered_data <- downloadHandler(
    filename = function() {
      paste0("filtered_", tolower(input$endpoint), "_data.csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )

  output$download_cox_results <- downloadHandler(
    filename = function() {
      paste0("cox_results_", tolower(input$endpoint), ".csv")
    },
    content = function(file) {
      write.csv(cox_results_reactive(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)