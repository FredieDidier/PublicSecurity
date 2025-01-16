# Carregar pacotes necessários
library(dplyr)
library(xtable)
library(knitr)

# Remover municípios específicos
main_data <- main_data[!(main_data$municipality_code == 2300000 | 
                           main_data$municipality_code == 2600000), ]

# Criar variável de tratamento
treated_states <- c("PE", "BA", "PB", "CE", "MA")
main_data$treated <- main_data$state %in% treated_states

# Criar as novas variáveis
main_data <- main_data %>%
  mutate(
    # Log da taxa de homicídios
    log_homicide_rate = log(taxa_homicidios_total_por_100mil_munic + 1),
    
    # Funcionários públicos em 2006 (absoluto e per capita)
    func_pub_2006 = ifelse(year == 2006, total_func_pub_munic, NA),
    log_func_pub_2006 = log(func_pub_2006),
    func_pub_per_1000_2006 = ifelse(year == 2006, (total_func_pub_munic/population_muni)*1000, NA),
    log_func_pub_per_1000_2006 = log(func_pub_per_1000_2006),
    
    # Escolas e estabelecimentos de saúde em 2006
    schools_2006 = ifelse(year == 2006, total_estabelecimentos_educ, NA),
    health_2006 = ifelse(year == 2006, total_estabelecimentos_saude, NA)
  )

# Criar função para formatar números
format_num <- function(x) {
  format(round(x, 2), big.mark = ",", scientific = FALSE)
}

# Lista de variáveis para análise
vars_list <- list(
  # Dependent Variables
  "Homicide Rate per 100,000 inhabitants" = "taxa_homicidios_total_por_100mil_munic",
  "Log(Homicide Rate per 100,000 inhabitants + 1)" = "log_homicide_rate",
  
  # Local Capacity
  "Number of Municipality Employees (2006)" = "func_pub_2006",
  "Log(Municipality Employees 2006)" = "log_func_pub_2006",
  "Municipality Employees per 1,000 inhabitants (2006)" = "func_pub_per_1000_2006",
  "Log(Municipality Employees per 1,000 inhabitants 2006)" = "log_func_pub_per_1000_2006",
  
  # Time-Varying Controls
  "Population" = "population_muni",
  "Log(GDP per capita)" = "log_pib_municipal_per_capita",
  "Number of Schools (2006)" = "schools_2006",
  "Number of Health Facilities (2006)" = "health_2006"
)

# Função para calcular estatísticas por grupo
calc_stats <- function(data, var_name) {
  var <- data[[var_name]]
  c(
    format_num(mean(var, na.rm = TRUE)),
    format_num(median(var, na.rm = TRUE)),
    format_num(sd(var, na.rm = TRUE))
  )
}

# Criar data frame com estatísticas para todos os grupos
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

# Preencher estatísticas
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

# Calcular número de municípios únicos por grupo
n_munic_all <- length(unique(main_data$municipality_code))
n_munic_treated <- length(unique(filter(main_data, treated)$municipality_code))
n_munic_never <- length(unique(filter(main_data, !treated)$municipality_code))

# Criar arquivo LaTeX
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

