# Load necessary packages
library(dplyr)
library(xtable)
library(knitr)

# Remove specific municipalities
main_data <- main_data[!(main_data$municipality_code == 2300000 | 
                           main_data$municipality_code == 2600000), ]

# Create treatment variable
treated_states <- c("PE", "BA", "PB", "CE", "MA")
main_data$treated <- main_data$state %in% treated_states

# Create new variables
main_data <- main_data %>%
  mutate(
    # Percentage of municipal public employees with higher education relative to total
    func_pub_superior_percent_2006 = ifelse(year == 2006, (funcionarios_superior/total_func_pub_munic)*100, NA),
    
    # Schools and health facilities in 2006
    schools_2006 = ifelse(year == 2006, total_estabelecimentos_educ, NA),
    health_2006 = ifelse(year == 2006, total_estabelecimentos_saude, NA))

# Create function to format numbers
format_num <- function(x) {
  format(round(x, 2), big.mark = ",", scientific = FALSE)
}

# List of variables for analysis
vars_list <- list(
  # Dependent Variables
  "Homicide Rate per 100,000 inhabitants" = "taxa_homicidios_total_por_100mil_munic",
  
  # Local Capacity
  "Percentage of Municipality Employees with Higher Education (2006)" = "func_pub_superior_percent_2006",
  
  # Police Station Variable
  "Distance to Nearest Police Station" = "distancia_delegacia_km",
  
  # Time-Varying Controls
  "Population" = "population_muni",
  "Log(GDP per capita)" = "log_pib_municipal_per_capita",
  "Number of Schools (2006)" = "schools_2006",
  "Number of Health Facilities (2006)" = "health_2006"
)

# Function to calculate statistics by group
calc_stats <- function(data, var_name) {
  var <- data[[var_name]]
  c(
    format_num(mean(var, na.rm = TRUE)),
    format_num(median(var, na.rm = TRUE)),
    format_num(sd(var, na.rm = TRUE))
  )
}

# Create data frame with statistics for all groups
stats_df <- data.frame(
  Variable = names(vars_list),
  # All
  Mean_All = NA,
  Median_All = NA,
  SD_All = NA,
  # Treated
  Mean_Treated = NA,
  Median_Treated = NA,
  SD_Treated = NA,
  # Never Treated
  Mean_Never = NA,
  Median_Never = NA,
  SD_Never = NA
)

# Fill statistics
for(i in 1:length(vars_list)) {
  # All
  stats_all <- calc_stats(main_data, vars_list[[i]])
  stats_df[i, c("Mean_All", "Median_All", "SD_All")] <- stats_all
  
  # Treated
  stats_treated <- calc_stats(filter(main_data, treated), vars_list[[i]])
  stats_df[i, c("Mean_Treated", "Median_Treated", "SD_Treated")] <- stats_treated
  
  # Never Treated
  stats_never <- calc_stats(filter(main_data, !treated), vars_list[[i]])
  stats_df[i, c("Mean_Never", "Median_Never", "SD_Never")] <- stats_never
}

# Calculate number of unique municipalities by group
n_munic_all <- length(unique(main_data$municipality_code))
n_munic_treated <- length(unique(filter(main_data, treated)$municipality_code))
n_munic_never <- length(unique(filter(main_data, !treated)$municipality_code))

# Create LaTeX file
latex_output <- "
\\begin{table}[!htbp]
\\centering
\\caption{Descriptive Statistics by Treatment Status}
\\begin{adjustbox}{max width=\\textwidth}
\\begin{tabular}{lccccccccc}
\\toprule
& \\multicolumn{3}{c}{All} & \\multicolumn{3}{c}{Treated} & \\multicolumn{3}{c}{Never Treated} \\\\
\\cmidrule(lr){2-4} \\cmidrule(lr){5-7} \\cmidrule(lr){8-10}
Variable & Mean & Median & SD & Mean & Median & SD & Mean & Median & SD \\\\
\\midrule
\\multicolumn{10}{l}{\\textit{Panel A: Dependent Variables}} \\\\"

# Add Dependent Variables (index 1)
latex_output <- paste0(latex_output, "\n",
                       stats_df$Variable[1], " & ",
                       stats_df$Mean_All[1], " & ",
                       stats_df$Median_All[1], " & ",
                       stats_df$SD_All[1], " & ",
                       stats_df$Mean_Treated[1], " & ",
                       stats_df$Median_Treated[1], " & ",
                       stats_df$SD_Treated[1], " & ",
                       stats_df$Mean_Never[1], " & ",
                       stats_df$Median_Never[1], " & ",
                       stats_df$SD_Never[1], " \\\\")

# Add Local Capacity (index 2)
latex_output <- paste0(latex_output, "
\\midrule
\\multicolumn{10}{l}{\\textit{Panel B: Local Capacity Variables}} \\\\")

latex_output <- paste0(latex_output, "\n",
                       stats_df$Variable[2], " & ",
                       stats_df$Mean_All[2], " & ",
                       stats_df$Median_All[2], " & ",
                       stats_df$SD_All[2], " & ",
                       stats_df$Mean_Treated[2], " & ",
                       stats_df$Median_Treated[2], " & ",
                       stats_df$SD_Treated[2], " & ",
                       stats_df$Mean_Never[2], " & ",
                       stats_df$Median_Never[2], " & ",
                       stats_df$SD_Never[2], " \\\\")

# Add Police Station Variable (index 3)
latex_output <- paste0(latex_output, "\n",
                       stats_df$Variable[3], " & ",
                       stats_df$Mean_All[3], " & ",
                       stats_df$Median_All[3], " & ",
                       stats_df$SD_All[3], " & ",
                       stats_df$Mean_Treated[3], " & ",
                       stats_df$Median_Treated[3], " & ",
                       stats_df$SD_Treated[3], " & ",
                       stats_df$Mean_Never[3], " & ",
                       stats_df$Median_Never[3], " & ",
                       stats_df$SD_Never[3], " \\\\")

# Add Time-Varying Controls (indices 4-7)
latex_output <- paste0(latex_output, "
\\midrule
\\multicolumn{10}{l}{\\textit{Panel C: Time-Varying Variables}} \\\\")

for(i in 4:7) {
  latex_output <- paste0(latex_output, "\n",
                         stats_df$Variable[i], " & ",
                         stats_df$Mean_All[i], " & ",
                         stats_df$Median_All[i], " & ",
                         stats_df$SD_All[i], " & ",
                         stats_df$Mean_Treated[i], " & ",
                         stats_df$Median_Treated[i], " & ",
                         stats_df$SD_Treated[i], " & ",
                         stats_df$Mean_Never[i], " & ",
                         stats_df$Median_Never[i], " & ",
                         stats_df$SD_Never[i], " \\\\")
}

# Add number of municipalities
latex_output <- paste0(latex_output, "
\\midrule
Number of Municipalities & \\multicolumn{3}{c}{", n_munic_all, "} & \\multicolumn{3}{c}{", n_munic_treated, "} & \\multicolumn{3}{c}{", n_munic_never, "} \\\\
\\bottomrule
\\end{tabular}
\\end{adjustbox}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} This table presents descriptive statistics for the main variables used in the analysis, separated by treatment status. Treated municipalities are those located in the states of PE, BA, PB, CE, and MA. All variables are measured at the municipality level in 2006. Percentage of municipality employees with higher education is calculated as the number of municipality employees with higher education divided by the total number of municipality employees and multiplied by 100.
\\end{tablenotes}
\\end{table}")

# Save the table to a .tex file
writeLines(latex_output, "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/table_A.3.tex")