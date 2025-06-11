## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## Script:            RunMe QRQ experts system
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
## 1.  Load sources                                                                                      ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Loading additional code module
modules <- c(
  "settings" 
)
for (mod in modules){
  source(
    paste0("2. Code/",mod,".R")
  )
}


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 2. Load QRQ scenarios and benchmarks                                                                                        ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

### Scenarios --------------------------------------------------------------------------------------------------

# Load all QRQ scenario data (s1-s4, p/n) following the flagging mechanism structure
# Scenarios: s1 = general outliers, s2 = discipline outliers, s3 = question-level outliers, s4 = sub-factor outliers
# Suffix p = remove too positive values, n = remove too negative values

# Load QRQ scenarios
raw_qrq_data  <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s0.dta", "scores_raw")
qrq_s1        <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s1.dta", "scores_s1")
qrq_s2        <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s2.dta", "scores_s2")
qrq_s3_n      <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s3_n.dta", "scores_s3_n")
qrq_s3_p      <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s3_p.dta", "scores_s3_p")
qrq_s4_n      <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s4_n.dta", "scores_s4_n")
qrq_s4_p      <- load_scenario("1. Data/2. Scenarios/qrq_country_averages_s4_p.dta", "scores_s4_p")

qrq_country_counts <- read_dta("1. Data/2. Scenarios/country_counts_s0.dta") %>%
  select(country, total_counts)

# Combine scenarios into one long dataset
qrq_scenarios <- raw_qrq_data %>%
  #filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")) %>%
  left_join(qrq_s1, by = c("country", "variables")) %>%
  left_join(qrq_s2, by = c("country", "variables")) %>%
  left_join(qrq_s3_n, by = c("country", "variables")) %>%
  left_join(qrq_s3_p, by = c("country", "variables")) %>%
  left_join(qrq_s4_n, by = c("country", "variables")) %>%
  left_join(qrq_s4_p, by = c("country", "variables")) %>%
  left_join(qrq_country_counts, by = "country")

### Benchmark --------------------------------------------------------------------------------------------------

# Load benchmark: long experts' direction (internal benchmark)

qrq_long_2023 <- read_dta("1. Data/3. Final/qrq_long_2023_country_averages.dta") %>%
  select(country, 
         f_1 = f_1_2023, f_1_2 = f_1_2_2023, f_1_3 = f_1_3_2023, f_1_4 = f_1_4_2023, f_1_5 = f_1_5_2023, f_1_6 = f_1_6_2023, f_1_7 = f_1_7_2023,
         f_2 = f_2_2023, f_2_1 = f_2_1_2023, f_2_2 = f_2_2_2023, f_2_3 = f_2_3_2023, f_2_4 = f_2_4_2023,
         f_3 = f_3_2023, f_3_1 = f_3_1_2023, f_3_2 = f_3_2_2023, f_3_3 = f_3_3_2023, f_3_4 = f_3_4_2023,
         f_4 = f_4_2023, f_4_1 = f_4_1_2023, f_4_2 = f_4_2_2023, f_4_3 = f_4_3_2023, f_4_4 = f_4_4_2023, f_4_5 = f_4_5_2023, f_4_6 = f_4_6_2023, f_4_7 = f_4_7_2023, f_4_8 = f_4_8_2023,
         f_6 = f_6_2023, f_6_1 = f_6_1_2023, f_6_2 = f_6_2_2023, f_6_3 = f_6_3_2023, f_6_4 = f_6_4_2023, f_6_5 = f_6_5_2023,
         f_7 = f_7_2023, f_7_1 = f_7_1_2023, f_7_2 = f_7_2_2023, f_7_3 = f_7_3_2023, f_7_4 = f_7_4_2023, f_7_5 = f_7_5_2023, f_7_6 = f_7_6_2023, f_7_7 = f_7_7_2023,
         f_8 = f_8_2023, f_8_1 = f_8_1_2023, f_8_2 = f_8_2_2023, f_8_3 = f_8_3_2023, f_8_4 = f_8_4_2023, f_8_5 = f_8_5_2023, f_8_6 = f_8_6_2023, f_8_7 = f_8_7_2023, 
         ROLI = ROLI_2023) %>%
  pivot_longer(cols = !c(country), names_to = "variables", values_to = "long_2023")

