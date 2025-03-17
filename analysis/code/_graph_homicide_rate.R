library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

create_homicide_graph <- function(data, category, GITHUB_PATH) library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

create_homicide_graph <- function(data, category, GITHUB_PATH) {
  target_states <- c("BA", "PE", "PB", "MA", "CE")
  cols <- c(paste0("taxa_homicidios_", category, "_por_100mil_", target_states),
            paste0("taxa_homicidios_", category, "_por_100mil_other_states"))
  
  graph_data <- data %>%
    select(year, all_of(cols)) %>%
    pivot_longer(cols = all_of(cols),
                 names_to = "state",
                 values_to = "rate") %>%
    mutate(state = sub("taxa_homicidios_.*_por_100mil_", "", state))
  
  color_palette <- c(
    "PE" = "#1f77b4",
    "BA" = "#d62728",
    "MA" = "#2ca02c",
    "CE" = "#ff7f0e",
    "PB" = "#9467bd",
    "other_states" = "#7f7f7f"
  )
  
  graph <- ggplot(graph_data, aes(x = year, y = rate, color = state)) +
    geom_line(size = 1.5) +
    geom_point(size = 3) +
    scale_color_manual(values = color_palette,
                       labels = c("Bahia", "Ceará", "Maranhão", 
                                  "Other Northeast States", "Paraíba", "Pernambuco")) +
    geom_vline(xintercept = c(2007, 2011, 2015, 2016), 
               linetype = "dashed", color = "black", size = 0.8) +
    labs(x = "",
         y = "Homicide rate",
         color = "") +
    theme_minimal() +
    theme(
      text = element_text(size = 20),
      axis.title.x = element_text(face = "bold", size = 22),  # Mantém negrito apenas no título do eixo x
      axis.title.y = element_text(size = 22),  # Remove o negrito do título do eixo y
      axis.text = element_text(size = 20),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.text = element_text(size = 18),
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.margin = margin(t = 20),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(size = 0.5),
      panel.border = element_rect(colour = "black", fill=NA, size=1),
      plot.margin = unit(c(1, 1, 1.5, 1), "cm")
    ) +
    scale_x_continuous(breaks = seq(2000, 2019, by = 2)) +
    scale_y_continuous(labels = comma_format(big.mark = ","))
  
  max_y <- max(graph_data$rate, na.rm = TRUE)
  annotations <- data.frame(
    x = c(2007, 2011, 2011, 2015, 2016),
    y = c(max_y * 0.2, max_y * 0.2, max_y * 0.15, max_y * 0.25,
          max_y * 0.15),
    label = c("PE", "BA", "PB", "CE", "MA"),
    color = c("#1f77b4", "#d62728", "#9467bd", "#ff7f0e", "#2ca02c")
  )
  
  graph <- graph +
    geom_text(data = annotations, 
              aes(x = x, y = y, label = label),
              color = annotations$color, 
              hjust = -0.2, 
              size = 10,
              fontface = "bold") +
    geom_segment(data = annotations, 
                 aes(x = x, xend = x,
                     y = min(graph_data$rate, na.rm = TRUE),
                     yend = y),
                 arrow = arrow(length = unit(0.4, "cm")),
                 color = "black",
                 size = 1)
  
  dir.create(file.path(GITHUB_PATH, "analysis/output/graphs"), recursive = TRUE, showWarnings = FALSE)
  
  filename <- file.path(GITHUB_PATH, "analysis/output/graphs", 
                        paste0("homicide_",
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
                               ".png"))
  
  ggsave(filename = filename,
         plot = graph, 
         width = 11, height = 8.5,
         dpi = 600,
         bg = "white")
  
  return(graph)
}

# Example usage
categories <- c("total", "homem", "mulher", "negro", "branco", 
                "homem_jovem", "mulher_jovem", "negro_jovem", "branco_jovem")

for (category in categories) {
  graph <- create_homicide_graph(main_data, category, GITHUB_PATH)
  print(paste("Created graph for category:", category))
}
