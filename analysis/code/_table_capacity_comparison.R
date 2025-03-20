# Código para criar tabela comparativa de capacidade administrativa por estados
# Comparando municípios de baixa (Low) e alta (High) capacidade administrativa
# Para estados tratados (PE, BA, PB, CE, MA) e nunca tratados
# Apenas para o ano de 2006

library(dplyr)
library(tidyr)
library(xtable)

# 0. Filtrar apenas para o ano de 2006
main_data <- main_data %>%
  filter(year == 2006)

# 1. Calcular o número de funcionários per capita (por 1000 habitantes) para toda a base
main_data <- main_data %>%
  mutate(
    employees_per_1000 = (total_func_pub_munic/population_muni)*1000
  )

# 2. Calcular mediana da porcentagem de funcionários com ensino superior para toda a base
p50_perc_sup <- median(main_data$perc_superior, na.rm = TRUE)

# 3. Criar variável de alta/baixa capacidade
main_data <- main_data %>%
  mutate(
    capacity = ifelse(!is.na(perc_superior) & perc_superior > p50_perc_sup, 
                      "High Capacity", "Low Capacity")
  )

# 4. Criar variável para agrupar estados
treated_states <- c("PE", "BA", "PB", "CE", "MA")
main_data <- main_data %>%
  mutate(
    state_group = ifelse(state %in% treated_states, state, "Never Treated")
  )

# 5. Função para calcular estatísticas e p-valores por estado e capacidade
calculate_state_stats <- function(state_data) {
  # Separar por capacidade
  high_cap <- filter(state_data, capacity == "High Capacity")
  low_cap <- filter(state_data, capacity == "Low Capacity")
  
  # Calcular o número de municípios em cada grupo
  n_high <- nrow(high_cap)
  n_low <- nrow(low_cap)
  
  # Lista de variáveis para analisar
  variables <- c(
    "total_vinculos_munic",
    "log_pib_municipal_per_capita", 
    "population_muni",
    "pop_density_municipality", 
    "distancia_delegacia_km",
    "employees_per_1000",
    "perc_superior"
  )
  
  # Inicializar dataframe de resultados
  results <- data.frame(
    variable = character(),
    low_mean = numeric(),
    high_mean = numeric(),
    p_value = numeric(),
    p_value_fmt = character(),
    n_low = numeric(),
    n_high = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Calcular estatísticas para cada variável
  for (var in variables) {
    if (length(high_cap[[var]]) > 0 && length(low_cap[[var]]) > 0) {
      # Calcular médias
      low_mean <- mean(low_cap[[var]], na.rm = TRUE)
      high_mean <- mean(high_cap[[var]], na.rm = TRUE)
      
      # Realizar teste t
      t_result <- tryCatch({
        t.test(high_cap[[var]], low_cap[[var]])
      }, error = function(e) {
        list(p.value = NA)
      })
      
      # Formatar p-valor
      p_value <- t_result$p.value
      p_value_fmt <- ifelse(is.na(p_value), "NA",
                            ifelse(p_value < 0.001, "<0.001",
                                   ifelse(p_value < 0.01, "<0.01",
                                          ifelse(p_value < 0.05, "<0.05",
                                                 as.character(round(p_value, 3))))))
      
      # Adicionar ao dataframe de resultados
      results <- rbind(results, data.frame(
        variable = var,
        low_mean = low_mean,
        high_mean = high_mean,
        p_value = p_value,
        p_value_fmt = p_value_fmt,
        n_low = n_low,
        n_high = n_high,
        stringsAsFactors = FALSE
      ))
    }
  }
  
  # Adicionar uma linha especial para o número de municípios
  results <- rbind(results, data.frame(
    variable = "n_municipalities",
    low_mean = n_low,
    high_mean = n_high,
    p_value = NA,
    p_value_fmt = NA,
    n_low = n_low,
    n_high = n_high,
    stringsAsFactors = FALSE
  ))
  
  return(results)
}

# 6. Aplicar função para cada estado
states_to_analyze <- c(treated_states, "Never Treated")
all_results <- list()

for (state_name in states_to_analyze) {
  state_data <- filter(main_data, state_group == state_name)
  if (nrow(state_data) > 0) {
    state_results <- calculate_state_stats(state_data)
    state_results$state <- state_name
    all_results[[state_name]] <- state_results
  }
}

# 7. Combinar resultados
combined_results <- do.call(rbind, all_results)

# 8. Renomear variáveis para nomes mais apresentáveis
variable_names <- c(
  "total_vinculos_munic" = "Formal Employment",
  "log_pib_municipal_per_capita" = "GDP per capita (log)",
  "population_muni" = "Population",
  "pop_density_municipality" = "Population Density", 
  "distancia_delegacia_km" = "Distance to Police Station (km)",
  "employees_per_1000" = "Public Employees per 1,000 inhabitants",
  "perc_superior" = "Percentage with College Degree",
  "n_municipalities" = "Number of Municipalities"
)

combined_results$variable_name <- variable_names[combined_results$variable]

# 9. Arredondar valores numéricos
combined_results <- combined_results %>%
  mutate(
    low_mean = case_when(
      variable == "total_vinculos_munic" ~ round(low_mean, 1),
      variable == "log_pib_municipal_per_capita" ~ round(low_mean, 2),
      variable == "population_muni" ~ round(low_mean, 0),
      variable == "pop_density_municipality" ~ round(low_mean, 2),
      variable == "distancia_delegacia_km" ~ round(low_mean, 2),
      variable == "employees_per_1000" ~ round(low_mean, 2),
      variable == "perc_superior" ~ round(low_mean, 2),
      variable == "n_municipalities" ~ round(low_mean, 0),
      TRUE ~ low_mean
    ),
    high_mean = case_when(
      variable == "total_vinculos_munic" ~ round(high_mean, 1),
      variable == "log_pib_municipal_per_capita" ~ round(high_mean, 2),
      variable == "population_muni" ~ round(high_mean, 0),
      variable == "pop_density_municipality" ~ round(high_mean, 2),
      variable == "distancia_delegacia_km" ~ round(high_mean, 2),
      variable == "employees_per_1000" ~ round(high_mean, 2),
      variable == "perc_superior" ~ round(high_mean, 2),
      variable == "n_municipalities" ~ round(high_mean, 0),
      TRUE ~ high_mean
    )
  )

# 10. Criar tabela LaTeX
# Primeiro, vamos estruturar os dados por estado e variável
latex_data <- combined_results %>%
  dplyr::select(state, variable_name, low_mean, high_mean, p_value_fmt) %>%
  dplyr::arrange(variable_name, state)

# Gerar código LaTeX
latex_code <- "\\begin{table}[htbp]
\\centering
\\caption{Administrative Capacity Comparison by State (2006)}
\\label{tab:capacity_comparison_2006}
\\begin{threeparttable}
\\small
\\begin{adjustbox}{max width=\\textwidth}
\\begin{tabular}{lcccccccccccc}
\\toprule
& \\multicolumn{2}{c}{PE} & \\multicolumn{2}{c}{BA} & \\multicolumn{2}{c}{PB} & \\multicolumn{2}{c}{CE} & \\multicolumn{2}{c}{MA} & \\multicolumn{2}{c}{Never Treated} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7} \\cmidrule(lr){8-9} \\cmidrule(lr){10-11} \\cmidrule(lr){12-13}
Variable & Low & High & Low & High & Low & High & Low & High & Low & High & Low & High \\\\
\\midrule\n"

