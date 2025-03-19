# Código para gerar tabela com dois painéis sobre funcionários públicos municipais
# Panel A: All Sample (Above/Below Median Population)
# Panel B: By State (PE, BA, PB, CE, MA, Never Treated)

# Carregar pacotes necessários
if (!requireNamespace("xtable", quietly = TRUE)) {
  install.packages("xtable")
}
library(xtable)

########################
# CONFIGURAÇÃO INICIAL
########################

# Primeiro, vamos calcular a mediana da população
mediana_pop <- median(main_data$population_muni, na.rm = TRUE)

# Criar uma variável que categoriza os municípios conforme a população
main_data$cat_populacao <- ifelse(main_data$population_muni <= mediana_pop, 
                                  "Below Median", 
                                  "Above Median")

# Calcular o número de funcionários per capita (por 1000 habitantes)
main_data$total_func_pub_munic_per_capita <- (main_data$total_func_pub_munic / main_data$population_muni) * 1000
main_data$funcionarios_superior_per_capita <- (main_data$funcionarios_superior / main_data$population_muni) * 1000

# Definir os estados tratados
treated_states <- c("PE", "BA", "PB", "CE", "MA")

# Criar nova variável para categorizar os estados
main_data$state_group <- ifelse(main_data$state %in% treated_states, 
                                main_data$state, 
                                "Never Treated")

########################
# PANEL A: ALL SAMPLE
########################

# Calcular as médias por categoria de população para todos os municípios
tabela_resultado_A <- aggregate(
  cbind(total_func_pub_munic_per_capita, funcionarios_superior_per_capita, 
        perc_superior) ~ cat_populacao, 
  data = main_data, 
  FUN = mean, 
  na.rm = TRUE
)

# Arredondar os valores para duas casas decimais
tabela_resultado_A$total_func_pub_munic_per_capita <- round(tabela_resultado_A$total_func_pub_munic_per_capita, 2)
tabela_resultado_A$funcionarios_superior_per_capita <- round(tabela_resultado_A$funcionarios_superior_per_capita, 2)
tabela_resultado_A$perc_superior <- round(tabela_resultado_A$perc_superior, 2)

# Criar uma matriz com os resultados
matriz_resultado_A <- as.matrix(tabela_resultado_A[, -1])
rownames(matriz_resultado_A) <- tabela_resultado_A$cat_populacao

# Transpor a matriz para que as categorias de população sejam colunas
matriz_transposta_A <- t(matriz_resultado_A)
rownames(matriz_transposta_A) <- c("Municipality Public Employees (per 1,000 inhabitants)", 
                                   "Municipality Public Employees with College Degree (per 1,000 inhabitants)",
                                   "Percentage with College Degree (%)")

########################
# PANEL B: BY STATE
########################

# Calcular as médias por estado
tabela_resultado_B <- aggregate(
  cbind(total_func_pub_munic_per_capita, funcionarios_superior_per_capita, 
        perc_superior) ~ state_group, 
  data = main_data, 
  FUN = mean, 
  na.rm = TRUE
)

# Arredondar os valores para duas casas decimais
tabela_resultado_B$total_func_pub_munic_per_capita <- round(tabela_resultado_B$total_func_pub_munic_per_capita, 2)
tabela_resultado_B$funcionarios_superior_per_capita <- round(tabela_resultado_B$funcionarios_superior_per_capita, 2)
tabela_resultado_B$perc_superior <- round(tabela_resultado_B$perc_superior, 2)

# Reordenar as linhas para que estados tratados apareçam primeiro e depois o controle
tabela_resultado_B <- tabela_resultado_B[order(factor(tabela_resultado_B$state_group, 
                                                      levels = c(treated_states, "Never Treated"))), ]

# Criar uma matriz com os resultados
matriz_resultado_B <- as.matrix(tabela_resultado_B[, -1])
rownames(matriz_resultado_B) <- tabela_resultado_B$state_group

# Transpor a matriz para que os estados sejam colunas
matriz_transposta_B <- t(matriz_resultado_B)
rownames(matriz_transposta_B) <- c("Municipality Public Employees (per 1,000 inhabitants)", 
                                   "Municipality Public Employees with College Degree (per 1,000 inhabitants)",
                                   "Percentage with College Degree (%)")

########################
# GERAR TABELA LATEX COMPLETA
########################

# Criar a tabela LaTeX para Panel A
tabela_latex_A <- xtable(matriz_transposta_A, 
                         align = c("l", "r", "r"))
# Configurar o formato para duas casas decimais
digits(tabela_latex_A) <- c(0, 2, 2)

# Criar a tabela LaTeX para Panel B
tabela_latex_B <- xtable(matriz_transposta_B, 
                         align = c("l", rep("r", ncol(matriz_transposta_B))))
# Configurar o formato para duas casas decimais
digits(tabela_latex_B) <- rep(2, ncol(matriz_transposta_B) + 1)

# Gerar código LaTeX para Panel A
latex_code_A <- capture.output(
  print(tabela_latex_A, 
        booktabs = TRUE,
        include.rownames = TRUE,
        sanitize.rownames.function = function(x) x,
        include.colnames = TRUE,
        sanitize.colnames.function = function(x) x,
        floating = FALSE)
)

# Gerar código LaTeX para Panel B
latex_code_B <- capture.output(
  print(tabela_latex_B, 
        booktabs = TRUE,
        include.rownames = TRUE,
        sanitize.rownames.function = function(x) x,
        include.colnames = TRUE,
        sanitize.colnames.function = function(x) x,
        floating = FALSE)
)

# Combinar os dois painéis em uma única tabela com subtítulos
tabela_latex_completa <- paste(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Municipality Public Employees Statistics}",
  "\\label{tab:municipal_employees}",
  "\\begin{threeparttable}",
  
  "\\begin{subtable}{\\textwidth}",
  "\\centering",
  "\\caption{All Sample}",
  paste(latex_code_A[2:(length(latex_code_A)-1)], collapse = "\n"),
  "\\end{subtable}",
  
  "\\vspace{0.5cm}",
  
  "\\begin{subtable}{\\textwidth}",
  "\\centering",
  "\\caption{By State}",
  paste(latex_code_B[2:(length(latex_code_B)-1)], collapse = "\n"),
  "\\end{subtable}",
  
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Note:} This table presents the average number of municipal public employees per 1,000 inhabitants, the average number of employees with college degree per 1,000 inhabitants, and the percentage of municipal employees with college degree. Panel A divides municipalities by population (above and below median). Panel B shows statistics by state, where PE, BA, PB, CE, and MA are treated states, while \"Never Treated\" represents the average for all other states in the sample that serve as control group.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}",
  sep = "\n"
)

# Salvar a tabela completa em um arquivo .tex
output_file <- paste0(GITHUB_PATH, "analysis/output/tables/public_employees_statistics.tex")
writeLines(tabela_latex_completa, output_file)

cat("Tabela LaTeX com dois painéis salva em:", output_file)