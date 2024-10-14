* Instalação do pacote sdid
ssc install sdid, replace

* Carregar os dados (substitua "seu_arquivo_de_dados.dta" pelo nome real do seu arquivo)
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurityBahia/build/workfile/output/main_data_stata.dta", clear

* Preparar os dados para Synthetic DiD
* Extrair o código do estado a partir do código do município

* Filtrar os dados para o período de interesse
* keep if year >= 2007 & year <= 2015

* Criar variável de tratamento (Bahia a partir de 2011)
* gen treated = (state_code == 29 & year >= 2011)

* Identificar municípios com dados para todos os anos
bysort municipality_code: gen n_years = _N
keep if n_years == 9  // 9 anos de 2000 a 2020

* Verificar se ainda há municípios tratados após o balanceamento
count if state_code == 29
if r(N) == 0 {
    display as error "Todos os municípios da Bahia foram removidos no processo de balanceamento."
    exit
}

* Configurar os dados para o formato panel
xtset municipality_code year

* Executar a análise Synthetic DiD com covariáveis
eststo sdid_1: sdid taxa_homicidios_total_por_100m_1 municipality_code year treated, covariates(log_pib_municipal_per_capita pop_density_municipality, projected) method(sdid) vce(bootstrap) reps(100) graph

* Salvar o gráfico
graph export "synthetic_did_result.png", replace

*create a table
esttab sdid_1, starlevel ("*" 0.10 "**" 0.05 "***" 0.01) b(%-9.3f) se(%-9.3f)

* Executar a análise Synthetic Control com covariáveis
eststo sc_1 sdid taxa_homicidios_total_por_100m_1 municipality_code year treated, covariates(log_pib_municipal_per_capita pop_density_municipality, projected) method(sc) vce(bootstrap) reps(100) graph

*create a table
esttab sdsc_1, starlevel ("*" 0.10 "**" 0.05 "***" 0.01) b(%-9.3f) se(%-9.3f)


ssc install sdid_event, replace

sdid_event taxa_homicidios_total_por_100m_1 municipality_code year treated, effects(5) placebo(4) covariates(log_pib_municipal_per_capita pop_density_municipality) vce(bootstrap) brep(50)
