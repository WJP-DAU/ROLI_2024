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
qrq_s0        <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s0.dta", 
                               "scores_s0")

qrq_s1_n      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s1_n.dta", 
                               "scores_s1_n")
qrq_s1_p      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s1_p.dta", 
                               "scores_s1_p")

qrq_s2_n      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s2_n.dta", 
                               "scores_s2_n")
qrq_s2_p      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s2_p.dta", 
                               "scores_s2_p")

qrq_s3_n      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s3_n.dta", 
                               "scores_s3_n")
qrq_s3_p      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s3_p.dta", 
                               "scores_s3_p")

qrq_s4_n      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s4_n.dta", 
                               "scores_s4_n")
qrq_s4_p      <- load_scenario("1. Data/2. Scenarios/Alternative/qrq_country_averages_s4_p.dta", 
                               "scores_s4_p")

qrq_country_counts <- read_dta("1. Data/2. Scenarios/Alternative/country_counts_s0.dta") %>%
  select(country, total_counts, total_counts_long)


# Combine scenarios into one long dataset
qrq_scenarios <- qrq_s0 %>%
  #filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8")) %>%
  left_join(qrq_s1_n, by = c("country", "variables")) %>%
  left_join(qrq_s1_p, by = c("country", "variables")) %>%
  left_join(qrq_s2_n, by = c("country", "variables")) %>%
  left_join(qrq_s2_p, by = c("country", "variables")) %>%
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

### Final data ------------------------------------------------------------------------------------------------

# PREP: Join necessary data
qrq4validation <- qrq_scenarios %>%
  left_join(qrq_benchmark,     by = c("country", "variables")) %>%
  left_join(qrq_scores_change, by = c("country", "variables")) %>%
  mutate(
    diff_s0 = scores_s0 - scores_2023,
    s0_direction  = if_else(diff_s0 > 0, "Positive", "Negative"),
    s0_match_long = if_else(long_direction == s0_direction & total_counts_long > 5, "Same", "Different",
                            if_else(s0_direction == s0_direction, "Same", "Different",
                                    "Review")),
  ) %>%
  mutate(
    diff_s1_p       = scores_s1_p - scores_2023,
    s1_p_direction  = if_else(diff_s1_p > 0, "Positive", "Negative"),
    s1_p_match_long = if_else(long_direction == s1_p_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s1_p_direction, "Same", "Different",
                                      "Review")),
    diff_s1_n       = scores_s1_n - scores_2023,
    s1_n_direction  = if_else(diff_s1_n > 0, "Positive", "Negative"),
    s1_n_match_long = if_else(long_direction == s1_n_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s1_n_direction, "Same", "Different",
                                      "Review")),
    diff_s2_p       = scores_s2_p - scores_2023,
    s2_p_direction  = if_else(diff_s2_p > 0, "Positive", "Negative"),
    s2_p_match_long = if_else(long_direction == s2_p_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s2_p_direction, "Same", "Different",
                                      "Review")),
    diff_s2_n       = scores_s2_n - scores_2023,
    s2_n_direction  = if_else(diff_s2_n > 0, "Positive", "Negative"),
    s2_n_match_long = if_else(long_direction == s2_n_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s2_n_direction, "Same", "Different",
                                      "Review")),
    diff_s3_p       = scores_s3_p - scores_2023,
    s3_p_direction  = if_else(diff_s3_p > 0, "Positive", "Negative"),
    s3_p_match_long = if_else(long_direction == s3_p_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s3_p_direction, "Same", "Different",
                                      "Review")),
    diff_s3_n       = scores_s3_n - scores_2023,
    s3_n_direction  = if_else(diff_s3_n > 0, "Positive", "Negative"),
    s3_n_match_long = if_else(long_direction == s3_n_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s3_n_direction, "Same", "Different",
                                      "Review")),
    diff_s4_p       = scores_s4_p - scores_2023,
    s4_p_direction  = if_else(diff_s4_p > 0, "Positive", "Negative"),
    s4_p_match_long = if_else(long_direction == s4_p_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s4_p_direction, "Same", "Different",
                                      "Review")),
    diff_s4_n       = scores_s4_n - scores_2023,
    s4_n_direction  = if_else(diff_s4_n > 0, "Positive", "Negative"),
    s4_n_match_long = if_else(long_direction == s4_n_direction & total_counts_long > 5, "Same", "Different",
                              if_else(s0_direction == s4_n_direction, "Same", "Different",
                                      "Review")),
    scores_s1 = 
      case_when(
        long_direction %in% "Negative" & total_counts_long > 5 ~ scores_s1_p,
        long_direction %in% "Positive" & total_counts_long > 5 ~ scores_s1_n,
        s0_direction   %in% "Negative"  ~ scores_s1_p,
        s0_direction   %in% "Positive"  ~ scores_s1_n,
        T ~ NA_real_
      ),
    diff_s1       = scores_s1 - scores_2023,
    s1_direction  = if_else(diff_s1 > 0, "Positive", "Negative"),
    s1_match_long = if_else(long_direction == s1_direction & total_counts_long > 5, "Same", "Different",
                            if_else(s0_direction == s1_direction, "Same", "Different",
                                    "Review")),
    scores_s2 = 
      case_when(
        long_direction %in% "Negative" & total_counts_long > 5 ~ scores_s2_p,
        long_direction %in% "Positive" & total_counts_long > 5 ~ scores_s2_n,
        s0_direction   %in% "Negative" ~ scores_s2_p,
        s0_direction   %in% "Positive" ~ scores_s2_n,
        T ~ NA_real_
      ),
    diff_s2   = scores_s2 - scores_2023,
    s2_direction  = if_else(diff_s2 > 0, "Positive", "Negative"),
    s2_match_long = if_else(long_direction == s2_direction & total_counts_long > 5, "Same", "Different",
                            if_else(s0_direction == s2_direction, "Same", "Different",
                                    "Review")),
    scores_s3 = 
      case_when(
        long_direction %in% "Negative" & total_counts_long > 5 ~ scores_s3_p,
        long_direction %in% "Positive" & total_counts_long > 5 ~ scores_s3_n,
        s0_direction   %in% "Negative" ~ scores_s3_p,
        s0_direction   %in% "Positive" ~ scores_s3_n,
        T ~ NA_real_
      ),
    diff_s3   = scores_s3 - scores_2023,
    s3_direction  = if_else(diff_s3 > 0, "Positive", "Negative"),
    s3_match_long = if_else(long_direction == s3_direction & total_counts_long > 5, "Same", "Different",
                            if_else(s0_direction == s3_direction, "Same", "Different",
                                    "Review")),
    scores_s4 = 
      case_when(
        long_direction %in% "Negative" & total_counts_long > 5 ~ scores_s4_p,
        long_direction %in% "Positive" & total_counts_long > 5 ~ scores_s4_n,
        s0_direction   %in% "Negative" ~ scores_s4_p,
        s0_direction   %in% "Positive" ~ scores_s4_n,
        T ~ NA_real_
      ),
    diff_s4   = scores_s4 - scores_2023,
    s4_direction  = if_else(diff_s4 > 0, "Positive", "Negative"),
    s4_match_long = if_else(long_direction == s4_direction & total_counts_long > 5, "Same", "Different",
                            if_else(s0_direction == s4_direction, "Same", "Different",
                                    "Review"))
  )

