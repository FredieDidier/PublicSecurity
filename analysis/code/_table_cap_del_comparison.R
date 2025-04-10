# Código para criar uma tabela de distribuição das variáveis contínuas
# Comparando estados tratados e não tratados

library(dplyr)
library(tidyr)
library(xtable)

# 1. Filtrar apenas para o ano de 2006 (linha de base antes do tratamento)
balance_data <- main_data %>%
  filter(year == 2006)

# 2. Criar variável de tratamento
balance_data <- balance_data %>%
  mutate(
    treatment_status = case_when(
      state == "PE" ~ "Treated (2007)",
      state %in% c("BA", "PB") ~ "Treated (2011)",
      state == "CE" ~ "Treated (2015)",
      state == "MA" ~ "Treated (2016)",
      TRUE ~ "Never Treated"
    ),
    ever_treated = ifelse(state %in% c("PE", "BA", "PB", "CE", "MA"), "Treated", "Control")
  )

# 3. Variáveis de interesse
balance_vars <- c(
  "perc_superior",                # Capacidade administrativa
  "distancia_delegacia_km"        # Distância à delegacia
)

# 4. Função para calcular estatísticas descritivas detalhadas
calculate_distribution_stats <- function(data, var_name, group_var = "ever_treated") {
  result <- data %>%
    group_by(across(all_of(group_var))) %>%
    summarize(
      n = sum(!is.na(.data[[var_name]])),
      mean = mean(.data[[var_name]], na.rm = TRUE),
      sd = sd(.data[[var_name]], na.rm = TRUE),
      min = min(.data[[var_name]], na.rm = TRUE),
      p25 = quantile(.data[[var_name]], 0.25, na.rm = TRUE),
      median = quantile(.data[[var_name]], 0.5, na.rm = TRUE),
      p75 = quantile(.data[[var_name]], 0.75, na.rm = TRUE),
      max = max(.data[[var_name]], na.rm = TRUE)
    ) %>%
    pivot_wider(
      id_cols = NULL,
      names_from = all_of(group_var),
      values_from = c(n, mean, sd, min, p25, median, p75, max)
    ) %>%
    mutate(
      # Adicionar testes estatísticos
      mean_diff = mean_Treated - mean_Control,
      mean_pvalue = t.test(
        data[[var_name]][data[[group_var]] == "Treated"],
        data[[var_name]][data[[group_var]] == "Control"]
      )$p.value,
      median_diff = median_Treated - median_Control,
      # Teste de Wilcoxon para medianas
      median_pvalue = wilcox.test(
        data[[var_name]][data[[group_var]] == "Treated"],
        data[[var_name]][data[[group_var]] == "Control"]
      )$p.value,
      variable = var_name
    )
  
  return(result)
}

# 5. Calcular estatísticas para cada variável
distribution_stats <- lapply(balance_vars, function(var) {
  calculate_distribution_stats(balance_data, var)
}) %>% bind_rows()

