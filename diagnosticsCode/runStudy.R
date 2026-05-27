# create logger ----
resultsFolder <- here("results")
if(!dir.exists(resultsFolder)){
  dir.create(resultsFolder)
}

createLogFile(logFile = tempfile(pattern = "log_{date}_{time}"))
logMessage("LOG CREATED")

# Define diagnostics settings ----
study_period <- c(as.Date("2019-04-19"), NA)
study_age_groups <- list(
  c(0, 0),
  c(1, 3),
  c(4, 12),
  c(13, 17)
)

# run ----
source(here("cohorts", "instantiateCohorts.R"))
info(logger, "- Running PhenotypeDiagnostics for study cohorts")
diagnostics_study <- phenotypeDiagnostics(
  cdm$study_cohorts,
  survival = FALSE,
  cohortSample = 20000,
  matchedSample = NULL,
  populationSample = NULL
)

exportSummarisedResult(
  diagnostics_study,
  minCellCount = minCellCount,
  fileName = "phenotyper_study_results_{cdm_name}_{date}.csv",
  path = resultsFolder
)

info(logger, "- Running PhenotypeDiagnostics for congenital aortic valve disease")
diagnostics_congenital_aortic_valve_disease <- phenotypeDiagnostics(
  cdm$congenital_aortic_valve_disease,
  survival = FALSE,
  cohortSample = 20000,
  matchedSample = NULL,
  populationSample = NULL
)

exportSummarisedResult(
  diagnostics_congenital_aortic_valve_disease,
  minCellCount = minCellCount,
  fileName = "phenotyper_congenital_aortic_valve_disease_results_{cdm_name}_{date}.csv",
  path = resultsFolder
)
logMessage("Finished")
