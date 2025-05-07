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

# Loading additional code modules
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

# Helper: Load and pivot scenario files
load_scenario <- function(file, value_name) {
  read_dta(file) %>%
    select(country, f_1:f_8, ROLI) %>%
    pivot_longer(cols = -country, names_to = "variables", values_to = value_name)
}

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

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##
## 3. Data validation system --------------------------                                                                                 
##
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

### Stage 1: Compare scenarios 1 vs 2 (remove expert) ------------------------------------------------------------------------------------------------

qrq_stage1 <- qrq_scenarios %>%
  left_join(qrq_benchmark, by = c("country", "variables")) %>%
  left_join(qrq_scores_change, by = c("country", "variables")) %>%
  mutate(
    # Calculate change in score for each scenario relative to previous year
    s1_change = scores_s1 - scores_2023,
    s2_change = scores_s2 - scores_2023,
    
    # Direction of change
    s1_direction = if_else(s1_change > 0, "Positive", "Negative"),
    s2_direction = if_else(s2_change > 0, "Positive", "Negative"),
    
    # Large change indicator (absolute change > 0.05)
    s1_scores_big_change = if_else(abs(s1_change) > 0.05, "Yes", "No"),
    s2_scores_big_change = if_else(abs(s2_change) > 0.05, "Yes", "No"),
    
    # Match with benchmark direction
    s1_match_long = if_else(s1_direction == long_direction, "Yes", "No", missing = "No data"),
    s2_match_long = if_else(s2_direction == long_direction, "Yes", "No", missing = "No data")
  ) %>%
  rowwise() %>%
  mutate(
    # Select the minimum change scenario (if both mismatch or match equally)
    min_scenario = case_when(
      s1_change == s2_change ~ "s1_change", #Minimal Intervention
      min(s1_change, s2_change, na.rm = TRUE) == s1_change ~ "s1_change", #Stability over time
      min(s1_change, s2_change, na.rm = TRUE) == s2_change ~ "s2_change", #Stability over time
      is.na(scores_2023) ~ "s1_change", #Minimal Intervention
      is.na(min(s1_change, s2_change)) ~ "No data"
    ),
    
    # Apply selection logic
    scenario_stage1 = case_when(
      s1_match_long == "Yes" & s2_match_long == "No" ~ "Scenario 1",
      s1_match_long == "No" & s2_match_long == "Yes" ~ "Scenario 2",
      min_scenario == "s1_change" ~ "Scenario 1", #Following our principles
      min_scenario == "s2_change" ~ "Scenario 2"  #Following our principles
    ),
    
    # Output selected score, change, direction, and large change flag
    scores_stage1 = if_else(scenario_stage1 == "Scenario 1", scores_s1, scores_s2),
    scores_change_stage1 = if_else(scenario_stage1 == "Scenario 1", s1_change, s2_change),
    scores_direction_stage1 = if_else(scenario_stage1 == "Scenario 1", s1_direction, s2_direction),
    scores_big_change_stage1 = if_else(scenario_stage1 == "Scenario 1", s1_scores_big_change, s2_scores_big_change)
  ) %>%
  ungroup() %>%
  select(
    country, variables, total_counts, scores_2023, scores_2024, scores_change,
    scores_s3_n, scores_s3_p, scores_s4_n, scores_s4_p, long_direction,
    ends_with("stage1")
  )

### Stage 2: Compare scenarios 3 vs 4 (remove responses) ------------------------------------------------------------------------------------------------

