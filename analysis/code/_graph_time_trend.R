
main_data = main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000) 

# Primeiro, criar a variável log_formal_emp
main_data <- main_data %>%
  mutate(log_formal_emp = log(total_vinculos_munic + 1)) %>%
  mutate(log_pop_density_municipality = log(pop_density_municipality))

# Primeiro, calcular as estatísticas por ano
time_trends <- main_data %>%
  group_by(year) %>%
  summarize(across(c(taxa_homicidios_total_por_100mil_munic,
                     log_pop_density_municipality,
                     log_pib_municipal_per_capita,
                     log_formal_emp),
                   list(mean = ~mean(., na.rm = TRUE),
                        q25 = ~quantile(., 0.25, na.rm = TRUE),
                        q75 = ~quantile(., 0.75, na.rm = TRUE))))

# Função para criar time trends com cores mais elegantes
plot_time_trend <- function(data, var, title, y_label, line_color = "#2E86C1", fill_color = "#AED6F1") {
  p <- ggplot(data, aes(x = year)) +
    geom_ribbon(aes(ymin = !!sym(paste0(var, "_q25")),
                    ymax = !!sym(paste0(var, "_q75"))),
                fill = fill_color,
                alpha = 0.3) +
    geom_line(aes(y = !!sym(paste0(var, "_mean"))),
              color = line_color,
              size = 1) +
    ggtitle(title) +
    labs(x = "Year", y = y_label) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 12, face = "bold"),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90")
    )
  
  return(p)
}

# Criar os plots com diferentes esquemas de cores
plots_list <- list(
  plot_time_trend(time_trends,
                  "taxa_homicidios_total_por_100mil_munic",
                  "Homicide Rate per 100,000 inhabitants",
                  "",
                  "#E74C3C", "#FADBD8"),  # Tons de vermelho
  
  plot_time_trend(time_trends,
                  "log_pop_density_municipality",
                  "Log (Population Density)",
                  "",
                  "#27AE60", "#D4EFDF"),  # Tons de verde
  
  plot_time_trend(time_trends,
                  "log_pib_municipal_per_capita",
                  "Log (GDP per capita)",
                  "",
                  "#8E44AD", "#E8DAEF"),  # Tons de roxo
  
  plot_time_trend(time_trends,
                  "log_formal_emp",
                  "Log (Formal Employment + 1)",
                  "",
                  "#F39C12", "#FCF3CF")   # Tons de laranja
)

# Salvar plots individuais também
for(i in 1:4) {
  ggsave(
    paste0(GITHUB_PATH, "analysis/output/graphs/time_trend_", i, ".pdf"),
    plots_list[[i]], 
    width = 10, 
    height = 6
  )
}