qrq_long_2024 <- read_dta("1. Data/3. Final/qrq_long_2024_country_averages.dta") %>%
  select(country, 
         f_1 = f_1_2024, f_1_2 = f_1_2_2024, f_1_3 = f_1_3_2024, f_1_4 = f_1_4_2024, f_1_5 = f_1_5_2024, f_1_6 = f_1_6_2024, f_1_7 = f_1_7_2024,
         f_2 = f_2_2024, f_2_1 = f_2_1_2024, f_2_2 = f_2_2_2024, f_2_3 = f_2_3_2024, f_2_4 = f_2_4_2024,
         f_3 = f_3_2024, f_3_1 = f_3_1_2024, f_3_2 = f_3_2_2024, f_3_3 = f_3_3_2024, f_3_4 = f_3_4_2024,
         f_4 = f_4_2024, f_4_1 = f_4_1_2024, f_4_2 = f_4_2_2024, f_4_3 = f_4_3_2024, f_4_4 = f_4_4_2024, f_4_5 = f_4_5_2024, f_4_6 = f_4_6_2024, f_4_7 = f_4_7_2024, f_4_8 = f_4_8_2024,
         f_6 = f_6_2024, f_6_1 = f_6_1_2024, f_6_2 = f_6_2_2024, f_6_3 = f_6_3_2024, f_6_4 = f_6_4_2024, f_6_5 = f_6_5_2024,
         f_7 = f_7_2024, f_7_1 = f_7_1_2024, f_7_2 = f_7_2_2024, f_7_3 = f_7_3_2024, f_7_4 = f_7_4_2024, f_7_5 = f_7_5_2024, f_7_6 = f_7_6_2024, f_7_7 = f_7_7_2024,
         f_8 = f_8_2024, f_8_1 = f_8_1_2024, f_8_2 = f_8_2_2024, f_8_3 = f_8_3_2024, f_8_4 = f_8_4_2024, f_8_5 = f_8_5_2024, f_8_6 = f_8_6_2024, f_8_7 = f_8_7_2024, 
         ROLI = ROLI_2024) %>%
  pivot_longer(cols = !c(country), names_to = "variables", values_to = "long_2024")

qrq_benchmark <- qrq_long_2023 %>%
  left_join(qrq_long_2024, by = c("country", "variables")) %>%
  mutate(
    long_change     = long_2024 - long_2023,
    long_direction  = if_else(long_change > 0, "Positive", "Negative"),
    long_big_change = if_else(abs(long_change) > 0.05, "Yes", "No")
  )

### Scores 2023 and 2024 ------------------------------------------------------------------------------------------------

# Load official QRQ scores
qrq_scores_2023 <- load_scenario("1. Data/3. Final/qrq_country_averages_2023.dta", "scores_2023")
qrq_scores_2024 <- load_scenario("1. Data/3. Final/qrq_country_averages_2024.dta", "scores_2024")
qrq_scores_2024_int <- load_scenario("1. Data/3. Final/qrq_country_averages_2024_int.dta", "scores_2024_int")

qrq_scores_change <- qrq_scores_2023 %>%
  left_join(qrq_scores_2024, by = c("country", "variables")) %>%
  mutate(
    scores_change     = scores_2024 - scores_2023,
    scores_direction  = if_else(scores_change > 0, "Positive", "Negative"),
    scores_big_change = if_else(abs(scores_change) > 0.05, "Yes", "No")
  )

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 3. Data validation system                                                                                 
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# PREP: Join necessary data
qrq_base_stage1 <- qrq_scenarios %>%
  left_join(qrq_benchmark, by = c("country", "variables")) %>%
  left_join(qrq_scores_change, by = c("country", "variables"))

### Stage 1: Compare scenarios 1 vs 2 (remove expert) --------------------------------------