qrq_stage2 <- qrq_stage1 %>%
  rowwise() %>%
  mutate(
    # Compute score changes for question-level (s3) scenarios
    s3_change_p = scores_s3_p - scores_2023,
    s3_change_n = scores_s3_n - scores_2023,
    
    # Determine directionally consistent score for s3
    s3_final = case_when(
      long_direction == "Positive" ~ scores_s3_n,
      long_direction == "Negative" ~ scores_s3_p,
      min(s3_change_n, s3_change_p, na.rm = TRUE) == s3_change_n ~ scores_s3_n,
      min(s3_change_n, s3_change_p, na.rm = TRUE) == s3_change_p ~ scores_s3_p,
      TRUE ~ scores_s3_p
    ),
    
    # Compute score changes for sub-factor-level (s4) scenarios
    s4_change_p = scores_s4_p - scores_2023,
    s4_change_n = scores_s4_n - scores_2023,
    
    # Determine directionally consistent score for s4
    s4_final = case_when(
      long_direction == "Positive" ~ scores_s4_n,
      long_direction == "Negative" ~ scores_s4_p,
      min(s4_change_n, s4_change_p, na.rm = TRUE) == s4_change_n ~ scores_s4_n,
      min(s4_change_n, s4_change_p, na.rm = TRUE) == s4_change_p ~ scores_s4_p,
      TRUE ~ scores_s4_p
    )
  ) %>%
  ungroup() %>%
  mutate(
    # Calculate change and direction for s3 and s4
    s3_change = s3_final - scores_2023,
    s4_change = s4_final - scores_2023,
    
    s3_direction = if_else(s3_change > 0, "Positive", "Negative"),
    s4_direction = if_else(s4_change > 0, "Positive", "Negative"),
    
    s3_scores_big_change = if_else(abs(s3_change) > 0.05, "Yes", "No"),
    s4_scores_big_change = if_else(abs(s4_change) > 0.05, "Yes", "No"),
    
    s3_match_long = if_else(s3_direction == long_direction, "Yes", "No", missing = "No data"),
    s4_match_long = if_else(s4_direction == long_direction, "Yes", "No", missing = "No data")
  ) %>%
  rowwise() %>%
  mutate(
    # Select minimum-change scenario between s3 and s4
    min_scenario = case_when(
      s3_change == s4_change ~ "s3_change",
      min(s3_change, s4_change, na.rm = TRUE) == s3_change ~ "s3_change",
      min(s3_change, s4_change, na.rm = TRUE) == s4_change ~ "s4_change",
      is.na(scores_2023) ~ "s3_change",
      is.na(min(s3_change, s4_change)) ~ "No data"
    ),
    
    # Apply selection logic
    scenario_stage2 = case_when(
      s3_match_long == "Yes" & s4_match_long == "No" ~ "Scenario 3",
      s3_match_long == "No" & s4_match_long == "Yes" ~ "Scenario 4",
      min_scenario == "s3_change" ~ "Scenario 3",
      min_scenario == "s4_change" ~ "Scenario 4"
    ),
    
    # Output selected score, change, direction, and large change flag
    scores_stage2 = if_else(scenario_stage2 == "Scenario 3", s3_final, s4_final),
    scores_change_stage2 = if_else(scenario_stage2 == "Scenario 3", s3_change, s4_change),
    scores_direction_stage2 = if_else(scenario_stage2 == "Scenario 3", s3_direction, s4_direction),
    scores_big_change_stage2 = if_else(scenario_stage2 == "Scenario 3", s3_scores_big_change, s4_scores_big_change)
  ) %>%
  ungroup() %>%
  select(
    country, variables, long_direction, ends_with("stage1"),
    ends_with("stage2"), scores_2023, scores_2024, scores_change, total_counts
  )

### Stage 3: Compare stage 1 vs 2 ------------------------------------------------------------------------------------------------

qrq_final <- qrq_stage2 %>%
  mutate(
    # Evaluate agreement between direction of Stage 1 and Stage 2 with the benchmark
    stage1_match_long = if_else(scores_direction_stage1 == long_direction, "Yes", "No", missing = "No data"),
    stage2_match_long = if_else(scores_direction_stage2 == long_direction, "Yes", "No", missing = "No data")
  ) %>%
  rowwise() %>%
  mutate(
    # Determine which stage involves the smaller change
    min_scenario = case_when(
      scores_change_stage1 == scores_change_stage2 ~ "scores_change_stage1",
      min(scores_change_stage1, scores_change_stage2, na.rm = TRUE) == scores_change_stage1 ~ "scores_change_stage1",
      min(scores_change_stage1, scores_change_stage2, na.rm = TRUE) == scores_change_stage2 ~ "scores_change_stage2",
      is.na(scores_2023) ~ "scores_change_stage1",
      is.na(min(scores_change_stage1, scores_change_stage2)) ~ "No data"
    ),
    
    # Final decision: which scenario to use
    scenario_final = case_when(
      stage1_match_long == "Yes" & stage2_match_long == "No" ~ scenario_stage1,
      stage1_match_long == "No" & stage2_match_long == "Yes" ~ scenario_stage2,
      min_scenario == "scores_change_stage1" ~ scenario_stage1,
      min_scenario == "scores_change_stage2" ~ scenario_stage2
    ),
    
    # Extract final values
    scores_final = if_else(scenario_final == scenario_stage1, scores_stage1, scores_stage2),
    scores_change_final = if_else(scenario_final == scenario_stage1, scores_change_stage1, scores_change_stage2),
    scores_direction_final = if_else(scenario_final == scenario_stage1, scores_direction_stage1, scores_direction_stage2),
    scores_big_change_final = if_else(scenario_final == scenario_stage1, scores_big_change_stage1, scores_big_change_stage2)
  ) %>%
  ungroup() %>%
  select(
    country, variables, long_direction, ends_with("final"),
    scores_2023, scores_2024, scores_change, total_counts
  )

# ## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ##
# ## 4.  Data Analysis                                                                                     ----
# ##
# ## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# options(scipen = 999)

# qrq_scores_analysis <- qrq_final %>%
#   mutate(
#     diff_qrq = abs(scores_2024 - scores_final),
#     level = case_when(
#       total_counts < 41 ~ "Low counts",
#       total_counts >= 41 & total_counts < 61 ~ "Medium counts",
#       total_counts >= 61 ~ "High counts"
#     )
#   )
# 
# 
# # Create the histogram
# p <- ggplot(data = qrq_scores_analysis, aes(x = diff_qrq)) +
#   geom_histogram(
#     binwidth = 0.001,       # Adjust bin width as needed
#     fill = "#0072B2",      # Blue color for bars
#     color = "white",       # White borders for better visibility
#     boundary = 0           # Align bins at 0
#   ) +
#   scale_x_continuous(breaks = seq(0,0.1,0.001),
#                      limits = c(0, 0.1)
#                      ) +
#   labs(
#     title = "Distribution of Score Differences",
#     x = "Difference in Scores (|2024 - Final|)",
#     y = "Number of Observations"
#   ) +
#   theme_minimal() +
#   theme(
#     text = element_text(family = "Lato"),
#     plot.title = element_text(face = "bold", size = 14),
#     axis.title = element_text(face = "bold"),
#     axis.text = element_text(angle = 90)
#   );p
# 
# # ggsave(plot = p, filename = "Histograma.svg", width = 8.5, height = 5.5)
# 
# "%!in%" <- compose("!", "%in%")
# data2plot <- qrq_scores_analysis %>%
#   filter(variables %!in% "ROLI") %>%
#   mutate(
#     counter = 1
#   ) %>%
#   group_by(scenario_final) %>%
#   summarise(
#     value = sum(counter, na.rm = T)
#   ) %>%
#   drop_na() %>%
#   mutate(
#     proportion = round(value/sum(value)*100, 0)
#   )
# 
# p2 <- ggplot(data = data2plot,
#              aes(x      = scenario_final,
#                  y = proportion,
#                  label = paste0(proportion, "%")
#              )
# ) +
#   geom_col(alpha = 0.5,
#            position = "identity",
#            colour = "white",
#            fill = "#0072B2")+
#   geom_text(size = 2.811678,
#             vjust = -1,
#             show.legend = F)+
#   scale_y_continuous(breaks = seq(0,70,10),
#                      limits = c(0, 70)) +
#   labs(
#     y         = " ",
#     x         = " "
#   ) +
#   theme(
#     axis.ticks         = element_blank(),
#     plot.margin        = unit(c(2.5, 7.5, 7.5, 2.5), "mm"),
#     panel.background   = element_rect(fill = "white",
#                                       size = 2),
#     panel.grid.major   = element_line(size     = 0.5,
#                                       colour   = "grey93",
#                                       linetype = "solid"),
#     panel.grid.minor   = element_blank(),
#     legend.position    = "top"
#   );p2

