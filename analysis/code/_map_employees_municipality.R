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
    fracao_superior = (funcionarios_superior / total_func_pub_munic) * 100
  )

# Calcular a mediana da fração de funcionários com ensino superior
mediana_superior <- median(map_data$fracao_superior, na.rm = TRUE)

# Classificar estados em relação à mediana
map_data <- map_data %>%
  mutate(
    categoria_mediana = case_when(
      is.na(fracao_superior) ~ "Not Available",
      fracao_superior >= mediana_superior ~ "Above Median",
      TRUE ~ "Below Median"
    )
  )

# Definir cores para abaixo e acima da mediana - azul escuro menos intenso para as siglas em preto ficarem visíveis
cores_categorias <- c(
  "Below Median" = "#99CCFF",  # Azul Claro
  "Above Median" = "#4D94FF",  # Azul Escuro (mais claro para contraste com as siglas pretas)
  "Not Available" = "#D3D3D3"  # Cinza para dados não disponíveis
)

# Garantir que a categoria_mediana seja um fator com níveis definidos
map_data$categoria_mediana <- factor(
  map_data$categoria_mediana, 
  levels = c("Below Median", "Above Median", "Not Available")
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

# Criar o mapa com categorias baseadas na mediana e siglas dos estados
mapa_superior <- ggplot() +
  # Camada base com a categoria (acima/abaixo da mediana)
  geom_sf(data = map_data,
          aes(fill = categoria_mediana),
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
  height = 8,  # Altura em polegadas
  dpi = 300,
  bg = "white"  # Alta resolução para publicação
)