qrq_stage1 <- compare_scenarios(
  df = qrq_base_stage1,
  score_a = "scores_s1",
  score_b = "scores_s2",
  direction_benchmark = "long_direction",
  year_ref = "scores_2023",
  scenario_labels = c("Scenario 1", "Scenario 2"),
  suffix = "stage1"
) %>%
  select(
    country, variables, total_counts, scores_2023, scores_2024, scores_change,
    scores_s3_n, scores_s3_p, scores_s4_n, scores_s4_p, long_direction,
    ends_with("stage1")
  )

### Stage 2: Compare scenarios 3 vs 4 (remove responses) --------------------------------------

# Compute directionally consistent s3 and s4 scores
qrq_stage2_input <- qrq_stage1 %>%
  rowwise() %>%
  mutate(
    s3_change_p = scores_s3_p - scores_2023,
    s3_change_n = scores_s3_n - scores_2023,
    s3_final = case_when(
      long_direction == "Positive" ~ scores_s3_n,
      long_direction == "Negative" ~ scores_s3_p,
      min(c(s3_change_n, s3_change_p), na.rm = TRUE) == s3_change_n ~ scores_s3_n,
      min(c(s3_change_n, s3_change_p), na.rm = TRUE) == s3_change_p ~ scores_s3_p,
      TRUE ~ scores_s3_p
    ),
    s4_change_p = scores_s4_p - scores_2023,
    s4_change_n = scores_s4_n - scores_2023,
    s4_final = case_when(
      long_direction == "Positive" ~ scores_s4_n,
      long_direction == "Negative" ~ scores_s4_p,
      min(c(s4_change_n, s4_change_p), na.rm = TRUE) == s4_change_n ~ scores_s4_n,
      min(c(s4_change_n, s4_change_p), na.rm = TRUE) == s4_change_p ~ scores_s4_p,
      TRUE ~ scores_s4_p
    )
  ) %>%
  ungroup()

qrq_stage2 <- compare_scenarios(
  df = qrq_stage2_input,
  score_a = "s3_final",
  score_b = "s4_final",
  direction_benchmark = "long_direction",
  year_ref = "scores_2023",
  scenario_labels = c("Scenario 3", "Scenario 4"),
  suffix = "stage2"
) %>%
  select(
    country, variables, long_direction, ends_with("stage1"),
    ends_with("stage2"), scores_2023, scores_2024, scores_change, total_counts
  )

### Stage 3: Compare stage 1 vs 2 --------------------------------------

qrq_final <- compare_stages(
  df = qrq_stage2,
  score_a       = "scores_stage1",
  change_a      = "scores_change_stage1",
  direction_a   = "scores_direction_stage1",
  big_change_a  = "scores_big_change_stage1",
  label_a       = "scenario_stage1",
  
  score_b       = "scores_stage2",
  change_b      = "scores_change_stage2",
  direction_b   = "scores_direction_stage2",
  big_change_b  = "scores_big_change_stage2",
  label_b       = "scenario_stage2",
  
  direction_benchmark = "long_direction",
  suffix = "final"
) %>%
  select(
    country, variables, long_direction, ends_with("final"),
    scores_2023, scores_2024, scores_change, total_counts, match_stage_a_b
  )

### Subfactor data --------------------------------------

qrq_final_subfactors <- qrq_final %>%
  select(country, variables, long_direction, scenario_final, scores_final, total_counts) %>%
  full_join(qrq_s1, by = c("country", "variables")) %>%
  full_join(qrq_s2, by = c("country", "variables")) %>%
  full_join(qrq_s3_n, by = c("country", "variables")) %>%
  full_join(qrq_s3_p, by = c("country", "variables")) %>%
  full_join(qrq_s4_n, by = c("country", "variables")) %>%
  full_join(qrq_s4_p, by = c("country", "variables")) %>%
  full_join(qrq_scores_2023, by = c("country", "variables")) %>%
  full_join(qrq_scores_2024, by = c("country", "variables")) %>%
  full_join(qrq_scores_2024_int, by = c("country", "variables"))
  