writexl::write_xlsx(qrq4validation, path = "qrq4validation.xlsx")

## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 3. Data validation system                                                                                 
##
## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

validate_qrq_scores <- function(df) {
  # Validación de columnas requeridas
  
  required_cols <- c(
    "scores_s0","scores_s1","scores_s2","scores_s3","scores_s4",
    "diff_s0","diff_s1","diff_s2","diff_s3","diff_s4",
    "s0_match_long","s1_match_long","s2_match_long","s3_match_long","s4_match_long"
  )
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(paste("Missing columns in input data:", paste(missing_cols, collapse = ", ")))
  }
  
  # Función auxiliar por fila
  select_validated_score <- function(row) {

    scores <- as.numeric(row[c("scores_s0", "scores_s1", "scores_s2", "scores_s3", "scores_s4")])
    diffs  <- abs(as.numeric(row[c("diff_s0","diff_s1", "diff_s2", "diff_s3", "diff_s4")]))
    matches <- row[c("s0_match_long","s1_match_long", "s2_match_long", "s3_match_long", "s4_match_long")]
    
    escenarios <- c("s0", "s1", "s2", "s3", "s4")
    
    valid <- data.frame(
      escenario = escenarios,
      score = scores,
      diff = diffs,
      match = matches,
      stringsAsFactors = FALSE
    )
    
    valid <- valid[complete.cases(valid), ]
    if (nrow(valid) == 0) return(c(score = NA, scenario = NA))
    
    same_matches <- valid[valid$match == "Same", ]
    
    if (nrow(same_matches) > 0) {
      min_diff <- min(same_matches$diff)
      selected <- same_matches[same_matches$diff == min_diff, ]
    } else {
      min_diff <- min(valid$diff)
      selected <- valid[valid$diff == min_diff, ]
    }
    
    selected <- selected[order(selected$escenario), ]
    
    scenario_label <- switch(selected$escenario[1],
                             "s0" = "Scenario 0",
                             "s1" = "Scenario 1",
                             "s2" = "Scenario 2",
                             "s3" = "Scenario 3",
                             "s4" = "Scenario 4"
    )
    
    return(c(score = selected$score[1], scenario = scenario_label))
  }
  
  # Aplicar la función a cada fila
  results <- t(apply(df, 1, select_validated_score)) |> as.data.frame()
  results$score <- as.numeric(results$score)
  
  # Asignar columnas nuevas
  df$validated_score <- results$score
  df$validated_scenario <- results$scenario
  
  return(df)
}

