# Function to create homicide rate graph
create_homicide_graph <- function(data, category, GITHUB_PATH, graph_type) {
  
  # Defining column names based on the category
  col_ba <- paste0("taxa_homicidios_por_100mil_", category, "_BA")
  col_others <- paste0("taxa_homicidios_por_100mil_", category, "_other_states")
  
  # Preparing data for the graph
  graph_data <- data %>%
    select(year, !!sym(col_ba), !!sym(col_others)) %>%
    pivot_longer(cols = c(!!sym(col_ba), !!sym(col_others)),
                 names_to = "state",
                 values_to = "rate")
  
  # Calculate mean rate and log rate
  graph_data <- graph_data %>%
    group_by(state, year) %>%
    mutate(
      mean_rate = mean(rate, na.rm = TRUE),
      log_rate = log(rate)
    ) %>%
    ungroup()
  
  # Determine y-axis variable and label based on graph_type
  y_var <- switch(graph_type,
                  "rate" = "rate",
                  "mean" = "mean_rate",
                  "log" = "log_rate")
  
  y_label <- switch(graph_type,
                    "rate" = "Homicide rate per 100,000 inhabitants",
                    "mean" = "Mean homicide rate per 100,000 inhabitants",
                    "log" = "Log of homicide rate per 100,000 inhabitants")
  
  # Creating the graph
  graph <- ggplot(graph_data, aes(x = year, y = !!sym(y_var), color = state)) +
    geom_line(size = 1.2) +
    geom_point(size = 3) +
    scale_color_manual(values = c("#FF3030", "#FFA07A"),
                       labels = c("Bahia", "Other Northeast States")) +
    geom_vline(xintercept = 2011, linetype = "dashed", color = "black", size = 0.8) +
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
    scale_x_continuous(breaks = seq(2007, 2015, by = 1))
  
  # Saving the graph
  category_english <- switch(category,
                             "total" = "total",
                             "homem" = "male",
                             "mulher" = "female",
                             "negro" = "non_white",
                             "branco" = "white",
                             "homem_jovem" = "young_male",
                             "mulher_jovem" = "young_female",
                             "negro_jovem" = "young_non_white",
                             "branco_jovem" = "young_white")
  
  filename <- paste0(GITHUB_PATH, "analysis/output/graphs/homicide_", graph_type, "_northeast_", category_english, ".pdf")
  ggsave(filename, graph, width = 12, height = 8, dpi = 300)
  
  return(graph)
}

# Example of using the function for all categories and graph types
categories <- c("total", "homem", "mulher", "negro", "branco", "homem_jovem", "mulher_jovem", "negro_jovem", "branco_jovem")
graph_types <- c("rate", "mean", "log")

for (category in categories) {
  for (graph_type in graph_types) {
    graph <- create_homicide_graph(main_data, category, GITHUB_PATH, graph_type)
    print(paste("Created", graph_type, "graph for category:", category))
  }
}