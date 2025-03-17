********************************************************************************
* Event Study em uma Única Regressão com Interação de Delegacia
********************************************************************************

* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

* Configurar o seed para bootstrap
set seed 982638

* Criar a variável de tratamento - Apenas PE
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007

* Criar a variável de ano de adoção - Apenas PE
gen treatment_year = 0
replace treatment_year = 2007 if state == "PE"

* Criar a variável de tempo relativo ao tratamento
gen rel_year = year - treatment_year

gen log_pop = log(population_muni)

* Definir ids para xtreg
xtset municipality_code year

* Criar dummies para as coortes de tratamento - Apenas PE
gen t2007 = (treatment_year == 2007)  // PE 
gen t2011 = (treatment_year == 2011)  // BA, PB
gen t2015 = (treatment_year == 2015)  // CE
gen t2016 = (treatment_year == 2016)  // MA

* Criar dummies de ano
forvalues y = 2000/2019 {
    gen d`y' = (year == `y')
}

* Preparar variável de capacidade conforme solicitado
* Calculando a estatística descritiva para identificar a mediana
sum distancia_delegacia_km, detail
* Criando a dummy delegacia que é 1 se proporção > mediana, 0 caso contrário
gen delegacia = (distancia_delegacia_km > r(p50))

* Criar dummy para baixa capacidade
gen close_delegacia = 1 - delegacia

drop if population_2000_muni == .

******************************************************************************
* Criar dummies de evento para todas as coortes interagidas com capacidade
******************************************************************************

* Para coorte 2007 (PE)
* Pré-tratamento: definir até t-7 com interações de capacidade
gen t_7_2007_high = t2007 * d2000 * delegacia
gen t_7_2007_low = t2007 * d2000 * close_delegacia
gen t_6_2007_high = t2007 * d2001 * delegacia
gen t_6_2007_low = t2007 * d2001 * close_delegacia
gen t_5_2007_high = t2007 * d2002 * delegacia
gen t_5_2007_low = t2007 * d2002 * close_delegacia
gen t_4_2007_high = t2007 * d2003 * delegacia
gen t_4_2007_low = t2007 * d2003 * close_delegacia
gen t_3_2007_high = t2007 * d2004 * delegacia
gen t_3_2007_low = t2007 * d2004 * close_delegacia
gen t_2_2007_high = t2007 * d2005 * delegacia
gen t_2_2007_low = t2007 * d2005 * close_delegacia
gen t_1_2007_high = t2007 * d2006 * delegacia
gen t_1_2007_low = t2007 * d2006 * close_delegacia
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007_high = t2007 * d2008 * delegacia
gen t1_2007_low = t2007 * d2008 * close_delegacia
gen t2_2007_high = t2007 * d2009 * delegacia
gen t2_2007_low = t2007 * d2009 * close_delegacia
gen t3_2007_high = t2007 * d2010 * delegacia
gen t3_2007_low = t2007 * d2010 * close_delegacia
gen t4_2007_high = t2007 * d2011 * delegacia
gen t4_2007_low = t2007 * d2011 * close_delegacia
gen t5_2007_high = t2007 * d2012 * delegacia
gen t5_2007_low = t2007 * d2012 * close_delegacia
gen t6_2007_high = t2007 * d2013 * delegacia
gen t6_2007_low = t2007 * d2013 * close_delegacia
gen t7_2007_high = t2007 * d2014 * delegacia
gen t7_2007_low = t2007 * d2014 * close_delegacia
gen t8_2007_high = t2007 * d2015 * delegacia
gen t8_2007_low = t2007 * d2015 * close_delegacia
gen t9_2007_high = t2007 * d2016 * delegacia
gen t9_2007_low = t2007 * d2016 * close_delegacia
gen t10_2007_high = t2007 * d2017 * delegacia
gen t10_2007_low = t2007 * d2017 * close_delegacia
gen t11_2007_high = t2007 * d2018 * delegacia
gen t11_2007_low = t2007 * d2018 * close_delegacia
gen t12_2007_high = t2007 * d2019 * delegacia
gen t12_2007_low = t2007 * d2019 * close_delegacia