qrq_validated <- validate_qrq_scores(qrq4validation) %>%
  select(country, variables, validated_score, validated_scenario, total_counts, 
         scores_2023, scores_2024, scores_change, scores_direction,
         scores_s0, long_change, long_direction)

factors_scores <- qrq_validated %>%
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
    factor_score = mean(validated_score, na.rm = T)
  ) %>%
  ungroup() %>%
  drop_na(factor) %>%
  select(country, variables = factor, factor_score) %>%
  unique() 

qrq_validated <- qrq_validated %>%
  left_join(factors_scores, by = c("country", "variables")) %>%
  mutate(
    validated_score =
      case_when(
        variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8") ~ factor_score,
        T ~ validated_score
      )
  )

"%!in%" <- compose("!", "%in%")
qrq4analysis <- qrq_validated %>%
  mutate(
    diff_scores_2023            = validated_score - scores_2023,
    validated_scores_direction  = if_else(diff_scores_2023 > 0, "Positive", "Negative"),
    diff_scores_2024            = validated_score - scores_2024,
    validated_benchmark_direction  = if_else(scores_direction == validated_scores_direction, "Same", "Different"),
  ) %>%
  mutate(
    level = case_when(
      total_counts < 41 ~ "3. Low counts",
      total_counts >= 41 & total_counts < 61 ~ "2. Medium counts",
      total_counts >= 61 ~ "1. High counts"
    ),
    diff_scores_2024_cat = case_when(
      diff_scores_2024 < 0.01                            ~ "Differences below 0.01",
      diff_scores_2024 >= 0.01 & diff_scores_2024 < 0.05 ~ "Differences between 0.01 and 0.05",
      diff_scores_2024 >= 0.05                           ~ "Differences above 0.05"
    )
  ) 

writexl::write_xlsx(x = qrq4analysis, path = "qrq4analysis.xlsx")

## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 4. Analysis                                                                               
##
## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subfactors_analysis <- qrq4analysis %>%
  filter(variables %!in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8"))

diff_levels <- c(
  "Differences below 0.01",
  "Differences between 0.01 and 0.05",
  "Differences above 0.05"
)
data_diff       <- proportions_data(subfactors_analysis,
                                    "diff_scores_2024_cat", diff_levels)

p_differences   <- plot_bar(data_diff, 
                            "diff_scores_2024_cat",
                            "Distribution of differences 2024");p_differences

direction_levels <- c(
  "Same",
  "Different"
)
data_direction  <- proportions_data(subfactors_analysis,
                                    "validated_benchmark_direction", direction_levels)
p_direction     <- plot_bar(data_direction, 
                            "validated_benchmark_direction",
                            "Differences in the direction 2024");p_direction  


factors_analysis <- qrq4analysis %>%
  filter(variables %in% c("f_1", "f_2", "f_3", "f_4", "f_6", "f_7", "f_8"))

diff_levels <- c(
  "Differences below 0.01",
  "Differences between 0.01 and 0.05",
  "Differences above 0.05"
)
data_diff       <- proportions_data(factors_analysis,
                                    "diff_scores_2024_cat", diff_levels)

p_differences   <- plot_bar(data_diff, 
                            "diff_scores_2024_cat",
                            "Distribution of differences 2024");p_differences

direction_levels <- c(
  "Same",
  "Different"
)
data_direction  <- proportions_data(factors_analysis,
                                    "validated_benchmark_direction", direction_levels)
p_direction     <- plot_bar(data_direction, 
                            "validated_benchmark_direction",
                            "Differences in the direction 2024");p_direction  

