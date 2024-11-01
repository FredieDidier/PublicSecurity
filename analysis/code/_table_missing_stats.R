library(dplyr)
library(stargazer)

# Filtrar códigos específicos
main_data <- main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000)

# Create expanded grid with all possible combinations
expand_grid <- expand.grid(
  municipality_code = unique(main_data$municipality_code),
  year = unique(main_data$year)
)

# Treated states (IBGE codes)
treated_states <- c("26", "29", "25", "23", "21")

# Join data and calculate statistics
result <- expand_grid %>%
  left_join(main_data, by = c("municipality_code", "year")) %>%
  filter(!is.na(municipality_code) & !is.na(year)) %>%
  mutate(
    state_code = substr(municipality_code, 1, 2),
    is_treated = state_code %in% treated_states
  )

# Create summary statistics table
missing_stats <- data.frame(
  "Category" = c(
    "Total",
    "Treated",
    "Not Treated"
  ),
  "Observations" = c(
    sum(is.na(result$state)),
    sum(is.na(result$state) & result$is_treated),
    sum(is.na(result$state) & !result$is_treated)
  ),
  "States" = c(
    n_distinct(substr(result$municipality_code[is.na(result$state)], 1, 2)),
    n_distinct(substr(result$municipality_code[is.na(result$state) & result$is_treated], 1, 2)),
    n_distinct(substr(result$municipality_code[is.na(result$state) & !result$is_treated], 1, 2))
  ),
  "Municipalities" = c(
    n_distinct(result$municipality_code[is.na(result$state)]),
    n_distinct(result$municipality_code[is.na(result$state) & result$is_treated]),
    n_distinct(result$municipality_code[is.na(result$state) & !result$is_treated])
  )
)

# Generate LaTeX file
sink(paste0(GITHUB_PATH, "analysis/output/tables/missing_stats.tex"))

# LaTeX document header
cat("\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\usepackage{booktabs}
\\usepackage{dcolumn}
\\usepackage{float}
\\usepackage[margin=1in]{geometry}
\\begin{document}
")

# Generate table with stargazer
stargazer(
  missing_stats,
  title = "Missing Data Statistics",
  summary = FALSE,
  rownames = FALSE,
  header = FALSE,
  digits = 0,
  float = TRUE,
  font.size = "normalsize",
  column.labels = c("Category", "Observations", "States", "Municipalities")
)

# Close LaTeX document
cat("\\end{document}")
sink()

###

# Calculate missing statistics for population_2000_muni
missing_stats <- data.frame(
  "Category" = c(
    "Total",
    "Treated",
    "Not Treated"
  ),
  "Observations" = c(
    sum(is.na(result$population_2000_muni)),
    sum(is.na(result$population_2000_muni) & result$is_treated),
    sum(is.na(result$population_2000_muni) & !result$is_treated)
  ),
  "States" = c(
    n_distinct(substr(result$municipality_code[is.na(result$population_2000_muni)], 1, 2)),
    n_distinct(substr(result$municipality_code[is.na(result$population_2000_muni) & result$is_treated], 1, 2)),
    n_distinct(substr(result$municipality_code[is.na(result$population_2000_muni) & !result$is_treated], 1, 2))
  ),
  "Municipalities" = c(
    n_distinct(result$municipality_code[is.na(result$population_2000_muni)]),
    n_distinct(result$municipality_code[is.na(result$population_2000_muni) & result$is_treated]),
    n_distinct(result$municipality_code[is.na(result$population_2000_muni) & !result$is_treated])
  )
)

# Generate LaTeX file
sink(paste0(GITHUB_PATH, "analysis/output/tables/missing_stats_population_2000_muni.tex"))

# LaTeX document header
cat("\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\usepackage{booktabs}
\\usepackage{dcolumn}
\\usepackage{float}
\\usepackage[margin=1in]{geometry}
\\begin{document}
")

# Generate table with stargazer
stargazer(
  missing_stats,
  title = "Missing Data Statistics for Population 2000",
  summary = FALSE,
  rownames = FALSE,
  header = FALSE,
  digits = 0,
  float = TRUE,
  font.size = "normalsize",
  column.labels = c("Category", "Observations", "States", "Municipalities")
)

# Close LaTeX document
cat("\\end{document}")
sink()