* Para coorte 2011 (BA, PB)
* Pré-tratamento
gen t_7_2011_high = t2011 * d2004 * delegacia
gen t_7_2011_low = t2011 * d2004 * close_delegacia
gen t_6_2011_high = t2011 * d2005 * delegacia
gen t_6_2011_low = t2011 * d2005 * close_delegacia
gen t_5_2011_high = t2011 * d2006 * delegacia
gen t_5_2011_low = t2011 * d2006 * close_delegacia
gen t_4_2011_high = t2011 * d2007 * delegacia
gen t_4_2011_low = t2011 * d2007 * close_delegacia
gen t_3_2011_high = t2011 * d2008 * delegacia
gen t_3_2011_low = t2011 * d2008 * close_delegacia
gen t_2_2011_high = t2011 * d2009 * delegacia
gen t_2_2011_low = t2011 * d2009 * close_delegacia
gen t_1_2011_high = t2011 * d2010 * delegacia
gen t_1_2011_low = t2011 * d2010 * close_delegacia
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011_high = t2011 * d2012 * delegacia
gen t1_2011_low = t2011 * d2012 * close_delegacia
gen t2_2011_high = t2011 * d2013 * delegacia
gen t2_2011_low = t2011 * d2013 * close_delegacia
gen t3_2011_high = t2011 * d2014 * delegacia
gen t3_2011_low = t2011 * d2014 * close_delegacia
gen t4_2011_high = t2011 * d2015 * delegacia
gen t4_2011_low = t2011 * d2015 * close_delegacia
gen t5_2011_high = t2011 * d2016 * delegacia
gen t5_2011_low = t2011 * d2016 * close_delegacia
gen t6_2011_high = t2011 * d2017 * delegacia
gen t6_2011_low = t2011 * d2017 * close_delegacia
gen t7_2011_high = t2011 * d2018 * delegacia
gen t7_2011_low = t2011 * d2018 * close_delegacia
gen t8_2011_high = t2011 * d2019 * delegacia
gen t8_2011_low = t2011 * d2019 * close_delegacia

* Para coorte 2015 (CE)
* Pré-tratamento
gen t_7_2015_high = t2015 * d2008 * delegacia
gen t_7_2015_low = t2015 * d2008 * close_delegacia
gen t_6_2015_high = t2015 * d2009 * delegacia
gen t_6_2015_low = t2015 * d2009 * close_delegacia
gen t_5_2015_high = t2015 * d2010 * delegacia
gen t_5_2015_low = t2015 * d2010 * close_delegacia
gen t_4_2015_high = t2015 * d2011 * delegacia
gen t_4_2015_low = t2015 * d2011 * close_delegacia
gen t_3_2015_high = t2015 * d2012 * delegacia
gen t_3_2015_low = t2015 * d2012 * close_delegacia
gen t_2_2015_high = t2015 * d2013 * delegacia
gen t_2_2015_low = t2015 * d2013 * close_delegacia
gen t_1_2015_high = t2015 * d2014 * delegacia
gen t_1_2015_low = t2015 * d2014 * close_delegacia
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015_high = t2015 * d2016 * delegacia
gen t1_2015_low = t2015 * d2016 * close_delegacia
gen t2_2015_high = t2015 * d2017 * delegacia
gen t2_2015_low = t2015 * d2017 * close_delegacia
gen t3_2015_high = t2015 * d2018 * delegacia
gen t3_2015_low = t2015 * d2018 * close_delegacia
gen t4_2015_high = t2015 * d2019 * delegacia
gen t4_2015_low = t2015 * d2019 * close_delegacia

