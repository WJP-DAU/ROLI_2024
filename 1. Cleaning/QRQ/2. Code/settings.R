## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Script:            Settings
##
## Author(s):         Santiago Pardo   (spardo@worldjusticeproject.org)
##                    
##
## Dependencies:      World Justice Project
##
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Outline:                                                                                                 ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 1.  Load Packages                                                                                      ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library(pacman)
p_load(char = c(
  # Load data
  "haven",
  # Visualizations
  "ggplot2",
  # Good 'ol Tidyverse
  "tidyverse"
))

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 2.  SharePoint Path                                                                                      ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if (Sys.info()["user"] == "santiagopardo") {
  
  path2EU <- paste0("/Users/santiagopardo/OneDrive - World Justice Project/EU Subnational")
  path2DA <- paste0("/Users/santiagopardo/OneDrive - World Justice Project/Data Analytics")
  
} else {
  "INSERT PATH"
}

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 3. Functions                                                                                      ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

### Helper: Load and pivot scenario files-----------------------------------------------------------------------

load_scenario <- function(file, value_name) {
  read_dta(file) %>%
    select(country, f_1:f_8, ROLI) %>%
    pivot_longer(cols = -country, names_to = "variables", values_to = value_name)
}

### Scenarios comparisson -----------------------------------------------------------------------


#' Compare two score scenarios and select the most appropriate based on direction, size, and alignment
#'
#' @param df Data frame containing all required variables
#' @param score_a Name of first scenario score column (string)
#' @param score_b Name of second scenario score column (string)
#' @param direction_benchmark Name of the column indicating benchmark direction ("Positive"/"Negative")
#' @param year_ref Name of the column with the previous year's score (used as baseline)
#' @param scenario_labels Character vector of length 2: labels to assign to scenario A and scenario B (e.g. c("Scenario 1", "Scenario 2"))
#' @param suffix Suffix to append to output column names (e.g. "stage1", "stage2")
#'
#' @return A data frame with added columns:
#'   - scenario_<suffix>
#'   - scores_<suffix>
#'   - scores_change_<suffix>
#'   - scores_direction_<suffix>
#'   - scores_big_change_<suffix>

compare_scenarios <- function(df, score_a, score_b, direction_benchmark, year_ref, scenario_labels, suffix) {
  # Convert column names (as strings) to symbols so they can be used programmatically in tidyverse
  score_a_sym <- sym(score_a)
  score_b_sym <- sym(score_b)
  direction_sym <- sym(direction_benchmark)
  year_ref_sym <- sym(year_ref)
  
  df %>%
    rowwise() %>%
    mutate(
      # Step 1: Compute score changes for each scenario relative to reference year
      change_a = !!score_a_sym - !!year_ref_sym,
      change_b = !!score_b_sym - !!year_ref_sym,
      
      # Step 2: Determine the direction of change
      direction_a = if_else(change_a > 0, "Positive", "Negative"),
      direction_b = if_else(change_b > 0, "Positive", "Negative"),
      
      # Step 3: Flag whether the change is "big" (absolute value > 0.05)
      big_change_a = if_else(abs(change_a) > 0.05, "Yes", "No"),
      big_change_b = if_else(abs(change_b) > 0.05, "Yes", "No"),
      
      # Step 4: Check whether each scenario aligns with the long-term benchmark direction
      match_a = if_else(direction_a == !!direction_sym, "Yes", "No", missing = "No data"),
      match_b = if_else(direction_b == !!direction_sym, "Yes", "No", missing = "No data"),
      
      # Step 5: Find which scenario has the smallest absolute change
      min_change = min(c(change_a, change_b), na.rm = TRUE),
      
      min_scenario  = 
        case_when(
          change_a    == change_b   ~ "a",                           # Equal changes → choose first by default
          min_change == change_a    ~ "a",                         # Smaller change in scenario A
          min_change == change_b    ~ "b",                         # Smaller change in scenario B
          is.na(!!year_ref_sym)     ~ "a",                          # Missing baseline → default to scenario A
          TRUE ~ "No data"                                      # Catch-all fallback
      ),
      
      # Step 6: Apply selection logic based on match with benchmark and change size
      !!paste0("scenario_", suffix) := 
        case_when(
          match_a == "Yes" & match_b == "No" ~ scenario_labels[1],    # Only A matches → choose A
          match_a == "No" & match_b == "Yes" ~ scenario_labels[2],    # Only B matches → choose B
          min_scenario == "a"                ~ scenario_labels[1],    # If both match/mismatch → choose smaller change
          min_scenario == "b"                ~ scenario_labels[2],
          TRUE ~ NA_character_
      ),
      
      # Step 7: Based on selected scenario, assign final score, change, direction, and big change flag
      !!paste0("scores_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == scenario_labels[1],
        !!score_a_sym,
        !!score_b_sym
      ),
      
      !!paste0("scores_change_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == scenario_labels[1],
        change_a,
        change_b
      ),
      
      !!paste0("scores_direction_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == scenario_labels[1],
        direction_a,
        direction_b
      ),
      
      !!paste0("scores_big_change_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == scenario_labels[1],
        big_change_a,
        big_change_b
      )
    ) %>%
    ungroup()
}

