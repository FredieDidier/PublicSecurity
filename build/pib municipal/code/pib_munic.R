# PIB Municipal data is downloaded from 'https://ftp.ibge.gov.br/Pib_Municipios/2012/base/base_1999_2012_xlsx.zip'
# and 'https://ftp.ibge.gov.br/Pib_Municipios/2021/base/base_de_dados_2010_2021_xlsx.zip'

library(data.table)
library(openxlsx)
library(janitor)

# Loading first dataset
pib_munic_1999_2012 = read.xlsx(paste0(DROPBOX_PATH, "build/pib municipal/input/pib_munic_1999_2012.xlsx"))

# Filtering data to appropriate years
pib_munic_2007_2012 = pib_munic_1999_2012 %>%
  clean_names() %>%
  filter(ano_de_referencia %in% c(2007:2012))

# Selecting important columns
pib_munic_2007_2012 =  pib_munic_2007_2012 %>%
  select(ano_de_referencia, codigo_do_municipio, produto_interno_bruto_a_precos_correntes_r_1_000,
         produto_interno_bruto_per_capita_dado_disponivel_somente_para_o_ultimo_ano_da_serie_r_1_00) %>%
  rename(year = ano_de_referencia, municipality_code = codigo_do_municipio,
         pib_municipal = produto_interno_bruto_a_precos_correntes_r_1_000,
         pib_municipal_per_capita = produto_interno_bruto_per_capita_dado_disponivel_somente_para_o_ultimo_ano_da_serie_r_1_00)

pib_munic_2007_2012 = pib_munic_2007_2012 %>%
  mutate(year = as.numeric(year),
         municipality_code = as.numeric(municipality_code))


# Loading second dataset
pib_munic_2010_2021 = read.xlsx(paste0(DROPBOX_PATH, "build/pib municipal/input/pib_munic_2010_2021.xlsx"))

# Filtering data to appropriate years
pib_munic_2013_2015 = pib_munic_2010_2021 %>%
  clean_names() %>%
  filter(ano %in% c(2013:2015))

# Selecting important columns
pib_munic_2013_2019 = pib_munic_2013_2015 %>%
  select(ano, codigo_do_municipio, produto_interno_bruto_a_precos_correntes_r_1_000,
         produto_interno_bruto_per_capita_a_precos_correntes_r_1_00) %>%
  rename(year = ano, municipality_code = codigo_do_municipio,
         pib_municipal = produto_interno_bruto_a_precos_correntes_r_1_000,
         pib_municipal_per_capita = produto_interno_bruto_per_capita_a_precos_correntes_r_1_00)

# Joining datasets
pib_munic = bind_rows(pib_munic_2007_2012, pib_munic_2013_2015)

# Creating Balanced Panel
painel_balanceado = as.data.table(expand.grid(
  year = unique(pib_munic$year),
  municipality_code = unique(pib_munic$municipality_code)
))

# Merging
pib_munic <- merge(painel_balanceado, pib_munic, 
                    by = c("year", "municipality_code"), 
                    all.x = TRUE)

# Saving clean dataset
save(pib_munic, file = paste0(DROPBOX_PATH, "build/pib municipal/output/clean_pib_munic.RData"))
