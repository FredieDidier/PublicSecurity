
main_data = main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000) 

# Primeiro, criar a variável log_formal_emp
main_data <- main_data %>%
  mutate(log_formal_emp = log(total_vinculos_munic + 1)) %>%
  mutate(log_pop_density_municipality = log(pop_density_municipality))

# Função para criar density plots
plot_density <- function(data, var, title) {
  p <- ggplot(data, aes(x = !!sym(var))) +
    geom_density(fill = "steelblue", alpha = 0.5) +
    ggtitle(title) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 12, face = "bold"),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9) 
    )
  
  ggsave(paste0(GITHUB_PATH, "analysis/output/graphs/density_plot_", var, ".pdf"), p, width = 10, height = 6)
  return(p)
}

# Função para criar density plots
plot_density <- function(data, var, title, x_label) {
  p <- ggplot(data, aes(x = !!sym(var))) +
    geom_density(fill = "steelblue", alpha = 0.5) +
    ggtitle(title) +
    labs(x = x_label, y = "Density") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 12, face = "bold"),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9) 
    )
  
  ggsave(paste0(GITHUB_PATH, "analysis/output/graphs/density_plot_", var, ".pdf"), p, width = 10, height = 6)
  return(p)
}

# Criar os plots
plot_density(main_data, 
             "taxa_homicidios_total_por_100mil_munic", 
             "",
             "Homicide Rate per 100,000 inhabitants")

plot_density(main_data, 
             "pop_density_municipality", 
             "",
             "Population Density")

plot_density(main_data, 
             "log_pib_municipal_per_capita", 
             "",
             "Log (GDP per capita)")

plot_density(main_data, 
             "log_formal_emp", 
             "",
             "Log (Formal Employment + 1)")

plot_density(main_data,
             "log_pop_density_municipality",
             "",
             "Log (Population Density)")

# Se quiser visualizar todos os plots juntos
library(gridExtra)

plots_list <- list(
  plot_density(main_data, 
               "taxa_homicidios_total_por_100mil_munic", 
               "Homicide Rate per 100,000 inhabitants",
               "Homicide Rate per 100,000 inhabitants"),
  
  plot_density(main_data, 
               "pop_density_municipality", 
               "Population Density",
               "Population Density (inhabitants per km²)"),
  
  plot_density(main_data, 
               "log_pib_municipal_per_capita", 
               "Log(GDP per capita)",
               "Log(Municipal GDP per capita)"),
  
  plot_density(main_data, 
               "log_formal_emp", 
               "Log(Formal Employment)",
               "Log(Formal Employment + 1)")
)

# Combinar todos os plots em uma única figura
combined_plot <- grid.arrange(grobs = plots_list, ncol = 2)

# Salvar a figura combinada
ggsave(paste0(GITHUB_PATH, "analysis/output/graphs/combined_density_plots.pdf"), 
       combined_plot, width = 15, height = 10)