# Variáveis na ordem que queremos apresentar
ordered_variables <- c(
  "Number of Municipalities",
  "Formal Employment",
  "GDP per capita (log)",
  "Population",
  "Population Density", 
  "Distance to Police Station (km)",
  "Public Employees per 1,000 inhabitants",
  "Percentage with College Degree"
)

# Adicionar cada variável à tabela
for (var in ordered_variables) {
  var_data <- filter(latex_data, variable_name == var)
  
  # Linha com os valores
  line <- paste0(var)
  
  # Adicionar valores para cada estado
  for (state_name in states_to_analyze) {
    state_var_data <- filter(var_data, state == state_name)
    
    if (nrow(state_var_data) > 0) {
      low_val <- formatC(state_var_data$low_mean, format = "f", digits = ifelse(var %in% c("Population", "Number of Municipalities"), 0, 2))
      high_val <- formatC(state_var_data$high_mean, format = "f", digits = ifelse(var %in% c("Population", "Number of Municipalities"), 0, 2))
      p_val <- state_var_data$p_value_fmt
      
      # Adicionar asterisco se p < 0.05 (exceto para o número de municípios)
      high_val_fmt <- ifelse(!is.na(p_val) && p_val %in% c("<0.05", "<0.01", "<0.001") && var != "Number of Municipalities", 
                             paste0(high_val, "$^{*}$"), 
                             high_val)
      
      line <- paste0(line, " & ", low_val, " & ", high_val_fmt)
    } else {
      line <- paste0(line, " & - & -")
    }
  }
  
  # Finalizar linha
  latex_code <- paste0(latex_code, line, " \\\\\n")
}

# Finalizar tabela
latex_code <- paste0(latex_code, "\\bottomrule
\\end{tabular}
\\end{adjustbox}
\\begin{tablenotes}
\\small
\\item \\textit{Note:} This table compares municipalities with low and high administrative capacity (below and above median percentage of employees with college degree) across different states for 2006. 
\\item $^{*}$ indicates statistically significant difference (p $<$ 0.05) between low and high capacity municipalities.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}")

# Salvar a tabela em um arquivo .tex
output_file <- paste0(GITHUB_PATH, "analysis/output/tables/administrative_capacity_by_state_2006.tex")
writeLines(latex_code, output_file)

cat("Tabela LaTeX de comparação de capacidade administrativa por estado (2006) salva em:", output_file)