### Stages comparisson -----------------------------------------------------------------------

#' General function to compare two scores and select the best one based on direction and minimal change
#'
#' @param df Data frame containing the columns to compare
#' @param score_a, score_b Column names (as strings) for score values
#' @param change_a, change_b Column names (as strings) for score changes
#' @param direction_a, direction_b Column names (as strings) for directions of change
#' @param big_change_a, big_change_b Column names (as strings) for large-change flags
#' @param label_a, label_b Column names (as strings) for scenario labels
#' @param direction_benchmark Name of the column with the benchmark direction
#' @param suffix Suffix for final output columns (e.g. "final")
#'
#' @return Data frame with final selected scenario and associated metrics

compare_stages <- function(
    df,
    score_a, change_a, direction_a, big_change_a, label_a,
    score_b, change_b, direction_b, big_change_b, label_b,
    direction_benchmark,
    suffix
) {
  df %>%
    mutate(
      stage_a_match = if_else(.data[[direction_a]] == .data[[direction_benchmark]], "Yes", "No", missing = "No data"),
      stage_b_match = if_else(.data[[direction_b]] == .data[[direction_benchmark]], "Yes", "No", missing = "No data"),
      match_stage_a_b = if_else(.data[[score_a]] == .data[[score_b]], "Same", "Different", missing = "No data")
    ) %>%
    rowwise() %>%
    mutate(
      min_change = min(c(.data[[change_a]], .data[[change_b]]), na.rm = TRUE),
      
      min_scenario = case_when(
        .data[[change_a]] == .data[[change_b]] ~ "a",
        min_change == .data[[change_a]] ~ "a",
        min_change == .data[[change_b]] ~ "b",
        is.na(scores_2023) ~ "a",
        TRUE ~ "No data"
      ),
      
      !!paste0("scenario_", suffix) := case_when(
        stage_a_match == "Yes" & stage_b_match == "No" ~ .data[[label_a]],
        stage_a_match == "No" & stage_b_match == "Yes" ~ .data[[label_b]],
        min_scenario == "a" ~ .data[[label_a]],
        min_scenario == "b" ~ .data[[label_b]],
        TRUE ~ NA_character_
      ),
      
      !!paste0("scores_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == .data[[label_a]],
        .data[[score_a]],
        .data[[score_b]]
      ),
      
      !!paste0("scores_change_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == .data[[label_a]],
        .data[[change_a]],
        .data[[change_b]]
      ),
      
      !!paste0("scores_direction_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == .data[[label_a]],
        .data[[direction_a]],
        .data[[direction_b]]
      ),
      
      !!paste0("scores_big_change_", suffix) := if_else(
        !!sym(paste0("scenario_", suffix)) == .data[[label_a]],
        .data[[big_change_a]],
        .data[[big_change_b]]
      )
    ) %>%
    ungroup()
}

