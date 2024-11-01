library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(fixest) # para regressões com efeitos fixos

create_homicide_graph_fe <- function(data, category, GITHUB_PATH, graph_type) {
  
  target_states <- c("BA", "PE", "PB", "MA", "CE")
  cols <- c(paste0("taxa_homicidios_", category, "_por_100mil_", target_states),
            paste0("taxa_homicidios_", category, "_por_100mil_other_states"))
  
  # Preparar dados como antes
  graph_data <- data %>%
    select(year, state, all_of(cols)) %>%
    pivot_longer(cols = all_of(cols),
                 names_to = "state_col",
                 values_to = "rate") %>%
    mutate(state = sub("taxa_homicidios_.*_por_100mil_", "", state_col))
  
  # Calcular residuais por estado após remover efeitos fixos
  y_var <- switch(graph_type,
                  "rate" = "rate",
                  "mean" = "rate",  # Usaremos rate para depois calcular média dos residuais
                  "log" = "log_rate")
  
  if(graph_type == "log") {
    graph_data$log_rate <- log(graph_data$rate +1)
  }
  
  # Estimar modelo com efeitos fixos
  fe_model <- feols(as.formula(paste(y_var, "~ 1 | state + year")), 
                    data = graph_data)
  
  # Adicionar residuais ao dataframe
  graph_data$residuals <- residuals(fe_model)
  
  if(graph_type == "mean") {
    graph_data <- graph_data %>%
      group_by(state, year) %>%
      mutate(residuals = mean(residuals, na.rm = TRUE)) %>%
      ungroup()
  }
  
  y_label <- switch(graph_type,
                    "rate" = "Residual homicide rate per 100,000 inhabitants",
                    "mean" = "Mean residual homicide rate per 100,000 inhabitants",
                    "log" = "Residual log homicide rate per 100,000 inhabitants")
  
  color_palette <- c(
    "PE" = "#0074D9",
    "BA" = "#FF4136",
    "MA" = "#2ECC40",
    "CE" = "#FFDC00",
    "PB" = "#FF851B",
    "other_states" = "#AAAAAA"
  )
  
  # Criar gráfico com residuais
  graph <- ggplot(graph_data, aes(x = year, y = residuals, color = state)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
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
  
  # Ajustar anotações para setas curtas
  annotations <- data.frame(
    x = c(2007, 2011, 2011, 2015, 2016),
    y = rep(min(graph_data$residuals, na.rm = TRUE) * 1.2, 5),
    label = c("PE", "BA", "PB", "CE", "MA"),
    color = c("#0074D9", "#FF4136", "#FF851B", "#FFDC00", "#2ECC40")
  )
  
  # Ajustar PB para evitar sobreposição com BA
  annotations$y[annotations$label == "PB"] <- min(graph_data$residuals, na.rm = TRUE) * 1.5
  
  # Criar pontos de início e fim para setas curtas
  annotations$yend <- annotations$y + abs(diff(range(graph_data$residuals, na.rm = TRUE))) * 0.1  # Seta com 10% da altura do gráfico
  
  graph <- graph +
    geom_text(data = annotations, aes(x = x, y = y, label = label), 
              color = annotations$color, hjust = -0.2, size = 6, fontface = "bold") +
    geom_segment(data = annotations, aes(x = x, xend = x, 
                                         y = y,
                                         yend = yend), 
                 arrow = arrow(length = unit(0.2, "cm")), color = "black", size = 0.5)
  
  filename <- paste0(GITHUB_PATH, "analysis/output/graphs/residuals_homicide_", graph_type, "_northeast_", 
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
    graph <- create_homicide_graph_fe(main_data, category, GITHUB_PATH, graph_type)
    print(paste("Created residual", graph_type, "graph for category:", category))
  }
}