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
  select(country, f_1 = f_1_2023, f_2 = f_2_2023, f_3 = f_3_2023, f_4 = f_4_2023, f_5 = f_5_2023, f_6 = f_6_2023, f_7 = f_7_2023, f_8 = f_8_2023, ROLI = ROLI_2023) %>%
  pivot_longer(cols = !c(country), names_to = "variables", values_to = "long_2023")
qrq_long_2024 <- read_dta("1. Data/3. Final/qrq_long_2024_country_averages.dta") %>%
  select(country, f_1 = f_1_2024, f_2 = f_2_2024, f_3 = f_3_2024, f_4 = f_4_2024, f_5 = f_5_2024, f_6 = f_6_2024, f_7 = f_7_2024, f_8 = f_8_2024, ROLI = ROLI_2024) %>%
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

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 4.  Data Analysis                                                                                     ----
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

"%!in%" <- compose("!", "%in%")

qrq_scores_analysis <- qrq_final %>%
  filter(variables %!in% "f_5") %>%
  filter(variables %!in% "ROLI") %>%
  mutate(
    diff_qrq_raw = scores_2024 - scores_final,
    diff_qrq = abs(diff_qrq_raw),
    level = case_when(
      total_counts < 41 ~ "3. Low counts",
      total_counts >= 41 & total_counts < 61 ~ "2. Medium counts",
      total_counts >= 61 ~ "1. High counts"
    ),
    diff_cat = case_when(
      diff_qrq == 0                      ~ "No differences",
      diff_qrq > 0 & diff_qrq < 0.01     ~ "Differences below 0.01",
      diff_qrq >= 0.01 & diff_qrq < 0.05 ~ "Differences between 0.01 and 0.05",
      diff_qrq >= 0.05 & diff_qrq < 0.1  ~ "Differences between 0.05 and 0.1",
      diff_qrq >= 0.1                    ~ "Differences above 0.1"
    ),
    scores_direction = case_when(
      scores_change < 0 ~ "Negative",
      scores_change > 0 ~ "Positive",
      scores_change == 0 ~ "No change"
    ),
    diff_direction = case_when(
      scores_direction_final == scores_direction ~ "Same direction",
      scores_direction_final != scores_direction ~ "Different direction",
      T ~ "Review"
    )
  ) %>%
  group_by(variables) %>%
  mutate(
    scores_2024_ranking  = rank(-scores_2024),
    scores_final_ranking = rank(-scores_final),
    diff_ranking = abs(scores_2024_ranking - scores_final_ranking),
  ) %>%
  ungroup() %>%
  mutate(
    diff_ranking_cat = case_when(
      diff_ranking == 0                      ~ "No differences",
      diff_ranking > 0 & diff_ranking < 5    ~ "Differences between 1 and 5",
      diff_ranking >= 5 & diff_ranking < 10  ~ "Differences between 5 and 10",
      diff_ranking >= 10 & diff_ranking < 20 ~ "Differences between 10 and 20",
      diff_ranking >= 20                     ~ "Differences above 20")
  )

### Proportions analysis ------------------------------------------------------

#### Rankings

diff_rankings <- c(
  "No differences",
  "Differences between 1 and 5",
  "Differences between 5 and 10",
  "Differences between 10 and 20",
  "Differences above 20"
)

data_rankings   <- proportions_data(qrq_scores_analysis, "diff_ranking_cat", diff_rankings)
p_diff_ranking  <- plot_bar(data_rankings, 
                            "diff_ranking_cat",
                            "Rankings differences 2024");p_diff_ranking

ggsave(plot = p_diff_ranking, 
       filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_ranking.svg"),
       width = 10,
       height = 7)

#### Scenarios

scenario_levels <- c(
  "Scenario 1",
  "Scenario 2",
  "Scenario 3",
  "Scenario 4"
)

data_scenarios  <- proportions_data(qrq_scores_analysis, "scenario_final", scenario_levels)
p_scenarios     <- plot_bar(data_scenarios, 
                            "scenario_final",
                            "Scenarios 2024");p_scenarios

ggsave(plot = p_scenarios, 
       filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_scenarios.svg"),
       width = 10,
       height = 7)

#### Differences

diff_levels <- c(
  "No differences",
  "Differences below 0.01",
  "Differences between 0.01 and 0.05",
  "Differences between 0.05 and 0.1",
  "Differences above 0.1"
)

data_diff       <- proportions_data(qrq_scores_analysis, "diff_cat", diff_levels)
p_differences   <- plot_bar(data_diff, 
                            "diff_cat",
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

data_direction  <- proportions_data(qrq_scores_analysis, "diff_direction", direction_levels)
p_direction     <- plot_bar(data_direction, 
                            "diff_direction",
                            "Differences in the direction 2024");p_direction

ggsave(plot = p_direction, 
       filename = paste0(path2DA, "/3. Outputs/Charts/", "p_diff_direction.svg"),
       width = 10,
       height = 7)

### Averages analysis ------------------------------------------------------

data_diff_factor <- qrq_scores_analysis %>%
  group_by(variables) %>%
  summarise(avg_diff = mean(diff_qrq, na.rm = T))

print(data_diff_factor)

data_diff_level <- qrq_scores_analysis %>%
  group_by(level) %>%
  summarise(avg_diff = mean(diff_qrq, na.rm = T))

print(data_diff_level)

### Ranking analysis ------------------------------------------------------

data_diff_factor_ranking <- qrq_scores_analysis %>%
  group_by(variables) %>%
  summarise(avg_diff = mean(diff_ranking, na.rm = T))

print(data_diff_factor_ranking)

data_diff_level_ranking <- qrq_scores_analysis %>%
  group_by(level) %>%
  summarise(avg_diff = mean(diff_ranking, na.rm = T))

print(data_diff_level_ranking)

### Direction analysis ------------------------------------------------------

data_diff_direction <- qrq_scores_analysis %>%
  group_by(diff_direction) %>%
  summarise(avg_diff = mean(diff_qrq, na.rm = T))

print(data_diff_direction)

data_diff_direction_ranking <- qrq_scores_analysis %>%
  group_by(diff_direction) %>%
  summarise(avg_diff = mean(diff_ranking, na.rm = T))

print(data_diff_direction_ranking)

data_diff_direction_ranking <- qrq_scores_analysis %>%
  group_by(diff_direction) %>%
  summarise(avg_diff = mean(diff_ranking, na.rm = T))

print(data_diff_direction_ranking)

### Direction diff analysis ------------------------------------------------------

qrq_negative <- qrq_scores_analysis %>%
  filter(scores_direction_final %in% "Negative") %>%
  summarise(avg_diff_final = mean(scores_change_final, na.rm = T),
            avg_diff_scores = mean(scores_change, na.rm = T))

print(qrq_negative)

qrq_positive <- qrq_scores_analysis %>%
  filter(scores_direction_final %in% "Positive") %>%
  summarise(avg_diff_final = mean(scores_change_final, na.rm = T),
            avg_diff_scores = mean(scores_change, na.rm = T))

print(qrq_positive)