# 6. Adicionar estatísticas por estado (para mostrar a variação entre estados)
state_stats <- balance_data %>%
  group_by(state) %>%
  summarize(
    across(all_of(balance_vars), 
           list(mean = ~mean(., na.rm = TRUE),
                median = ~median(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  )

# 7. Formatar para LaTeX
var_names <- c(
  "perc_superior" = "Percentage of Municipality Public Employees with Higher Education",
  "distancia_delegacia_km" = "Distance to Nearest Police Station (km)"
)

distribution_stats <- distribution_stats %>%
  mutate(
    variable_name = var_names[variable],
    mean_pvalue_fmt = ifelse(mean_pvalue < 0.01, "<0.01",
                             ifelse(mean_pvalue < 0.05, "<0.05",
                                    ifelse(mean_pvalue < 0.1, "<0.1", 
                                           as.character(round(mean_pvalue, 3))))),
    median_pvalue_fmt = ifelse(median_pvalue < 0.01, "<0.01",
                               ifelse(median_pvalue < 0.05, "<0.05",
                                      ifelse(median_pvalue < 0.1, "<0.1", 
                                             as.character(round(median_pvalue, 3)))))
  )

# 8. Gerar tabela LaTeX
latex_distribution <- "\\begin{table}[htbp]
\\centering
\\caption{Distribution of Key Variables Between Treatment and Control Groups (2006)}
\\label{tab:var_distribution}
\\small
\\begin{tabular}{lcccccccc}
\\toprule
& \\multicolumn{2}{c}{Mean (SD)} & \\multicolumn{2}{c}{Median [IQR]} & \\multicolumn{2}{c}{Range} & \\multicolumn{2}{c}{Tests} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7} \\cmidrule(lr){8-9}
Variable & Treated & Control & Treated & Control & Treated & Control & Mean & Median \\\\
\\midrule\n"

# Adicionar cada variável
for (i in 1:nrow(distribution_stats)) {
  row <- distribution_stats[i,]
  line <- paste0(
    row$variable_name, " & ",
    round(row$mean_Treated, 2), " (", round(row$sd_Treated, 2), ") & ",
    round(row$mean_Control, 2), " (", round(row$sd_Control, 2), ") & ",
    round(row$median_Treated, 2), " [", round(row$p25_Treated, 2), "--", round(row$p75_Treated, 2), "] & ",
    round(row$median_Control, 2), " [", round(row$p25_Control, 2), "--", round(row$p75_Control, 2), "] & ",
    round(row$min_Treated, 2), "--", round(row$max_Treated, 2), " & ",
    round(row$min_Control, 2), "--", round(row$max_Control, 2), " & ",
    row$mean_pvalue_fmt, " & ",
    row$median_pvalue_fmt, " \\\\"
  )
  latex_distribution <- paste0(latex_distribution, line, "\n")
}

# Completar a tabela
latex_distribution <- paste0(latex_distribution, "\\midrule
Number of Municipalities & ", distribution_stats$n_Treated[1], " & ", distribution_stats$n_Control[1], " & & & & & & \\\\
\\bottomrule
\\end{tabular}
\\parbox{\\textwidth}{
\\footnotesize
\\textit{Note:} This table provides detailed distributions of key variables used in heterogeneity analysis. IQR = Interquartile Range (25th--75th percentiles). Tests show p-values from t-test (Mean) and Wilcoxon rank-sum test (Median).
}
\\end{table}")

# 9. Tabela adicional mostrando distribuições por estado
latex_state_distribution <- "\\begin{table}[htbp]
\\centering
\\caption{Distribution of Key Variables by State (2006)}
\\label{tab:state_distribution}
\\small
\\begin{tabular}{lccccc}
\\toprule
& \\multicolumn{2}{c}{Admin. Capacity} & \\multicolumn{2}{c}{Distance to Police} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}
State & Mean (SD) & Median & Mean (SD) & Median \\\\
\\midrule\n"

# Adicionar cada estado
for (i in 1:nrow(state_stats)) {
  row <- state_stats[i,]
  line <- paste0(
    row$state, " & ",
    round(row$perc_superior_mean, 2), " (", round(row$perc_superior_sd, 2), ") & ",
    round(row$perc_superior_median, 2), " & ",
    round(row$distancia_delegacia_km_mean, 2), " (", round(row$distancia_delegacia_km_sd, 2), ") & ",
    round(row$distancia_delegacia_km_median, 2), " \\\\"
  )
  latex_state_distribution <- paste0(latex_state_distribution, line, "\n")
}

# Completar a tabela
latex_state_distribution <- paste0(latex_state_distribution, "\\bottomrule
\\end{tabular}
\\parbox{\\textwidth}{
\\footnotesize
\\textit{Note:} This table shows the distribution of key variables by state. Admin. Capacity = Percentage of Municipality Public Employees with Higher Education.
}
\\end{table}")

# 10. Salvar tabelas
output_dir <- paste0(GITHUB_PATH, "analysis/output/tables/")
writeLines(latex_distribution, paste0(output_dir, "variables_distribution.tex"))
writeLines(latex_state_distribution, paste0(output_dir, "state_distribution.tex"))

# 11. Cálculo adicional: Percentual de sobreposição entre tratados e controles
# Isso pode ajudar a justificar o uso de mediana por estado
overlap_stats <- data.frame(
  variable = character(),
  overlap_percent = numeric(),
  stringsAsFactors = FALSE
)

for (var in balance_vars) {
  # Calcular os ranges
  treated_range <- range(balance_data[[var]][balance_data$ever_treated == "Treated"], na.rm = TRUE)
  control_range <- range(balance_data[[var]][balance_data$ever_treated == "Control"], na.rm = TRUE)
  
  # Calcular sobreposição
  overlap_min <- max(treated_range[1], control_range[1])
  overlap_max <- min(treated_range[2], control_range[2])
  
  # Percentual do range total que se sobrepõe
  total_range <- max(treated_range[2], control_range[2]) - min(treated_range[1], control_range[1])
  overlap_range <- max(0, overlap_max - overlap_min)
  overlap_percent <- (overlap_range / total_range) * 100
  
  # Adicionar resultados
  overlap_stats <- rbind(overlap_stats, data.frame(
    variable = var,
    overlap_percent = overlap_percent
  ))
}

# Imprimir informação de sobreposição - útil para o texto
print(overlap_stats)

cat("LaTeX tables saved to:", output_dir)