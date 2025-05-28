# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(viridis)
library(janitor)

# Ler dados das delegacias
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Criar map_data com a nova métrica: fração de funcionários com ensino superior
# Filtrar apenas para estados do Nordeste
estados_nordeste <- c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE")

map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  filter(year == 2006) %>%
  filter(state %in% estados_nordeste) %>%  # Filtrar apenas estados do Nordeste
  mutate(
    # Fração de funcionários com ensino superior
    perc_superior = (funcionarios_superior / total_func_pub_munic) * 100
  )

# Classificar municípios em intervalos
map_data <- map_data %>%
  mutate(
    categoria = case_when(
      is.na(perc_superior) ~ "Not Available",
      perc_superior > 60 ~ "Above 60%",
      perc_superior > 40 ~ "41-60%",
      perc_superior > 20 ~ "21-40%",
      TRUE ~ "0-20%"
    )
  )

# Definir cores para os diferentes intervalos
cores_categorias <- c(
  "0-20%" = "#E6F2FF",      # Azul muito claro
  "21-40%" = "#99CCFF",     # Azul claro
  "41-60%" = "#4D94FF",     # Azul médio
  "Above 60%" = "#0066CC",  # Azul escuro
  "Not Available" = "#D3D3D3"  # Cinza para dados não disponíveis
)

# Garantir que a categoria seja um fator com níveis definidos (ordem crescente)
map_data$categoria <- factor(
  map_data$categoria, 
  levels = c("0-20%", "21-40%", "41-60%", "Above 60%", "Not Available")
)

# Criar dataframe com as posições manuais das siglas dos estados
# Usando as mesmas coordenadas do exemplo fornecido
state_labels <- data.frame(
  state = c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA"),
  x = c(-44.5, -42.5, -40.0, -36.5, -36.5, -37.5, -36.5, -37.5, -41.0),
  y = c(-5.0, -7.0, -5.0, -5.5, -7.0, -8.5, -9.5, -10.5, -12.0)
)

# Criar agregação por estado para adicionar bordas
estados_agregados <- map_data %>%
  group_by(state) %>%
  summarise(geometry = st_union(geometry)) %>%
  ungroup()

# Criar o mapa com categorias baseadas nos intervalos e siglas dos estados
mapa_superior <- ggplot() +
  # Camada base com as categorias por intervalo
  geom_sf(data = map_data,
          aes(fill = categoria),
          color = "white",
          size = 0.1) +
  # Adicionar bordas dos estados
  geom_sf(data = estados_agregados,
          fill = NA,
          color = "black",
          size = 0.5) +
  # Adicionar as siglas dos estados manualmente
  geom_text(data = state_labels,
            aes(x = x, y = y, label = state),
            color = "black",
            size = 4,
            fontface = "bold") +
  # Escalas
  scale_fill_manual(
    values = cores_categorias,
    name = "% Municipality Public Employees\nwith Higher Education (2006)",
    drop = FALSE  # Garantir que todas as categorias apareçam na legenda
  ) +
  # Tema do mapa
  theme_void() +
  theme(
    legend.position = "left",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  ) +
  coord_sf()

# Salvar o mapa
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/map_public_employees_education_2006.png"),
  plot = mapa_superior,
  width = 12,  # Largura em polegadas
  height = 8,   # Altura em polegadas
  dpi = 300,
  bg = "white"  # Alta resolução para publicação
)