# ggsave(plot = p2, filename = "Scenarios.svg", width = 8.5, height = 5.5)
# 
# 
# qrq_big_diff <- qrq_scores_analysis %>%
#   
# 
# qrq_system_results <- qrq_scores_analysis %>%
#   group_by(variables) %>%
#   summarise(
#     across(
#       starts_with("diff"),
#       ~mean(.x, na.rm = T)
#     )
#   ) %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~round(.x,5)
#     )
#   ) %>%
#   filter(variables %!in% "ROLI")
# 
# qrq_system_results <- qrq_scores_analysis %>%
#   group_by(variables, level) %>%
#   summarise(
#     across(
#       starts_with("diff"),
#       ~mean(.x, na.rm = T)
#     )
#   ) %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~round(.x,5)
#     )
#   ) %>%
#   filter(variables %!in% "ROLI") %>%
#   pivot_wider(id_cols = c(variables), names_from = level, values_from = diff_qrq) %>%
#   select(variables, `High counts`, `Medium counts`, `Low counts`)
# 
# 
# qrq_system_results <- qrq_scores_analysis %>%
#   mutate(
#     match_direction = if_else(long_direction == scores_direction_final, "Yes", "No"),
#     final_direction = if_else(scores_change > 0, "Positive", "Negative"),
#     final_match = if_else(final_direction == scores_direction_final, "Yes", "No")
#   )
# 
# qrq_system_results <- qrq_scores_analysis %>%
#   mutate(
#     match_direction = if_else(long_direction == scores_direction_final, "Yes", "No", "No data")
#   ) %>%
#   group_by(variables, level, match_direction) %>%
#   summarise(
#     across(
#       starts_with("diff"),
#       ~mean(.x, na.rm = T)
#     )
#   ) %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~round(.x,5)
#     )
#   ) %>%
#   filter(variables %!in% "ROLI") %>%
#   pivot_wider(id_cols = c(variables, match_direction), names_from = level, values_from = diff_qrq) %>%
#   select(variables, match_direction, `High counts`, `Medium counts`, `Low counts`) %>%
#   drop_na() %>%
#   arrange(match_direction) %>%
#   filter(
#     match_direction != "No data"
#   )
# 
# ### +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ###
# ### Analisis Factor                                                                            ----
# ###
# ### +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 
# "%!in%" <- compose("!","%in%")
# 
# qrq_system <- qrq_scores_2024 %>%
#   left_join(qrq_s1, by = c("country", "variables")) %>%
#   left_join(qrq_s2, by = c("country", "variables")) %>%
#   left_join(qrq_s3, by = c("country", "variables")) %>%
#   left_join(qrq_s4, by = c("country", "variables")) %>%
#   left_join(qrq_s5, by = c("country", "variables")) %>%
#   left_join(qrq_country_counts, by = "country")
# 
# qrq_system <- qrq_system %>%
#   mutate(
#     diff_s1 = scores_2024 - scores_s1,
#     diff_s2 = scores_2024 - scores_s2,
#     diff_s3 = scores_2024 - scores_s3,
#     diff_s4 = scores_2024 - scores_s4,
#     diff_s5 = scores_2024 - scores_s5
#   ) %>%
#   mutate(
#     level = 
#       case_when(
#         total_counts < 41 ~ "Low counts",
#         total_counts > 40   & total_counts < 61 ~ "Medium counts",
#         total_counts > 60 ~ "High counts"
#       )
#   )
# 
# writexl::write_xlsx(qrq_system, path = "diff_scores_2024.xlsx")  
# 
# qrq_diff <- qrq_system %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~abs(.x)
#     ),
#     across(
#       starts_with("diff"),
#       ~if_else(is.na(scores_2024) == T, NA_real_, .x)
#     )
#   ) %>%
#   rowwise() %>%
#   mutate(
#     diff_best_scenario = 
#       if_else(
#         is.na(scores_2024) == T, NA_real_,
#         min(c(diff_s1, diff_s2, diff_s3, diff_s4, diff_s5), na.rm = T)
#         ),
#     best_scenario = 
#       case_when(
#         diff_best_scenario == diff_s1 ~ "Scenario 1",
#         diff_best_scenario == diff_s2 ~ "Scenario 2",
#         diff_best_scenario == diff_s3 ~ "Scenario 3",
#         diff_best_scenario == diff_s4 ~ "Scenario 4",
#         diff_best_scenario == diff_s5 ~ "Scenario 5"
#       )
#   ) %>%
#   mutate(
#     score_best_scenario = 
#       case_when(
#         best_scenario == "Scenario 1" ~ scores_s1,
#         best_scenario == "Scenario 2" ~ scores_s2,
#         best_scenario == "Scenario 3" ~ scores_s3,
#         best_scenario == "Scenario 4" ~ scores_s4,
#         best_scenario == "Scenario 5" ~ scores_s5
#       )
#   ) %>%
#   group_by(country) %>%
#   mutate(ROLI_best_scenario = mean(score_best_scenario, na.rm = T)) %>%
#   ungroup()
# 
# p <- ggplot(data = qrq_diff %>%
#               filter(variables %!in% "ROLI"), 
#             aes(x      = diff_best_scenario
#                 #fill   = status)
#                 )
#             )+ 
#   geom_histogram(alpha = 0.5, 
#                  position = "identity",
#                  colour = "white") +
#   scale_x_continuous(breaks = seq(0,0.15,0.01)) +
#   scale_y_continuous(limits = c(0,500),
#                      breaks = seq(0,500,50)) +
#   labs(
#     y         = "Number of factors",
#     x         = "Differences in scores"
#   ) +
#   theme(
#     axis.ticks         = element_blank(),
#     plot.margin        = unit(c(2.5, 7.5, 7.5, 2.5), "mm"),
#     panel.background   = element_rect(fill = "white",
#                                       size = 2),
#     panel.grid.major   = element_line(size     = 0.5,
#                                       colour   = "grey93",
#                                       linetype = "solid"),
#     panel.grid.minor   = element_blank(),
#     legend.position    = "top"
#   );p
# ggsave(plot = p, filename = "Histograma.svg", width = 8.5, height = 5.5)
# 
# data2plot <- qrq_diff %>%
#   filter(variables %!in% "ROLI") %>%
#   mutate(
#     counter = 1
#   ) %>%
#   group_by(best_scenario) %>%
#   summarise(
#     value = sum(counter, na.rm = T)
#   ) %>%
#   drop_na() %>%
#   mutate(
#     proportion = round(value/sum(value)*100, 0)
#   )
# 
# p2 <- ggplot(data = data2plot,
#              aes(x      = best_scenario,
#                  y = proportion,
#                  label = paste0(proportion, "%")
#              )
#              ) + 
#   geom_col(alpha = 0.5, 
#            position = "identity",
#            colour = "white")+
#   geom_text(size = 2.811678,
#             vjust = -1, 
#             show.legend = F)+
#   scale_y_continuous(breaks = seq(0,40,10),
#                      limits = c(0, 40)) +
#   labs(
#     y         = " ",
#     x         = " "
#   ) +
#   theme(
#     axis.ticks         = element_blank(),
#     plot.margin        = unit(c(2.5, 7.5, 7.5, 2.5), "mm"),
#     panel.background   = element_rect(fill = "white",
#                                       size = 2),
#     panel.grid.major   = element_line(size     = 0.5,
#                                       colour   = "grey93",
#                                       linetype = "solid"),
#     panel.grid.minor   = element_blank(),
#     legend.position    = "top"
#   );p2
#   
# ggsave(plot = p2, filename = "Scenarios.svg", width = 8.5, height = 5.5)
# 
# qrq_system_results <- qrq_diff %>%
#   group_by(variables) %>%
#   summarise(
#     across(
#       starts_with("diff"),
#       ~mean(.x, na.rm = T)
#     )
#   ) %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~round(.x*100,2)
#     )
#   ) %>%
#   mutate(
#     diff_raw = diff_best_scenario - diff_s1
#   ) %>%
#   filter(variables %!in% "ROLI")
# 
# ROLI_final <- qrq_diff %>%
#   filter(variables %in% "ROLI") %>%
#   select(country, variables, scores_2024, score_best_scenario, ROLI_best_scenario) %>%
#   mutate(
#     diff_roli = scores_2024 - ROLI_best_scenario,
#     diff_roli = abs(diff_roli)
#   ) %>%
#   summarise(
#     diff_roli = mean(diff_roli, na.rm = T),
#     diff_roli = round(diff_roli*100, 3)
#   )
# 
# qrq_system_results_ROLI <- qrq_diff %>%
#   group_by(variables) %>%
#   summarise(
#     across(
#       starts_with("diff"),
#       ~mean(.x, na.rm = T)
#     )
#   ) %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~round(.x*100,3)
#     )
#   ) %>%
#   filter(variables %in% "ROLI") %>%
#   cbind(ROLI_final) %>%
#   mutate(
#     diff_raw = diff_roli - diff_s1
#   ) 
# 
# 
# 
# 
# ROLI_final_level <- qrq_diff %>%
#   filter(variables %in% "ROLI") %>%
#   select(country, variables, scores_2024, score_best_scenario, ROLI_best_scenario, level) %>%
#   group_by(level) %>%
#   mutate(
#     diff_roli = scores_2024 - ROLI_best_scenario,
#     diff_roli = abs(diff_roli)
#   ) %>%
#   summarise(
#     diff_roli = mean(diff_roli, na.rm = T),
#     diff_roli = round(diff_roli*100, 3)
#   )
# 
# qrq_system_results_ROLI_level <- qrq_diff %>%
#   group_by(variables, level) %>%
#   summarise(
#     across(
#       starts_with("diff"),
#       ~mean(.x, na.rm = T)
#     )
#   ) %>%
#   mutate(
#     across(
#       starts_with("diff"),
#       ~round(.x*100,3)
#     )
#   ) %>%
#   filter(variables %in% "ROLI") %>%
#   cbind(ROLI_final_level) %>%
#   mutate(
#     diff_raw = diff_roli - diff_s1
#   ) 
