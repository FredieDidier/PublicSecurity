
main_data = main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000) 

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