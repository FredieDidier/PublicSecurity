# Criando a tabela com médias de funcionários públicos municipais por população
# (abaixo e acima da mediana)

# Primeiro, vamos calcular a mediana da população
mediana_pop <- median(main_data$population_muni, na.rm = TRUE)

# Criar uma variável que categoriza os municípios conforme a população
main_data$cat_populacao <- ifelse(main_data$population_muni <= mediana_pop, 
                                  "Below Median", 
                                  "Above Median")

# Calcular o número de funcionários per capita (por 1000 habitantes)
main_data$total_func_pub_munic_per_capita <- (main_data$total_func_pub_munic / main_data$population_muni) * 1000
main_data$funcionarios_superior_per_capita <- (main_data$funcionarios_superior / main_data$population_muni) * 1000

# Calcular as médias por categoria de população
tabela_resultado <- aggregate(
  cbind(total_func_pub_munic_per_capita, funcionarios_superior_per_capita, 
        perc_superior) ~ cat_populacao, 
  data = main_data, 
  FUN = mean, 
  na.rm = TRUE
)

# Arredondar os valores para duas casas decimais
tabela_resultado$total_func_pub_munic_per_capita <- round(tabela_resultado$total_func_pub_munic_per_capita, 2)
tabela_resultado$funcionarios_superior_per_capita <- round(tabela_resultado$funcionarios_superior_per_capita, 2)
tabela_resultado$perc_superior <- round(tabela_resultado$perc_superior, 2)

# Criar uma matriz com os resultados
matriz_resultado <- as.matrix(tabela_resultado[, -1])
rownames(matriz_resultado) <- tabela_resultado$cat_populacao

# Transpor a matriz para que as categorias de população sejam colunas
matriz_transposta <- t(matriz_resultado)
rownames(matriz_transposta) <- c("Municipality Public Employees (per 1,000 inhabitants)", 
                                 "Municipality Public Employees with College Degree (per 1,000 inhabitants)",
                                 "Percentage with College Degree (per 1,000 inhabitants)")

# Carregar o pacote xtable para criar a tabela LaTeX
if (!requireNamespace("xtable", quietly = TRUE)) {
  install.packages("xtable")
}
library(xtable)

# Criar a tabela LaTeX
tabela_latex <- xtable(matriz_transposta, 
                       caption = "Municipality Public Employees by Population Category",
                       label = "tab:municipal_employees",
                       align = c("l", "r", "r"))

# Configurar o formato para duas casas decimais
digits(tabela_latex) <- c(0, 2, 2)

# Gerar o código LaTeX com booktabs
latex_code <- print(tabela_latex, 
                    booktabs = TRUE,
                    caption.placement = "top",
                    include.rownames = TRUE,
                    sanitize.rownames.function = function(x) x,
                    include.colnames = TRUE,
                    sanitize.colnames.function = function(x) x,
                    floating = TRUE)

# Adicionar uma nota explicativa (requer o pacote threeparttable)
cat("\\begin{table}[htbp]
\\centering
\\begin{threeparttable}
", latex_code, "
\\end{threeparttable}
\\end{table}")

# Salvar a tabela em um arquivo .tex
output_file <- paste0(GITHUB_PATH, "analysis/output/tables/public_employees_population_stats.tex")
sink(output_file)
cat("\\begin{table}[htbp]
\\centering
\\begin{threeparttable}
", latex_code, "
\\begin{tablenotes}
\\small
\\item \\textit{Note:} This table presents the average number of municipal public employees per 1,000 inhabitants, the average number of employees with college degree per 1,000 inhabitants, and the percentage of municipal employees with college degree, divided by municipalities above and below the population median.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}")
sink()

cat("Tabela LaTeX salva em:", output_file)