# Adicionar Dependent Variables (índices 1-2)
for(i in 1:2) {
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

# Adicionar Local Capacity (índices 3-6)
latex_output <- paste0(latex_output, "
\\midrule
\\multicolumn{10}{l}{\\textit{Panel B: Local Capacity Variables}} \\\\")

for(i in 3:6) {
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

# Adicionar Time-Varying Controls (índices 7-10)
latex_output <- paste0(latex_output, "
\\midrule
\\multicolumn{10}{l}{\\textit{Panel C: Time-Varying Variables}} \\\\")

for(i in 7:10) {
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

# Adicionar número de municípios
latex_output <- paste0(latex_output, "
\\midrule
Number of Municipalities & \\multicolumn{3}{c}{", n_munic_all, "} & \\multicolumn{3}{c}{", n_munic_treated, "} & \\multicolumn{3}{c}{", n_munic_never, "} \\\\
\\bottomrule
\\end{tabular}
\\end{adjustbox}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} This table presents descriptive statistics for the main variables used in the analysis, separated by treatment status. Treated municipalities are those located in the states of PE, BA, PB, CE, and MA. All variables are measured at the municipality level in 2006. Municipality employees per 1,000 inhabitants is calculated as the total number of municipality employees divided by population and multiplied by 1,000.
\\end{tablenotes}
\\end{table}")

# Salvar a tabela em um arquivo .tex
writeLines(latex_output, "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/descriptive_statistics_table.tex")


###
library(stargazer)

# Criar estatísticas básicas
total_stats <- main_data %>%
  summarise(
    n_estados = n_distinct(state),
    n_municipios = n_distinct(municipality_code)
  )

# Criar dataframe com informações do tratamento
treatment_info <- data.frame(
  treatment_year = c(2007, 2011, 2011, 2015, 2016),
  state = c("PE", "BA", "PB", "CE", "MA")
)

# Estatísticas por ano de tratamento
yearly_stats <- main_data %>%
  left_join(treatment_info, by = "state") %>%
  group_by(treatment_year) %>%
  summarise(
    treated_states = n_distinct(state),
    treated_munic = n_distinct(municipality_code)
  ) %>%
  arrange(treatment_year) %>%
  filter(!is.na(treatment_year))

# Estatísticas totais de tratados vs não tratados
total_treat_stats <- main_data %>%
  left_join(treatment_info, by = "state") %>%
  summarise(
    treated_states = n_distinct(state[!is.na(treatment_year)]),
    nontreated_states = n_distinct(state[is.na(treatment_year)]),
    treated_munic = n_distinct(municipality_code[!is.na(treatment_year)]),
    nontreated_munic = n_distinct(municipality_code[is.na(treatment_year)])
  )

# Criar dataframe para a tabela final
table_data <- data.frame(
  Category = c(
    "Total",
    "Treated since 2007",
    "Treated since 2011",
    "Treated since 2015",
    "Treated since 2016",
    "Total Treated",
    "Total Not Treated"
  ),
  States = c(
    total_stats$n_estados,
    yearly_stats$treated_states[yearly_stats$treatment_year == 2007],
    yearly_stats$treated_states[yearly_stats$treatment_year == 2011],
    yearly_stats$treated_states[yearly_stats$treatment_year == 2015],
    yearly_stats$treated_states[yearly_stats$treatment_year == 2016],
    total_treat_stats$treated_states,
    total_treat_stats$nontreated_states
  ),
  Municipalities = c(
    total_stats$n_municipios,
    yearly_stats$treated_munic[yearly_stats$treatment_year == 2007],
    yearly_stats$treated_munic[yearly_stats$treatment_year == 2011],
    yearly_stats$treated_munic[yearly_stats$treatment_year == 2015],
    yearly_stats$treated_munic[yearly_stats$treatment_year == 2016],
    total_treat_stats$treated_munic,
    total_treat_stats$nontreated_munic
  )
)

sink("/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/summary_stats.tex")

cat("\\documentclass{article}

% Pacotes necessários
\\usepackage[utf8]{inputenc}
\\usepackage{booktabs}
\\usepackage{dcolumn}
\\usepackage{float}
\\usepackage[margin=1in]{geometry}
\\usepackage{caption}

\\begin{document}
")

stargazer(table_data,
          type = "latex",
          title = "Distribution of Treatment",
          summary = FALSE,
          rownames = FALSE,
          header = FALSE,
          digits = 0,
          float = TRUE,
          font.size = "normalsize",
          covariate.labels = c("Category", "States", "Municipalities"),
          table.placement = "!htbp",
          style = "aer")

cat("\\end{document}")
sink()
