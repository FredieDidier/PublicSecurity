library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(fixest)

create_homicide_graph_fe <- function(data, category, GITHUB_PATH, graph_type) {
  
  target_states <- c("BA", "PE", "PB", "MA", "CE")
  cols <- c(paste0("taxa_homicidios_", category, "_por_100mil_", target_states),
            paste0("taxa_homicidios_", category, "_por_100mil_other_states"))
  
  # Preparar dados
  graph_data <- data %>%
    select(year, state, all_of(cols)) %>%
    pivot_longer(cols = all_of(cols),
                 names_to = "state_col",
                 values_to = "rate") %>%
    mutate(state = sub("taxa_homicidios_.*_por_100mil_", "", state_col))
  
  # Preparar variável dependente baseado no tipo de gráfico
  y_var <- switch(graph_type,
                  "rate" = "rate",
                  "mean" = "rate",
                  "log" = "log_rate")
  
  if(graph_type == "log") {
    graph_data$log_rate <- log(graph_data$rate + 1)
  }
  
  # Estimar modelo com efeitos fixos
  fe_model <- feols(as.formula(paste(y_var, "~ 1 | state + year")), 
                    data = graph_data)
  
  # Extrair efeitos fixos
  fe_state <- fixef(fe_model)$state
  fe_year <- fixef(fe_model)$year
  
  # Criar dataframe com efeitos fixos de estado e ano
  fe_data_state <- data.frame(
    year = rep(unique(graph_data$year), each = length(fe_state)),
    state = rep(names(fe_state), times = length(unique(graph_data$year))),
    effect = rep(as.numeric(fe_state), times = length(unique(graph_data$year)))
  )
  
  fe_data_year <- data.frame(
    year = as.numeric(names(fe_year)),
    effect_year = as.numeric(fe_year)
  )
  
  # Combinar efeitos fixos de estado e ano
  fe_data <- fe_data_state %>%
    left_join(fe_data_year, by = "year") %>%
    mutate(total_effect = effect + effect_year)
  
  y_label <- switch(graph_type,
                    "rate" = "Homicide rate per 100,000 inhabitants (Fixed Effects)",
                    "mean" = "Mean homicide rate per 100,000 inhabitants (Fixed Effects)",
                    "log" = "Log homicide rate per 100,000 inhabitants (Fixed effects)")
  
  color_palette <- c(
    "PE" = "#0074D9",
    "BA" = "#FF4136",
    "MA" = "#2ECC40",
    "CE" = "#FFDC00",
    "PB" = "#FF851B",
    "other_states" = "#AAAAAA"
  )
  
  # Criar gráfico com efeitos fixos combinados
  graph <- ggplot(fe_data, aes(x = year, y = total_effect, color = state)) +
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
  
  # Adicionar anotações com setas
  annotations <- data.frame(
    x = c(2007, 2011, 2011, 2015, 2016),
    y = rep(min(fe_data$total_effect, na.rm = TRUE) * 1.2, 5),
    label = c("PE", "BA", "PB", "CE", "MA"),
    color = c("#0074D9", "#FF4136", "#FF851B", "#FFDC00", "#2ECC40")
  )
  
  # Ajustar PB para evitar sobreposição com BA
  annotations$y[annotations$label == "PB"] <- min(fe_data$total_effect, na.rm = TRUE) * 1.5
  
  # Criar pontos de início e fim para setas curtas
  annotations$yend <- annotations$y + abs(diff(range(fe_data$total_effect, na.rm = TRUE))) * 0.1
  
  graph <- graph +
    geom_text(data = annotations, aes(x = x, y = y, label = label), 
              color = annotations$color, hjust = -0.2, size = 6, fontface = "bold") +
    geom_segment(data = annotations, 
                 aes(x = x, xend = x, y = y, yend = yend), 
                 arrow = arrow(length = unit(0.2, "cm")), 
                 color = "black", 
                 size = 0.5)
  
  # Salvar gráfico
  filename <- paste0(GITHUB_PATH, "analysis/output/graphs/fixed_effects_", graph_type, "_northeast_", 
                     switch(category, 
                            "total" = "total", 
                            "homem" = "male", 
                            "mulher" = "female",
                            "negro" = "non_white", 
                            "branco" = "white", 
                            "homem_jovem" = "young_male",
                            "mulher_jovem" = "young_female", 
                            "negro_jovem" = "young_non_white",
                            "branco_jovem" = "young_white"), 
                     ".pdf")
  
  ggsave(filename, graph, width = 12, height = 8, dpi = 300)
  
  return(graph)
}

# Exemplo de uso da função
categories <- c("total", "homem", "mulher", "negro", "branco", 
                "homem_jovem", "mulher_jovem", "negro_jovem", "branco_jovem")
graph_types <- c("rate", "mean", "log")

for (category in categories) {
  for (graph_type in graph_types) {
    graph <- create_homicide_graph_fe(main_data, category, GITHUB_PATH, graph_type)
    print(paste("Created combined fixed effects", graph_type, "graph for category:", category))
  }
}