writexl::write_xlsx(qrq_final_subfactors, path = "prueba.xlsx")

# Define base variables and columns to replicate
base_vars <- c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")
cols_to_copy <- c("long_direction", "scenario_final", "total_counts")

# Loop over each base variable
for (base in base_vars) {
  # Get reference rows
  ref_data <- qrq_final_subfactors %>%
    filter(variables == base) %>%
    select(country, all_of(cols_to_copy)) %>%
    rename_with(~ paste0("ref_", .), all_of(cols_to_copy))
  
  # Merge and update values for matching prefixed variables
  qrq_final_subfactors <- qrq_final_subfactors %>%
    left_join(ref_data, by = "country") %>%
    mutate(across(all_of(cols_to_copy),
                  ~ if_else(grepl(paste0("^", base, "_"), variables),
                            get(paste0("ref_", cur_column())),
                            .))) %>%
    select(-starts_with("ref_")) %>%
    filter(variables != "ROLI")
}

qrq_final_subfactors <- qrq_final_subfactors %>%
  mutate(
    scores_final_factor =
      case_when(
        scenario_final %in% "Scenario 1" ~ scores_s1,
        scenario_final %in% "Scenario 2" ~ scores_s2,
        scenario_final %in% "Scenario 3" & long_direction %in% "Positive" ~ scores_s3_n,
        scenario_final %in% "Scenario 3" & long_direction %in% "Negative" ~ scores_s3_p,
        scenario_final %in% "Scenario 4" & long_direction %in% "Positive" ~ scores_s4_n,
        scenario_final %in% "Scenario 4" & long_direction %in% "Negative" ~ scores_s4_p,
        T ~ scores_final
      )
  )

factors_avg <- qrq_final_subfactors %>%
  mutate(
    factor = 
      case_when(
        str_detect(variables, "f_1_") ~ "f_1",
        str_detect(variables, "f_2_") ~ "f_2",
        str_detect(variables, "f_3_") ~ "f_3",
        str_detect(variables, "f_4_") ~ "f_4",
        str_detect(variables, "f_6_") ~ "f_6",
        str_detect(variables, "f_7_") ~ "f_7",
        str_detect(variables, "f_8_") ~ "f_8"
      )
  ) %>%
  group_by(country, factor) %>%
  mutate(
    factor_score = mean(scores_final, na.rm = T)
  ) %>%
  ungroup() %>%
  drop_na(factor) %>%
  select(country, variables = factor, factor_score) %>%
  unique() 

qrq_subfactors_final <- qrq_final_subfactors %>%
  left_join(factors_avg, by = c("country", "variables")) %>%
  mutate(
    scores_final =
      case_when(
        variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8") ~ factor_score,
        T ~ scores_final
      )
  ) %>%
  select(country, variables, scores_final_subfactor = scores_final, scores_final_factor, 
         scores_2023, scores_2024, scores_2024_int,
         total_counts, scores_s1, scores_s2, scores_s3_n, scores_s3_p, scores_s4_n, scores_s4_p,
         long_direction, scenario_final_factor = scenario_final, long_direction) %>%
  mutate(
    diff_subfactor     = abs(scores_2024 - scores_final_subfactor),
    diff_factor        = abs(scores_2024 - scores_final_factor),
    best_scores        = 
      case_when(
        diff_subfactor < diff_factor ~ "diff_subfactor",
        diff_subfactor > diff_factor ~ "diff_factor",
        diff_subfactor == diff_factor ~ "same"
      ),
    diff_subfactor_int     = abs(scores_2024_int - scores_final_subfactor),
    diff_factor_int        = abs(scores_2024_int - scores_final_factor),
    best_scores_int        = 
      case_when(
        diff_subfactor < diff_factor ~ "diff_subfactor",
        diff_subfactor > diff_factor ~ "diff_factor",
        diff_subfactor == diff_factor ~ "same"
      ),
    change_subfactor    = scores_2023 - scores_final_subfactor,
    change_factor       = scores_2023 - scores_final_factor,
    direction_subfactor = 
      case_when(
        change_subfactor > 0 ~ "Positive",
        change_subfactor < 0 ~ "Negative",
        change_subfactor == 0 ~ "No change"
      ),
    direction_factor = 
      case_when(
        change_factor > 0 ~ "Positive",
        change_factor < 0 ~ "Negative",
        change_factor == 0 ~ "No change"
      )
  ) %>%
  mutate(
    scores_change = scores_2023 - scores_2024,
    scores_direction = case_when(
      scores_change < 0 ~ "Negative",
      scores_change > 0 ~ "Positive",
      scores_change == 0 ~ "No change"
    ),
    scores_change_int = scores_2023 - scores_2024_int,
    scores_direction_int = case_when(
      scores_change_int < 0 ~ "Negative",
      scores_change_int > 0 ~ "Positive",
      scores_change_int == 0 ~ "No change"
    )
  )

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 4.  Data Analysis                                                                                     ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