* Para coorte 2016 (MA)
* Pré-tratamento
gen t_7_2016_high = t2016 * d2009 * delegacia
gen t_7_2016_low = t2016 * d2009 * close_delegacia
gen t_6_2016_high = t2016 * d2010 * delegacia
gen t_6_2016_low = t2016 * d2010 * close_delegacia
gen t_5_2016_high = t2016 * d2011 * delegacia
gen t_5_2016_low = t2016 * d2011 * close_delegacia
gen t_4_2016_high = t2016 * d2012 * delegacia
gen t_4_2016_low = t2016 * d2012 * close_delegacia
gen t_3_2016_high = t2016 * d2013 * delegacia
gen t_3_2016_low = t2016 * d2013 * close_delegacia
gen t_2_2016_high = t2016 * d2014 * delegacia
gen t_2_2016_low = t2016 * d2014 * close_delegacia
gen t_1_2016_high = t2016 * d2015 * delegacia
gen t_1_2016_low = t2016 * d2015 * close_delegacia
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016_high = t2016 * d2017 * delegacia
gen t1_2016_low = t2016 * d2017 * close_delegacia
gen t2_2016_high = t2016 * d2018 * delegacia
gen t2_2016_low = t2016 * d2018 * close_delegacia
gen t3_2016_high = t2016 * d2019 * delegacia
gen t3_2016_low = t2016 * d2019 * close_delegacia

********************************************************************************
* Parte 1: Event Study em uma Única Regressão com delegacia
********************************************************************************

xtreg taxa_homicidios_total_por_100m_1 ///
    t_7_2007_high t_6_2007_high t_5_2007_high t_4_2007_high t_3_2007_high t_2_2007_high t_1_2007_high ///
    t1_2007_high t2_2007_high t3_2007_high t4_2007_high t5_2007_high t6_2007_high t7_2007_high t8_2007_high t9_2007_high t10_2007_high t11_2007_high t12_2007_high ///
    t_7_2007_low t_6_2007_low t_5_2007_low t_4_2007_low t_3_2007_low t_2_2007_low t_1_2007_low ///
    t1_2007_low t2_2007_low t3_2007_low t4_2007_low t5_2007_low t6_2007_low t7_2007_low t8_2007_low t9_2007_low t10_2007_low t11_2007_low t12_2007_low ///
    t_7_2011_high t_6_2011_high t_5_2011_high t_4_2011_high t_3_2011_high t_2_2011_high t_1_2011_high ///
    t1_2011_high t2_2011_high t3_2011_high t4_2011_high t5_2011_high t6_2011_high t7_2011_high t8_2011_high ///
    t_7_2011_low t_6_2011_low t_5_2011_low t_4_2011_low t_3_2011_low t_2_2011_low t_1_2011_low ///
    t1_2011_low t2_2011_low t3_2011_low t4_2011_low t5_2011_low t6_2011_low t7_2011_low t8_2011_low ///
    t_7_2015_high t_6_2015_high t_5_2015_high t_4_2015_high t_3_2015_high t_2_2015_high t_1_2015_high ///
    t1_2015_high t2_2015_high t3_2015_high t4_2015_high ///
    t_7_2015_low t_6_2015_low t_5_2015_low t_4_2015_low t_3_2015_low t_2_2015_low t_1_2015_low ///
    t1_2015_low t2_2015_low t3_2015_low t4_2015_low ///
    t_7_2016_high t_6_2016_high t_5_2016_high t_4_2016_high t_3_2016_high t_2_2016_high t_1_2016_high ///
    t1_2016_high t2_2016_high t3_2016_high ///
    t_7_2016_low t_6_2016_low t_5_2016_low t_4_2016_low t_3_2016_low t_2_2016_low t_1_2016_low ///
    t1_2016_low t2_2016_low t3_2016_low ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Salvar o número de observações
sca nobs = e(N)

* Salvar os coeficientes completos
matrix betas = e(b)

* Extrair coeficientes para cada coorte com interação HIGH
* Para PE (2007) HIGH
matrix betas2007_high = betas[1, 1..19], .
* Para PE (2007) LOW
matrix betas2007_low = betas[1, 20..38], .

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007) HIGH
matrix vars2007_high = A[1, 1..19], .
* Para PE (2007) LOW
matrix vars2007_low = A[1, 20..38], .

