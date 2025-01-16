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
    
    # Funcionários públicos em 2006
    func_pub_2006 = ifelse(year == 2006, total_func_pub_munic, NA),
    log_func_pub_2006 = log(func_pub_2006),
    
    # Funcionários com ensino superior em 2006
    func_sup_2006 = ifelse(year == 2006, funcionarios_superior, NA),
    log_func_sup_2006 = log(func_sup_2006 + 1),
    
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
  "Number of Local-level Municipality Employees (2006)" = "func_pub_2006",
  "Log(Number of Local-level Municipality Employees)" = "log_func_pub_2006",
  "Number of Local-Level College-Educated Municipality Employees (2006)" = "func_sup_2006",
  "Log(Number of Local-Level College-Educated Municipality Employees + 1)" = "log_func_sup_2006",
  
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
\\begin{tabular}{lccccccccc}
\\hline\\hline
& \\multicolumn{3}{c}{All} & \\multicolumn{3}{c}{Treated} & \\multicolumn{3}{c}{Never Treated} \\\\
\\cline{2-4} \\cline{5-7} \\cline{8-10}
Variable & Mean & Median & Std. Dev. & Mean & Median & Std. Dev. & Mean & Median & Std. Dev. \\\\
\\hline
\\\\[-1.8ex]
\\multicolumn{10}{l}{\\textit{Panel A: Dependent Variables}} \\\\
\\hline"

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
\\\\[-1.8ex]
\\multicolumn{10}{l}{\\textit{Panel B: Local Capacity}} \\\\
\\hline")

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
\\\\[-1.8ex]
\\multicolumn{10}{l}{\\textit{Panel C: Time-Varying Controls}} \\\\
\\hline")

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
\\\\[-1.8ex]
\\hline
Number of Municipalities & \\multicolumn{3}{c}{", n_munic_all, "} & \\multicolumn{3}{c}{", n_munic_treated, "} & \\multicolumn{3}{c}{", n_munic_never, "} \\\\")

# Adicionar rodapé e fechamento
latex_output <- paste0(latex_output, "
\\hline\\hline
\\multicolumn{10}{p{1.8\\textwidth}}{\\footnotesize \\textit{Notes:} This table presents descriptive statistics for the main variables used in the analysis, separated by treatment status. Treated municipalities are those located in the states of PE, BA, PB, CE, and MA. All variables are measured at the municipality level. The number of municipality employees, college-educated employees, schools, and health facilities are measured in 2006.} \\\\
\\end{tabular}
\\label{tab:descriptive_stats}
\\end{table}")

# Salvar a tabela em um arquivo .tex
writeLines(latex_output, "/Users/fredie/Downloads/descriptive_statistics_table.tex")