"%!in%" <- compose("!", "%in%")

qrq_scores_analysis <- qrq_subfactors_final %>%
  mutate(
    level = case_when(
      total_counts < 41 ~ "3. Low counts",
      total_counts >= 41 & total_counts < 61 ~ "2. Medium counts",
      total_counts >= 61 ~ "1. High counts"
    ),
    diff_factor_cat = case_when(
      diff_factor == 0                         ~ "No differences",
      diff_factor > 0 & diff_factor < 0.01     ~ "Differences below 0.01",
      diff_factor >= 0.01 & diff_factor < 0.05 ~ "Differences between 0.01 and 0.05",
      diff_factor >= 0.05 & diff_factor < 0.1  ~ "Differences between 0.05 and 0.1",
      diff_factor >= 0.1                       ~ "Differences above 0.1"
    ),
    diff_factor_cat_int = case_when(
      diff_factor_int == 0                         ~ "No differences",
      diff_factor_int > 0 & diff_factor_int < 0.01     ~ "Differences below 0.01",
      diff_factor_int >= 0.01 & diff_factor_int < 0.05 ~ "Differences between 0.01 and 0.05",
      diff_factor_int >= 0.05 & diff_factor_int < 0.1  ~ "Differences between 0.05 and 0.1",
      diff_factor_int >= 0.1                       ~ "Differences above 0.1"
    ),
    diff_factor_direction = case_when(
      direction_factor == scores_direction ~ "Same direction",
      direction_factor != scores_direction ~ "Different direction",
      T ~ NA_character_
    ),
    diff_factor_direction_int = case_when(
      direction_factor == scores_direction_int ~ "Same direction",
      direction_factor != scores_direction_int ~ "Different direction",
      T ~ NA_character_
    ),
    diff_subfactor_cat = case_when(
      diff_subfactor < 0.01     ~ "Differences below 0.01",
      diff_subfactor >= 0.01 & diff_subfactor < 0.05 ~ "Differences between 0.01 and 0.05",
      diff_subfactor >= 0.05                       ~ "Differences above 0.05"
    ),
    diff_subfactor_direction = case_when(
      direction_subfactor == scores_direction ~ "Same direction",
      direction_subfactor != scores_direction ~ "Different direction",
      T ~ NA_character_
    )
  )
  # ) %>%
  # group_by(variables) %>%
  # mutate(
  #   scores_2024_ranking  = rank(-scores_2024),
  #   scores_final_ranking = rank(-scores_final_factor),
  #   diff_ranking = abs(scores_2024_ranking - scores_final_ranking),
  # ) %>%
  # ungroup() %>%
  # mutate(
  #   diff_ranking_cat = case_when(
  #     diff_ranking == 0                      ~ "No differences",
  #     diff_ranking > 0 & diff_ranking < 5    ~ "Differences between 1 and 5",
  #     diff_ranking >= 5 & diff_ranking < 10  ~ "Differences between 5 and 10",
  #     diff_ranking >= 10 & diff_ranking < 20 ~ "Differences between 10 and 20",
  #     diff_ranking >= 20                     ~ "Differences above 20")
  # )