* Calcular p-values usando boottest com Webb weights
boottest {t_7_2007_high} {t_6_2007_high} {t_5_2007_high} {t_4_2007_high} {t_3_2007_high} {t_2_2007_high} {t_1_2007_high} ///
        {t1_2007_high} {t2_2007_high} {t3_2007_high} {t4_2007_high} {t5_2007_high} {t6_2007_high} {t7_2007_high} {t8_2007_high} {t9_2007_high} {t10_2007_high} {t11_2007_high} {t12_2007_high} ///
        {t_7_2007_low} {t_6_2007_low} {t_5_2007_low} {t_4_2007_low} {t_3_2007_low} {t_2_2007_low} {t_1_2007_low} ///
        {t1_2007_low} {t2_2007_low} {t3_2007_low} {t4_2007_low} {t5_2007_low} {t6_2007_low} {t7_2007_low} {t8_2007_low} {t9_2007_low} {t10_2007_low} {t11_2007_low} {t12_2007_low}, ///
        noci cluster(state_code) reps(9999) weighttype(webb) seed(982638)

* Guardar p-values para cada coorte HIGH
matrix pvalue2007_high = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19), .

* Guardar p-values para cada coorte LOW
matrix pvalue2007_low = r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), r(p_26), ///
                  r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), r(p_38), .

* Testes de tendências paralelas (pré-tratamento)
* Para PE (2007) HIGH
test t_7_2007_high t_6_2007_high t_5_2007_high t_4_2007_high t_3_2007_high t_2_2007_high t_1_2007_high
scalar f2007_high = r(F)
scalar f2007p_high = r(p)

* Para PE (2007) LOW
test t_7_2007_low t_6_2007_low t_5_2007_low t_4_2007_low t_3_2007_low t_2_2007_low t_1_2007_low
scalar f2007_low = r(F)
scalar f2007p_low = r(p)

********************************************************************************
* Criar tendência específica por coorte e delegacia
********************************************************************************
gen trend = year - 2000 // Tendência linear começando em 2000

* Criar tendências específicas para PE por delegacia
gen partrend2007_high = trend * t2007 * delegacia
gen partrend2007_low = trend * t2007 * close_delegacia
gen partrend2011_high = trend * t2011 * delegacia
gen partrend2011_low = trend * t2011 * close_delegacia
gen partrend2015_high = trend * t2015 * delegacia
gen partrend2015_low = trend * t2015 * close_delegacia
gen partrend2016_high = trend * t2016 * delegacia
gen partrend2016_low = trend * t2016 * close_delegacia

********************************************************************************
* Parte 2: Event Study com Tendências Lineares Específicas por Coorte e Delegacia
********************************************************************************

* IMPORTANTE: Remover t_7 para cada coorte (seguindo a lógica do código original)
* Modelo com todas as variáveis incluindo tendências lineares específicas por coorte e capacidade
xtreg taxa_homicidios_total_por_100m_1 ///
    t_6_2007_high t_5_2007_high t_4_2007_high t_3_2007_high t_2_2007_high t_1_2007_high ///
    t1_2007_high t2_2007_high t3_2007_high t4_2007_high t5_2007_high t6_2007_high t7_2007_high t8_2007_high t9_2007_high t10_2007_high t11_2007_high t12_2007_high ///
    partrend2007_high ///
    t_6_2007_low t_5_2007_low t_4_2007_low t_3_2007_low t_2_2007_low t_1_2007_low ///
    t1_2007_low t2_2007_low t3_2007_low t4_2007_low t5_2007_low t6_2007_low t7_2007_low t8_2007_low t9_2007_low t10_2007_low t11_2007_low t12_2007_low ///
    partrend2007_low ///
    t_6_2011_high t_5_2011_high t_4_2011_high t_3_2011_high t_2_2011_high t_1_2011_high ///
    t1_2011_high t2_2011_high t3_2011_high t4_2011_high t5_2011_high t6_2011_high t7_2011_high t8_2011_high ///
    partrend2011_high ///
    t_6_2011_low t_5_2011_low t_4_2011_low t_3_2011_low t_2_2011_low t_1_2011_low ///
    t1_2011_low t2_2011_low t3_2011_low t4_2011_low t5_2011_low t6_2011_low t7_2011_low t8_2011_low ///
    partrend2011_low ///
    t_6_2015_high t_5_2015_high t_4_2015_high t_3_2015_high t_2_2015_high t_1_2015_high ///
    t1_2015_high t2_2015_high t3_2015_high t4_2015_high ///
    partrend2015_high ///
    t_6_2015_low t_5_2015_low t_4_2015_low t_3_2015_low t_2_2015_low t_1_2015_low ///
    t1_2015_low t2_2015_low t3_2015_low t4_2015_low ///
    partrend2015_low ///
    t_6_2016_high t_5_2016_high t_4_2016_high t_3_2016_high t_2_2016_high t_1_2016_high ///
    t1_2016_high t2_2016_high t3_2016_high ///
    partrend2016_high ///
    t_6_2016_low t_5_2016_low t_4_2016_low t_3_2016_low t_2_2016_low t_1_2016_low ///
    t1_2016_low t2_2016_low t3_2016_low ///
    partrend2016_low ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)
