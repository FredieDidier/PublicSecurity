# Carregar pacotes necessários
library(stargazer)
library(tidyr)
library(dplyr)
library(xtable)

main_data = main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000) 

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

# Criar dataframe para a tabela final com o número correto de linhas e valores alinhados
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

# Gerar tabela em LaTeX usando stargazer
sink(paste0(GITHUB_PATH, "analysis/output/tables/descriptive_stats.tex"))
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
          title = "Descriptive Statistics",
          summary = FALSE,
          rownames = FALSE,
          header = FALSE,
          digits = 0,
          float = TRUE,
          font.size = "normalsize")
cat("\\end{document}")
sink()

##################

#################

# Primeiro, criar a variável log_formal_emp
main_data <- main_data %>%
  mutate(log_formal_emp = log(total_vinculos_munic + 1)) %>%
  mutate(log_pop_density_municipality = log(pop_density_municipality))

# Criar tabela de estatísticas descritivas
summary_stats <- main_data %>%
  summarize(across(c(taxa_homicidios_total_por_100mil_munic, 
                     log_pop_density_municipality,
                     log_pib_municipal_per_capita,
                     log_formal_emp),
                   list(mean = ~mean(., na.rm = TRUE),
                        median = ~median(., na.rm = TRUE),
                        sd = ~sd(., na.rm = TRUE),
                        min = ~min(., na.rm = TRUE),
                        max = ~max(., na.rm = TRUE))))

# Transformar para formato mais legível
summary_stats_long <- summary_stats %>%
  pivot_longer(cols = everything(),
               names_to = c("variable", "statistic"),
               names_pattern = "(.*)_(mean|median|sd|min|max)$",
               values_to = "value")

# Criar tabela final com nomes em inglês
summary_stats_wide <- summary_stats_long %>%
  pivot_wider(names_from = statistic, 
              values_from = value) %>%
  mutate(variable = case_when(
    variable == "taxa_homicidios_total_por_100mil_munic" ~ "homicide_rate_per_100k",
    variable == "log_pop_density_municipality" ~ "log_population_density",
    variable == "log_pib_municipal_per_capita" ~ "log_gdp_per_capita",
    variable == "log_formal_emp" ~ "log_formal_employment",
    TRUE ~ variable
  ))


# Convert the reshaped summary_stats to a LaTeX table
latex_table <- xtable(summary_stats_wide, 
                      caption = "Summary Statistics", 
                      label = "tab:summary_stats")

# Save the LaTeX table to a .tex file
print(latex_table, 
      file = paste0(GITHUB_PATH, "analysis/output/tables/summary_stats.tex"), 
      floating = FALSE, 
      tabular.environment = "tabular", 
      booktabs = TRUE, 
      include.rownames = FALSE)