subfactors_analysis <- qrq_scores_analysis %>%
  filter(variables %!in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8"))

diff_levels <- c(
  "Differences below 0.01",
  "Differences between 0.01 and 0.05",
  "Differences above 0.05"
)
data_diff       <- proportions_data(subfactors_analysis,
                                    "diff_subfactor_cat", diff_levels)

p_differences   <- plot_bar(data_diff, 
                            "diff_subfactor_cat",
                            "Distribution of differences 2024");p_differences

direction_levels <- c(
  "Same direction",
  "Different direction"
)
data_direction  <- proportions_data(subfactors_analysis,
                                    "diff_subfactor_direction", direction_levels)
p_direction     <- plot_bar(data_direction, 
                            "diff_subfactor_direction",
                            "Differences in the direction 2024");p_direction  

factors_analysis <- qrq_scores_analysis %>%
  filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8"))

diff_levels <- c(
  "No differences",
  "Differences below 0.01",
  "Differences between 0.01 and 0.05",
  "Differences between 0.05 and 0.1",
  "Differences above 0.1"
)
data_diff       <- proportions_data(factors_analysis,
                                    "diff_subfactor_cat", diff_levels)

p_differences   <- plot_bar(data_diff, 
                            "diff_subfactor_cat",
                            "Distribution of differences 2024");p_differences

direction_levels <- c(
  "Same direction",
  "Different direction"
)
data_direction  <- proportions_data(factors_analysis,
                                    "diff_subfactor_direction", direction_levels)
p_direction     <- plot_bar(data_direction, 
                            "diff_subfactor_direction",
                            "Differences in the direction 2024");p_direction  


### Proportions analysis ------------------------------------------------------

#### Differences

diff_levels <- c(
  "No differences",
  "Differences below 0.01",
  "Differences between 0.01 and 0.05",
  "Differences between 0.05 and 0.1",
  "Differences above 0.1"
)

data_diff       <- proportions_data(qrq_scores_analysis %>% 
                                      filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")),
                                    "diff_factor_cat", diff_levels)
p_differences   <- plot_bar(data_diff, 
                            "diff_factor_cat",
                            "Distribution of differences 2024");p_differences

data_diff       <- proportions_data(qrq_scores_analysis %>% 
                                      filter(variables %!in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")),
                                    "diff_subfactor_cat", diff_levels)
p_differences   <- plot_bar(data_diff, 
                            "diff_subfactor_cat",
                            "Distribution of differences 2024");p_differences

data_diff       <- proportions_data(qrq_scores_analysis %>% 
                                      filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")), 
                                    "diff_factor_cat_int", diff_levels)
p_differences   <- plot_bar(data_diff, 
                            "diff_factor_cat_int",
                            "Distribution of differences 2024");p_differences

ggsave(plot = p_differences, 
       filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_levels.svg"),
       width = 10,
       height = 7)

#### Directions

direction_levels <- c(
  "Same direction",
  "Different direction"
)

data_direction  <- proportions_data(qrq_scores_analysis %>% 
                                      filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")), 
                                    "diff_factor_direction", direction_levels) %>% drop_na()
p_direction     <- plot_bar(data_direction, 
                            "diff_factor_direction",
                            "Differences in the direction 2024");p_direction

data_direction  <- proportions_data(qrq_scores_analysis %>% 
                                      filter(variables %!in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")), 
                                    "diff_subfactor_direction", direction_levels) %>% drop_na()
p_direction     <- plot_bar(data_direction, 
                            "diff_subfactor_direction",
                            "Differences in the direction 2024");p_direction

data_direction  <- proportions_data(qrq_scores_analysis%>% 
                                      filter(variables %!in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")),
                                    "diff_factor_direction_int", direction_levels) %>% drop_na()
p_direction     <- plot_bar(data_direction, 
                            "diff_factor_direction_int",
                            "Differences in the direction 2024");p_direction

ggsave(plot = p_direction, 
       filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_direction.svg"),
       width = 10,
       height = 7)

direction_counts <- qrq_scores_analysis%>% 
  filter(variables %!in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")) %>%
  group_by(level) %>%
  # Count the number of occurrences per category
  count(diff_factor_direction) %>%
  
  # Drop rows where the category variable is NA
  drop_na() %>%
  
  # Compute the proportion and convert the variable to a factor with the desired order
  mutate(
    proportion = round(n / sum(n) * 100, 2),
    category_var := factor(diff_factor_direction, levels = direction_levels)
  )

#### Rankings

# diff_rankings <- c(
#   "No differences",
#   "Differences between 1 and 5",
#   "Differences between 5 and 10",
#   "Differences between 10 and 20",
#   "Differences above 20"
# )
# 
# data_rankings   <- proportions_data(qrq_scores_analysis, "diff_ranking_cat", diff_rankings)
# p_diff_ranking  <- plot_bar(data_rankings, 
#                             "diff_ranking_cat",
#                             "Rankings differences 2024");p_diff_ranking
# 
# ggsave(plot = p_diff_ranking, 
#        filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_ranking.svg"),
#        width = 10,
#        height = 7)

#### Scenarios

# scenario_levels <- c(
#   "Scenario 1",
#   "Scenario 2",
#   "Scenario 3",
#   "Scenario 4"
# )
# 
# data_scenarios  <- proportions_data(qrq_scores_analysis, "scenario_final_factor", scenario_levels)
# p_scenarios     <- plot_bar(data_scenarios, 
#                             "scenario_final",
#                             "Scenarios 2024");p_scenarios
# 
# ggsave(plot = p_scenarios, 
#        filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_scenarios.svg"),
#        width = 10,
#        height = 7)


### Averages analysis ------------------------------------------------------
# 
# data_diff_factor <- qrq_scores_analysis %>%
#   group_by(variables) %>%
#   summarise(avg_diff = mean(diff_qrq, na.rm = T))
# 
# print(data_diff_factor)
# 
# data_diff_level <- qrq_scores_analysis %>%
#   group_by(level) %>%
#   summarise(avg_diff = mean(diff_qrq, na.rm = T))
# 
# print(data_diff_level)
# 
# ### Ranking analysis ------------------------------------------------------
# 
# data_diff_factor_ranking <- qrq_scores_analysis %>%
#   group_by(variables) %>%
#   summarise(avg_diff = mean(diff_ranking, na.rm = T))
# 
# print(data_diff_factor_ranking)
# 
# data_diff_level_ranking <- qrq_scores_analysis %>%
#   group_by(level) %>%
#   summarise(avg_diff = mean(diff_ranking, na.rm = T))
# 
# print(data_diff_level_ranking)
# 
# ### Direction analysis ------------------------------------------------------
# 
# data_diff_direction <- qrq_scores_analysis %>%
#   group_by(diff_direction) %>%
#   summarise(avg_diff = mean(diff_qrq, na.rm = T))
# 
# print(data_diff_direction)
# 
# data_diff_direction_ranking <- qrq_scores_analysis %>%
#   group_by(diff_direction) %>%
#   summarise(avg_diff = mean(diff_ranking, na.rm = T))
# 
# print(data_diff_direction_ranking)
# 
# data_diff_direction_ranking <- qrq_scores_analysis %>%
#   group_by(diff_direction) %>%
#   summarise(avg_diff = mean(diff_ranking, na.rm = T))
# 
# print(data_diff_direction_ranking)
# 
# ### Direction diff analysis ------------------------------------------------------
# 
# qrq_negative <- qrq_scores_analysis %>%
#   filter(scores_direction_final %in% "Negative") %>%
#   summarise(avg_diff_final = mean(scores_change_final, na.rm = T),
#             avg_diff_scores = mean(scores_change, na.rm = T))
# 
# print(qrq_negative)
# 
# qrq_positive <- qrq_scores_analysis %>%
#   filter(scores_direction_final %in% "Positive") %>%
#   summarise(avg_diff_final = mean(scores_change_final, na.rm = T),
#             avg_diff_scores = mean(scores_change, na.rm = T))
# 
# print(qrq_positive)