* Salvar o número de observações
sca nobs_trend = e(N)

* Salvar os coeficientes completos
matrix betas_trend = e(b)

* Extrair coeficientes para PE, incluindo as tendências
* Para PE (2007) HIGH - notamos que não temos mais t_7, então começamos em t_6
matrix betas2007_high_trend = ., betas_trend[1, 1..18], ., betas_trend[1, 19]
* Para PE (2007) LOW
matrix betas2007_low_trend = ., betas_trend[1, 20..37], ., ., betas_trend[1, 38]

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007) HIGH
matrix vars2007_high_trend = ., A[1, 1..18], ., A[1, 19]
* Para PE (2007) LOW
matrix vars2007_low_trend = ., A[1, 20..37], ., ., A[1, 38]

* Calcular p-values usando boottest com Webb weights
boottest {t_6_2007_high} {t_5_2007_high} {t_4_2007_high} {t_3_2007_high} {t_2_2007_high} {t_1_2007_high} ///
        {t1_2007_high} {t2_2007_high} {t3_2007_high} {t4_2007_high} {t5_2007_high} {t6_2007_high} {t7_2007_high} {t8_2007_high} {t9_2007_high} {t10_2007_high} {t11_2007_high} {t12_2007_high} ///
        {partrend2007_high} ///
        {t_6_2007_low} {t_5_2007_low} {t_4_2007_low} {t_3_2007_low} {t_2_2007_low} {t_1_2007_low} ///
        {t1_2007_low} {t2_2007_low} {t3_2007_low} {t4_2007_low} {t5_2007_low} {t6_2007_low} {t7_2007_low} {t8_2007_low} {t9_2007_low} {t10_2007_low} {t11_2007_low} {t12_2007_low} ///
        {partrend2007_low}, ///
        noci cluster(state_code) reps(9999) weighttype(webb) seed(982638)

* Guardar p-values para PE, incluindo as tendências
* Por causa da remoção de t_7, ajustamos os índices
matrix pvalue2007_high_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), ., r(p_19)

matrix pvalue2007_low_trend = ., r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), ///
                  r(p_26), r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), ., ., r(p_38)

* Testes de tendências paralelas (pré-tratamento) - excluindo t_7 conforme especificação
* Para PE (2007) HIGH
test t_6_2007_high t_5_2007_high t_4_2007_high t_3_2007_high t_2_2007_high t_1_2007_high
scalar f2007_high_trend = r(F)
scalar f2007p_high_trend = r(p)

* Para PE (2007) LOW
test t_6_2007_low t_5_2007_low t_4_2007_low t_3_2007_low t_2_2007_low t_1_2007_low
scalar f2007_low_trend = r(F)
scalar f2007p_low_trend = r(p)

********************************************************************************
* Criar gráficos de event study para PE - alta e baixa capacidade
********************************************************************************

