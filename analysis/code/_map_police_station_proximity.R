# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)

# Ler dados das delegacias
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp"))
delegacias = delegacias %>%
  rename(distancia_delegacia_km = dstnc__)

# Filtrar apenas para estados do Nordeste
estados_nordeste <- c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE")

# Assumindo que existe uma coluna state ou UF no dataset
if("UF" %in% colnames(delegacias)) {
  estado_coluna <- "UF"
} else if("state" %in% colnames(delegacias)) {
  estado_coluna <- "state"
} else {
  # Se não existir, você precisará adicionar essa informação ao seu dataset
  warning("Coluna de estado não encontrada. Adicionando coluna fictícia para demonstração.")
  # Este é apenas um exemplo, você precisará adaptar ao seu dataset real
  estado_coluna <- "state"
  delegacias$state <- sample(estados_nordeste, nrow(delegacias), replace = TRUE)
}

# Filtrar apenas municípios do Nordeste
delegacias <- delegacias %>%
  filter(!!sym(estado_coluna) %in% estados_nordeste)

# Criar variável categórica para as distâncias em intervalos específicos
delegacias <- delegacias %>%
  mutate(dist_categoria = case_when(
    distancia_delegacia_km <= 15 ~ "0-15 km",
    distancia_delegacia_km <= 30 ~ "15-30 km",
    TRUE ~ "Above 30 km"
  ))

# Garantir que as categorias estejam na ordem desejada usando factor
delegacias$dist_categoria <- factor(
  delegacias$dist_categoria,
  levels = c("0-15 km", "15-30 km", "Above 30 km")
)

# Definindo paleta de cores em tons de laranja para boa visibilidade das siglas em preto
cores_categorias <- c(
  "0-15 km" = "#FFECB3",     # Laranja muito claro
  "15-30 km" = "#FFB74D",    # Laranja médio
  "Above 30 km" = "#E65100" # Laranja escuro
)

# Criar agregação por estado para adicionar bordas
estados_agregados <- delegacias %>%
  group_by(!!sym(estado_coluna)) %>%
  summarise(geometry = st_union(geometry)) %>%
  ungroup()

# Criar dataframe com as posições manuais das siglas dos estados do Nordeste
state_labels <- data.frame(
  state = c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA"),
  x = c(-44.5, -42.5, -40.0, -36.5, -36.5, -37.5, -36.5, -37.5, -41.0),
  y = c(-5.0, -7.0, -5.0, -5.5, -7.0, -8.5, -9.5, -10.5, -12.0)
)

# Criar o mapa
map = ggplot() +
  # Camada base com a categoria de distância
  geom_sf(data = delegacias,
          aes(fill = dist_categoria),
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
  # Usando paleta de cores laranja
  scale_fill_manual(
    values = cores_categorias,
    name = "Distance to Nearest\nPolice Station",
    drop = FALSE  # Garantir que todas as categorias apareçam na legenda mesmo se não tiverem dados
  ) +
  theme_void() +
  theme(
    legend.position = "left",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  ) +
  coord_sf()

# Salvar o mapa como um arquivo PNG com alta resolução
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/map_police_station_proximity.png"),
  plot = map,
  width = 12,  # Largura em polegadas
  height = 8,  # Altura em polegadas
  dpi = 300,
  bg = "white"  # Fundo branco para publicação
)
