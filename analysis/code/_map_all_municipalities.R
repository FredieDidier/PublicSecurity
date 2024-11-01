# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(tidyr)
library(janitor)

# Filtrar códigos específicos
main_data <- main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000)

# Criar tabela com número total de municípios e estados na amostra
table1 <- main_data %>%
  summarise(
    n_estados = n_distinct(state),
    n_municipios = n_distinct(municipality_code)
  )

# Criar dataframe com informações do tratamento
treatment_info <- data.frame(
  treatment_year = c(2007, 2011, 2011, 2015, 2016),
  state = c("PE", "BA", "PB", "CE", "MA")
)

# Criar tabela com número de estados e municípios tratados por ano
table2 <- main_data %>%
  inner_join(treatment_info, by = "state") %>%
  group_by(treatment_year) %>%
  summarise(
    states = paste(sort(unique(state)), collapse = ", "),
    n_state = n_distinct(state),
    n_municipios = n_distinct(municipality_code)
  ) %>%
  arrange(treatment_year)


# Ler dados das delegacias
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Criar map_data mantendo a estrutura sf
map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  left_join(treatment_info, by = "state") %>%
  mutate(
    treatment_status = case_when(
      is.na(treatment_year) ~ "Not Treated",
      TRUE ~ paste("Treated since", treatment_year)
    )
  )

map_data = map_data %>%
  select(treatment_status)

# Criar o mapa
map = ggplot() +
  geom_sf(data = map_data, aes(fill = treatment_status), color = "white", size = 0.1) +
  scale_fill_manual(
    values = c(
      "Not Treated" = "grey80",
      "Treated since 2007" = "#1a9850",
      "Treated since 2011" = "#91cf60",
      "Treated since 2015" = "#d9ef8b",
      "Treated since 2016" = "#fee08b"
    ),
    name = "Treatment Status"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "bottom",
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

# Salvar o mapa como um arquivo PDF
ggsave(paste0(GITHUB_PATH, "analysis/output/maps/_map_all_municipalities_treated_not_treated.pdf"), map, width = 12, height = 8, dpi = 300)

