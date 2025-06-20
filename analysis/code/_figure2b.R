library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(fixest)

# Loading Main Data
load(paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))

create_residuals_homicide_total_graph <- function(data, GITHUB_PATH) {
  target_states <- c("BA", "PE", "PB", "MA", "CE")
  cols <- c(paste0("taxa_homicidios_total_por_100mil_", target_states),
            "taxa_homicidios_total_por_100mil_other_states")
  
  graph_data <- data %>%
    select(year, state, all_of(cols)) %>%
    pivot_longer(cols = all_of(cols),
                 names_to = "state_col",
                 values_to = "rate") %>%
    mutate(state = sub("taxa_homicidios_total_por_100mil_", "", state_col))
  
  fe_model <- feols(rate ~ 1 | state + year, data = graph_data)
  graph_data$residuals <- residuals(fe_model)
  
  color_palette <- c(
    "PE" = "#1f77b4",
    "BA" = "#d62728",
    "MA" = "#2ca02c",
    "CE" = "#ff7f0e",
    "PB" = "#9467bd",
    "other_states" = "#7f7f7f"
  )
  
  graph <- ggplot(graph_data, aes(x = year, y = residuals, color = state)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", size = 1) +
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
      axis.title.x = element_text(face = "bold", size = 22),
      axis.title.y = element_text(size = 22),
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
  
  min_y <- min(graph_data$residuals, na.rm = TRUE)
  annotations <- data.frame(
    x = c(2007, 2011, 2011, 2015, 2016),
    y = c(min_y * 1.2,           # PE
          min_y * 1.2,            # BA
          min_y * 1.5,            # PB
          min_y * 1.3,            # CE
          min_y * 1.1),           # MA
    label = c("PE", "BA", "PB", "CE", "MA"),
    color = c("#1f77b4", "#d62728", "#9467bd", "#ff7f0e", "#2ca02c")
  )
  
  y_range <- diff(range(graph_data$residuals, na.rm = TRUE))
  annotations$yend <- annotations$y + y_range * 0.15
  
  graph <- graph +
    geom_text(data = annotations, 
              aes(x = x, y = y, label = label),
              color = annotations$color, 
              hjust = -0.2, 
              size = 10,
              fontface = "bold") +
    geom_segment(data = annotations, 
                 aes(x = x, xend = x, y = y, yend = yend),
                 arrow = arrow(length = unit(0.4, "cm")),
                 color = "black",
                 size = 1)
  
  # Save
  filename <- file.path(GITHUB_PATH, "analysis/output/graphs", "figura_2b.png")
  
  # Save
  tryCatch({
    ggsave(filename = filename,
           plot = graph, 
           width = 11, height = 8.5,
           dpi = 600,
           bg = "white")
    print(paste("Successfully saved:", filename))
  }, error = function(e) {
    print(paste("Error saving file:", e$message))
  })
  
  return(graph)
}

# Generate and save graph
print("Processing residuals for total homicides")
graph_residuals_total <- create_residuals_homicide_total_graph(main_data, GITHUB_PATH)
print("Created graph: figure_2b.png")