* PARTE 1: GRÁFICOS SEM TENDÊNCIAS

* Criar datasets a partir das matrizes para facilitar a plotagem
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* Pernambuco 2007
* Alta capacidade
gen coef_2007_high = .
gen se_2007_high = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_high = betas2007_high[1,`pos'] if rel_year == `rel_year'
    replace se_2007_high = vars2007_high[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_high = 0 if rel_year == 0
replace se_2007_high = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_high = betas2007_high[1,`pos'] if rel_year == `rel_year'
    replace se_2007_high = vars2007_high[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2007_low = .
gen se_2007_low = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_low = betas2007_low[1,`pos'] if rel_year == `rel_year'
    replace se_2007_low = vars2007_low[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_low = 0 if rel_year == 0
replace se_2007_low = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_low = betas2007_low[1,`pos'] if rel_year == `rel_year'
    replace se_2007_low = vars2007_low[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2007_high = coef_2007_high + 1.96 * se_2007_high
gen ci_lower_2007_high = coef_2007_high - 1.96 * se_2007_high
gen ci_upper_2007_low = coef_2007_low + 1.96 * se_2007_low
gen ci_lower_2007_low = coef_2007_low - 1.96 * se_2007_low

* Gráfico para PE (2007) - Alta vs Baixa capacidade
twoway (rcap ci_upper_2007_high ci_lower_2007_high rel_year if rel_year >= -7 & rel_year <= 12, lcolor(midblue)) ///
       (scatter coef_2007_high rel_year if rel_year >= -7 & rel_year <= 12, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2007_low ci_lower_2007_low rel_year if rel_year >= -7 & rel_year <= 12, lcolor(cranberry)) ///
       (scatter coef_2007_low rel_year if rel_year >= -7 & rel_year <= 12, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Pernambuco (2007)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)12) ylabel(, angle(horizontal)) ///
       legend(order(2 "Long Distance" 4 "Close Distance") position(6) rows(1)) ///
       name(coorte2007, replace) scheme(s1mono)
	   
	   
	   * Salvar gráfico combinado
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delegacia_event_study_PE.pdf", replace


* PARTE 2: GRÁFICOS COM TENDÊNCIAS LINEARES

* Repetir o mesmo processo para os modelos com tendências lineares
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* Pernambuco 2007 com tendência
* Alta capacidade
gen coef_2007_high_trend = .
gen se_2007_high_trend = .

* Preencher valores dos coeficientes e erros padrão - Note que começamos em t-6 (não tem t-7)
replace coef_2007_high_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_high_trend = betas2007_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_high_trend = vars2007_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_high_trend = 0 if rel_year == 0
replace se_2007_high_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_high_trend = betas2007_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_high_trend = vars2007_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2007_low_trend = .
gen se_2007_low_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2007_low_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_low_trend = betas2007_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_low_trend = vars2007_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_low_trend = 0 if rel_year == 0
replace se_2007_low_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_low_trend = betas2007_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_low_trend = vars2007_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2007_high_trend = coef_2007_high_trend + 1.96 * se_2007_high_trend
gen ci_lower_2007_high_trend = coef_2007_high_trend - 1.96 * se_2007_high_trend
gen ci_upper_2007_low_trend = coef_2007_low_trend + 1.96 * se_2007_low_trend
gen ci_lower_2007_low_trend = coef_2007_low_trend - 1.96 * se_2007_low_trend

* Gráfico para PE (2007) - Alta vs Baixa capacidade com tendência
twoway (rcap ci_upper_2007_high_trend ci_lower_2007_high_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(midblue)) ///
       (scatter coef_2007_high_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2007_low_trend ci_lower_2007_low_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(cranberry)) ///
       (scatter coef_2007_low_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Pernambuco (2007)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)12) ylabel(, angle(horizontal)) ///
       legend(order(2 "Long Distance" 4 "Close Distance") position(6) rows(1)) ///
       name(coorte2007_trend, replace) scheme(s1mono)

	   * Salvar gráfico combinado
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delegacia_event_study_trends_PE.pdf", replace
