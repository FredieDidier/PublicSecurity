library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

create_homicide_graph <- function(data, category, GITHUB_PATH, graph_type) {
  
  target_states <- c("BA", "PE", "PB", "MA", "CE")
  cols <- c(paste0("taxa_homicidios_", category, "_por_100mil_", target_states),
            paste0("taxa_homicidios_", category, "_por_100mil_other_states"))
  
  graph_data <- data %>%
    select(year, all_of(cols)) %>%
    pivot_longer(cols = all_of(cols),
                 names_to = "state",
                 values_to = "rate") %>%
    mutate(state = sub("taxa_homicidios_.*_por_100mil_", "", state))
  
  graph_data <- graph_data %>%
    group_by(state, year) %>%
    mutate(
      mean_rate = mean(rate, na.rm = TRUE),
      log_rate = log(rate + 1)
    ) %>%
    ungroup()
  
  y_var <- switch(graph_type,
                  "rate" = "rate",
                  "mean" = "mean_rate",
                  "log" = "log_rate")
  
  y_label <- switch(graph_type,
                    "rate" = "Homicide rate per 100,000 inhabitants",
                    "mean" = "Mean homicide rate per 100,000 inhabitants",
                    "log" = "Log of homicide rate per 100,000 inhabitants")
  
  color_palette <- c(
    "PE" = "#0074D9", # Azul para Pernambuco
    "BA" = "#FF4136", # Vermelho para Bahia
    "MA" = "#2ECC40", # Verde para Maranhão
    "CE" = "#FFDC00", # Amarelo para Ceará
    "PB" = "#FF851B", # Laranja para Paraíba
    "other_states" = "#AAAAAA" # Cinza para outros estados
  )
  
  graph <- ggplot(graph_data, aes(x = year, y = !!sym(y_var), color = state)) +
    geom_line(size = 1.2) +
    geom_point(size = 2) +
    scale_color_manual(values = color_palette,
                       labels = c("Bahia", "Ceará", "Maranhão", "Other Northeast States", "Paraíba", "Pernambuco")) +
    geom_vline(xintercept = c(2007, 2011, 2015, 2016), linetype = "dashed", color = "black", size = 0.5) +
    labs(x = "Year",
         y = y_label,
         color = "") +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 12),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      panel.border = element_rect(colour = "black", fill=NA, size=0.5)
    ) +
    scale_x_continuous(breaks = seq(2000, 2019, by = 1)) +
    scale_y_continuous(labels = comma)
  
  # Ajustar posições das anotações pra melhor visibilidade
  annotations <- data.frame(
    x = c(2007, 2011, 2011, 2015, 2016),
    y = c(max(graph_data[[y_var]], na.rm = TRUE) * 0.2,
          max(graph_data[[y_var]], na.rm = TRUE) * 0.2,
          max(graph_data[[y_var]], na.rm = TRUE) * 0.15,
          max(graph_data[[y_var]], na.rm = TRUE) * 0.2,
          max(graph_data[[y_var]], na.rm = TRUE) * 0.2),
    label = c("PE", "BA", "PB", "CE", "MA"),
    color = c("#0074D9", "#FF4136", "#FF851B", "#FFDC00", "#2ECC40")
  )
  
  graph <- graph +
    geom_text(data = annotations, aes(x = x, y = y, label = label), 
              color = annotations$color, hjust = -0.2, size = 6, fontface = "bold") +
    geom_segment(data = annotations, aes(x = x, xend = x, 
                                         y = min(graph_data[[y_var]], na.rm = TRUE), 
                                         yend = y), 
                 arrow = arrow(length = unit(0.3, "cm")), color = "black", size = 0.7)
  
  filename <- paste0(GITHUB_PATH, "analysis/output/graphs/homicide_", graph_type, "_northeast_", 
                     switch(category, "total" = "total", "homem" = "male", "mulher" = "female",
                            "negro" = "non_white", "branco" = "white", "homem_jovem" = "young_male",
                            "mulher_jovem" = "young_female", "negro_jovem" = "young_non_white",
                            "branco_jovem" = "young_white"), ".pdf")
  
  ggsave(filename, graph, width = 12, height = 8, dpi = 300)
  
  return(graph)
}

# Exemplo de uso da função
categories <- c("total", "homem", "mulher", "negro", "branco", "homem_jovem", "mulher_jovem", "negro_jovem", "branco_jovem")
graph_types <- c("rate", "mean", "log")
for (category in categories) {
  for (graph_type in graph_types) {
    graph <- create_homicide_graph(main_data, category, GITHUB_PATH, graph_type)
    print(paste("Created", graph_type, "graph for category:", category))
  }
}
