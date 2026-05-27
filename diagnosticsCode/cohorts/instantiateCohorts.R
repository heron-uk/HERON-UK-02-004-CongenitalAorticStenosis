index_codes <- CodelistGenerator::importCodelist(here::here("cohorts", "index_codelists"), "csv")
procedure_codes <- CodelistGenerator::importCodelist(here::here("cohorts", "procedure_codelists"), "csv")
comorbidity_codes <- CodelistGenerator::importCodelist(here::here("cohorts", "comorbidity_codelists"), "csv")

# Comorbidity cohorts -----
cdm$comorbidity_cohorts <- CohortConstructor::conceptCohort(
	cdm = cdm,
	name = "comorbidity_cohorts",
	conceptSet = comorbidity_codes,
	exit = "event_start_date"
) |>
	CohortConstructor::requireIsFirstEntry()

# Outcome cohorts ----
cdm$intervention_cohorts <- CohortConstructor::conceptCohort(
	cdm = cdm,
	name = "intervention_cohorts",
	conceptSet = procedure_codes,
	exit = "event_start_date",
	useSourceFields = TRUE
)

omopgenerics::logMessage("Creating death cohort")
cdm$death_cohort <- CohortConstructor::deathCohort(cdm, name = "death_cohort")

cdm <- bind(
	cdm$intervention_cohorts,
	cdm$death_cohort,
	name = "outcome_cohorts"
)

# Study cohorts reused from the main study -----
cdm$study_cohorts <- CohortConstructor::conceptCohort(
	cdm = cdm,
	name = "study_cohorts",
	conceptSet = index_codes,
	exit = "event_start_date"
) |>
	CohortConstructor::requireIsFirstEntry() |>
	CohortConstructor::exitAtObservationEnd() |>
	CohortConstructor::requireAge(ageRange = c(0, 17)) |>
	CohortConstructor::requireInDateRange(
		dateRange = study_period
	)

cdm$study_cohorts <- cdm$study_cohorts |>
	CohortConstructor::requireCohortIntersect(
		"outcome_cohorts",
		window = c(-Inf, 0),
		intersections = c(0, 0),
		cohortCombinationCriteria = "all"
	)

cdm$study_cohorts <- cdm$study_cohorts |>
	PatientProfiles::addDemographics(ageGroup = study_age_groups)

# Additional diagnostics cohort -----
congenital_aortic_valve_disease_codes <- list(
	congenital_aortic_valve_disease = unique(c(
		index_codes$aortic_stenosis_congenital,
		comorbidity_codes$aortic_insufficiency
	))
)

cdm$congenital_aortic_valve_disease <- CohortConstructor::conceptCohort(
	cdm = cdm,
	name = "congenital_aortic_valve_disease",
	conceptSet = congenital_aortic_valve_disease_codes,
	exit = "event_start_date"
) |>
	CohortConstructor::requireIsFirstEntry() |>
	CohortConstructor::exitAtObservationEnd() |>
	CohortConstructor::requireAge(ageRange = c(0, 17)) |>
	CohortConstructor::requireInDateRange(
		dateRange = study_period
	) |>
	PatientProfiles::addDemographics(ageGroup = study_age_groups)
