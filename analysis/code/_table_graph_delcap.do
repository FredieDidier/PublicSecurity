********************************************************************************
* Event Study para PE com Heterogeneidade por Capacidade e Distância a Delegacias
********************************************************************************

* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

* Configurar o seed para bootstrap
set seed 982638

* Criar a variável de tratamento
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007

* Criar a variável de ano de adoção
gen treatment_year = 0
replace treatment_year = 2007 if state == "PE"

* Criar a variável de tempo relativo ao tratamento
gen rel_year = year - treatment_year

gen log_pop = log(population_muni)

* Definir ids para xtreg
xtset municipality_code year

* Criar dummies para as coortes de tratamento
gen t2007 = (treatment_year == 2007)  // PE
gen never = (treatment_year == 0)     // Nunca tratados

* Criar dummies de ano
forvalues y = 2000/2019 {
    gen d`y' = (year == `y')
}

* Preparar variável de capacidade conforme solicitado
preserve
keep if year == 2006
* Calculando a porcentagem de funcionários com ensino superior em relação ao total
gen porc_func_superior = (funcionarios_superior / total_func_pub_munic) * 100
* Calculando a estatística descritiva para identificar a mediana
sum porc_func_superior, detail
* Criando a dummy high_cap que é 1 se proporção > mediana, 0 caso contrário
gen high_cap = (porc_func_superior > r(p50))
* Mantendo apenas as variáveis necessárias para o merge
keep municipality_code high_cap
save "temp_high_cap.dta", replace
restore

* Fazendo o merge com o dataset principal
merge m:1 municipality_code using "temp_high_cap.dta", nogenerate
erase "temp_high_cap.dta"

* Preparar variável de delegacia conforme solicitado
* Calculando a estatística descritiva para identificar a mediana da distância até delegacia
sum distancia_delegacia_km, detail
* Criando a dummy delegacia que é 1 se distância > mediana, 0 caso contrário
gen delegacia = (distancia_delegacia_km > r(p50))
* Mantendo apenas as variáveis necessárias para o merge

* Criar a variável delcap com as 4 categorias solicitadas
gen delcap = 1 if high_cap == 0 & delegacia == 0
replace delcap = 2 if high_cap == 0 & delegacia == 1
replace delcap = 3 if high_cap == 1 & delegacia == 0
replace delcap = 4 if high_cap == 1 & delegacia == 1

* Criar dummies para cada categoria de delcap
gen delcap1 = (delcap == 1)
gen delcap2 = (delcap == 2)
gen delcap3 = (delcap == 3)
gen delcap4 = (delcap == 4)

******************************************************************************
* Criar dummies de evento para PE (2007) interagidas com as 4 categorias
******************************************************************************

* Para coorte 2007 (PE) - Categoria 1: low cap & close delegacia
* Pré-tratamento: definir até t-7 com interações
gen t_7_2007_cat1 = t2007 * d2000 * delcap1
gen t_6_2007_cat1 = t2007 * d2001 * delcap1
gen t_5_2007_cat1 = t2007 * d2002 * delcap1
gen t_4_2007_cat1 = t2007 * d2003 * delcap1
gen t_3_2007_cat1 = t2007 * d2004 * delcap1
gen t_2_2007_cat1 = t2007 * d2005 * delcap1
gen t_1_2007_cat1 = t2007 * d2006 * delcap1
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007_cat1 = t2007 * d2008 * delcap1
gen t2_2007_cat1 = t2007 * d2009 * delcap1
gen t3_2007_cat1 = t2007 * d2010 * delcap1
gen t4_2007_cat1 = t2007 * d2011 * delcap1
gen t5_2007_cat1 = t2007 * d2012 * delcap1
gen t6_2007_cat1 = t2007 * d2013 * delcap1
gen t7_2007_cat1 = t2007 * d2014 * delcap1
gen t8_2007_cat1 = t2007 * d2015 * delcap1
gen t9_2007_cat1 = t2007 * d2016 * delcap1
gen t10_2007_cat1 = t2007 * d2017 * delcap1
gen t11_2007_cat1 = t2007 * d2018 * delcap1
gen t12_2007_cat1 = t2007 * d2019 * delcap1

* Para coorte 2007 (PE) - Categoria 2: low cap & far delegacia
* Pré-tratamento
gen t_7_2007_cat2 = t2007 * d2000 * delcap2
gen t_6_2007_cat2 = t2007 * d2001 * delcap2
gen t_5_2007_cat2 = t2007 * d2002 * delcap2
gen t_4_2007_cat2 = t2007 * d2003 * delcap2
gen t_3_2007_cat2 = t2007 * d2004 * delcap2
gen t_2_2007_cat2 = t2007 * d2005 * delcap2
gen t_1_2007_cat2 = t2007 * d2006 * delcap2
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007_cat2 = t2007 * d2008 * delcap2
gen t2_2007_cat2 = t2007 * d2009 * delcap2
gen t3_2007_cat2 = t2007 * d2010 * delcap2
gen t4_2007_cat2 = t2007 * d2011 * delcap2
gen t5_2007_cat2 = t2007 * d2012 * delcap2
gen t6_2007_cat2 = t2007 * d2013 * delcap2
gen t7_2007_cat2 = t2007 * d2014 * delcap2
gen t8_2007_cat2 = t2007 * d2015 * delcap2
gen t9_2007_cat2 = t2007 * d2016 * delcap2
gen t10_2007_cat2 = t2007 * d2017 * delcap2
gen t11_2007_cat2 = t2007 * d2018 * delcap2
gen t12_2007_cat2 = t2007 * d2019 * delcap2

* Para coorte 2007 (PE) - Categoria 3: high cap & close delegacia
* Pré-tratamento
gen t_7_2007_cat3 = t2007 * d2000 * delcap3
gen t_6_2007_cat3 = t2007 * d2001 * delcap3
gen t_5_2007_cat3 = t2007 * d2002 * delcap3
gen t_4_2007_cat3 = t2007 * d2003 * delcap3
gen t_3_2007_cat3 = t2007 * d2004 * delcap3
gen t_2_2007_cat3 = t2007 * d2005 * delcap3
gen t_1_2007_cat3 = t2007 * d2006 * delcap3
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007_cat3 = t2007 * d2008 * delcap3
gen t2_2007_cat3 = t2007 * d2009 * delcap3
gen t3_2007_cat3 = t2007 * d2010 * delcap3
gen t4_2007_cat3 = t2007 * d2011 * delcap3
gen t5_2007_cat3 = t2007 * d2012 * delcap3
gen t6_2007_cat3 = t2007 * d2013 * delcap3
gen t7_2007_cat3 = t2007 * d2014 * delcap3
gen t8_2007_cat3 = t2007 * d2015 * delcap3
gen t9_2007_cat3 = t2007 * d2016 * delcap3
gen t10_2007_cat3 = t2007 * d2017 * delcap3
gen t11_2007_cat3 = t2007 * d2018 * delcap3
gen t12_2007_cat3 = t2007 * d2019 * delcap3

* Para coorte 2007 (PE) - Categoria 4: high cap & far delegacia
* Pré-tratamento
gen t_7_2007_cat4 = t2007 * d2000 * delcap4
gen t_6_2007_cat4 = t2007 * d2001 * delcap4
gen t_5_2007_cat4 = t2007 * d2002 * delcap4
gen t_4_2007_cat4 = t2007 * d2003 * delcap4
gen t_3_2007_cat4 = t2007 * d2004 * delcap4
gen t_2_2007_cat4 = t2007 * d2005 * delcap4
gen t_1_2007_cat4 = t2007 * d2006 * delcap4
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007_cat4 = t2007 * d2008 * delcap4
gen t2_2007_cat4 = t2007 * d2009 * delcap4
gen t3_2007_cat4 = t2007 * d2010 * delcap4
gen t4_2007_cat4 = t2007 * d2011 * delcap4
gen t5_2007_cat4 = t2007 * d2012 * delcap4
gen t6_2007_cat4 = t2007 * d2013 * delcap4
gen t7_2007_cat4 = t2007 * d2014 * delcap4
gen t8_2007_cat4 = t2007 * d2015 * delcap4
gen t9_2007_cat4 = t2007 * d2016 * delcap4
gen t10_2007_cat4 = t2007 * d2017 * delcap4
gen t11_2007_cat4 = t2007 * d2018 * delcap4
gen t12_2007_cat4 = t2007 * d2019 * delcap4

********************************************************************************
* Parte 1: Event Study em uma Única Regressão com as 4 Categorias
********************************************************************************

* Modelo com todas as variáveis e interações com as 4 categorias para PE
xtreg taxa_homicidios_total_por_100m_1 ///
    t_7_2007_cat1 t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1 ///
    t1_2007_cat1 t2_2007_cat1 t3_2007_cat1 t4_2007_cat1 t5_2007_cat1 t6_2007_cat1 t7_2007_cat1 t8_2007_cat1 t9_2007_cat1 t10_2007_cat1 t11_2007_cat1 t12_2007_cat1 ///
    t_7_2007_cat2 t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2 ///
    t1_2007_cat2 t2_2007_cat2 t3_2007_cat2 t4_2007_cat2 t5_2007_cat2 t6_2007_cat2 t7_2007_cat2 t8_2007_cat2 t9_2007_cat2 t10_2007_cat2 t11_2007_cat2 t12_2007_cat2 ///
    t_7_2007_cat3 t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3 ///
    t1_2007_cat3 t2_2007_cat3 t3_2007_cat3 t4_2007_cat3 t5_2007_cat3 t6_2007_cat3 t7_2007_cat3 t8_2007_cat3 t9_2007_cat3 t10_2007_cat3 t11_2007_cat3 t12_2007_cat3 ///
    t_7_2007_cat4 t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4 ///
    t1_2007_cat4 t2_2007_cat4 t3_2007_cat4 t4_2007_cat4 t5_2007_cat4 t6_2007_cat4 t7_2007_cat4 t8_2007_cat4 t9_2007_cat4 t10_2007_cat4 t11_2007_cat4 t12_2007_cat4 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Salvar o número de observações
sca nobs = e(N)

* Salvar os coeficientes completos
matrix betas = e(b)

* Extrair coeficientes para cada categoria
* Para PE (2007) Categoria 1: low cap & close delegacia
matrix betas2007_cat1 = betas[1, 1..19], .
* Para PE (2007) Categoria 2: low cap & far delegacia
matrix betas2007_cat2 = betas[1, 20..38], ., .
* Para PE (2007) Categoria 3: high cap & close delegacia
matrix betas2007_cat3 = betas[1, 39..57], ., ., .
* Para PE (2007) Categoria 4: high cap & far delegacia
matrix betas2007_cat4 = betas[1, 58..76], ., ., ., .

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007) Categoria 1
matrix vars2007_cat1 = A[1, 1..19], .
* Para PE (2007) Categoria 2
matrix vars2007_cat2 = A[1, 20..38], ., .
* Para PE (2007) Categoria 3
matrix vars2007_cat3 = A[1, 39..57], ., ., .
* Para PE (2007) Categoria 4
matrix vars2007_cat4 = A[1, 58..76], ., ., ., .

* Calcular p-values usando boottest com Webb weights
boottest {t_7_2007_cat1} {t_6_2007_cat1} {t_5_2007_cat1} {t_4_2007_cat1} {t_3_2007_cat1} {t_2_2007_cat1} {t_1_2007_cat1} ///
        {t1_2007_cat1} {t2_2007_cat1} {t3_2007_cat1} {t4_2007_cat1} {t5_2007_cat1} {t6_2007_cat1} {t7_2007_cat1} {t8_2007_cat1} {t9_2007_cat1} {t10_2007_cat1} {t11_2007_cat1} {t12_2007_cat1} ///
        {t_7_2007_cat2} {t_6_2007_cat2} {t_5_2007_cat2} {t_4_2007_cat2} {t_3_2007_cat2} {t_2_2007_cat2} {t_1_2007_cat2} ///
        {t1_2007_cat2} {t2_2007_cat2} {t3_2007_cat2} {t4_2007_cat2} {t5_2007_cat2} {t6_2007_cat2} {t7_2007_cat2} {t8_2007_cat2} {t9_2007_cat2} {t10_2007_cat2} {t11_2007_cat2} {t12_2007_cat2} ///
        {t_7_2007_cat3} {t_6_2007_cat3} {t_5_2007_cat3} {t_4_2007_cat3} {t_3_2007_cat3} {t_2_2007_cat3} {t_1_2007_cat3} ///
        {t1_2007_cat3} {t2_2007_cat3} {t3_2007_cat3} {t4_2007_cat3} {t5_2007_cat3} {t6_2007_cat3} {t7_2007_cat3} {t8_2007_cat3} {t9_2007_cat3} {t10_2007_cat3} {t11_2007_cat3} {t12_2007_cat3} ///
        {t_7_2007_cat4} {t_6_2007_cat4} {t_5_2007_cat4} {t_4_2007_cat4} {t_3_2007_cat4} {t_2_2007_cat4} {t_1_2007_cat4} ///
        {t1_2007_cat4} {t2_2007_cat4} {t3_2007_cat4} {t4_2007_cat4} {t5_2007_cat4} {t6_2007_cat4} {t7_2007_cat4} {t8_2007_cat4} {t9_2007_cat4} {t10_2007_cat4} {t11_2007_cat4} {t12_2007_cat4}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)

* Guardar p-values para cada categoria
* Para PE (2007) Categoria 1
matrix pvalue2007_cat1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19), .

* Para PE (2007) Categoria 2
matrix pvalue2007_cat2 = r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), r(p_26), ///
                  r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), r(p_38), ., .

* Para PE (2007) Categoria 3
matrix pvalue2007_cat3 = r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), r(p_45), ///
                   r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), r(p_54), r(p_55), r(p_56), r(p_57), ., ., .

* Para PE (2007) Categoria 4
matrix pvalue2007_cat4 = r(p_58), r(p_59), r(p_60), r(p_61), r(p_62), r(p_63), r(p_64), ///
                  r(p_65), r(p_66), r(p_67), r(p_68), r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75), r(p_76), ., ., ., .

* Testes de tendências paralelas (pré-tratamento)
* Para PE (2007) Categoria 1
test t_7_2007_cat1 t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1
scalar f2007_cat1 = r(F)
scalar f2007p_cat1 = r(p)

* Para PE (2007) Categoria 2
test t_7_2007_cat2 t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2
scalar f2007_cat2 = r(F)
scalar f2007p_cat2 = r(p)

* Para PE (2007) Categoria 3
test t_7_2007_cat3 t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3
scalar f2007_cat3 = r(F)
scalar f2007p_cat3 = r(p)

* Para PE (2007) Categoria 4
test t_7_2007_cat4 t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4
scalar f2007_cat4 = r(F)
scalar f2007p_cat4 = r(p)

********************************************************************************
* Criar tendência específica por categoria para PE
********************************************************************************
gen trend = year - 2000 // Tendência linear começando em 2000

* Criar tendências específicas para cada categoria de PE
gen partrend2007_cat1 = trend * t2007 * delcap1
gen partrend2007_cat2 = trend * t2007 * delcap2
gen partrend2007_cat3 = trend * t2007 * delcap3
gen partrend2007_cat4 = trend * t2007 * delcap4

********************************************************************************
* Parte 2: Event Study com Tendências Lineares Específicas por Categoria para PE
********************************************************************************

* IMPORTANTE: Remover t_7 para cada categoria (seguindo a lógica do código original)
* Modelo com todas as variáveis incluindo tendências lineares específicas por categoria
xtreg taxa_homicidios_total_por_100m_1 ///
    t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1 ///
    t1_2007_cat1 t2_2007_cat1 t3_2007_cat1 t4_2007_cat1 t5_2007_cat1 t6_2007_cat1 t7_2007_cat1 t8_2007_cat1 t9_2007_cat1 t10_2007_cat1 t11_2007_cat1 t12_2007_cat1 ///
    partrend2007_cat1 ///
    t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2 ///
    t1_2007_cat2 t2_2007_cat2 t3_2007_cat2 t4_2007_cat2 t5_2007_cat2 t6_2007_cat2 t7_2007_cat2 t8_2007_cat2 t9_2007_cat2 t10_2007_cat2 t11_2007_cat2 t12_2007_cat2 ///
    partrend2007_cat2 ///
    t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3 ///
    t1_2007_cat3 t2_2007_cat3 t3_2007_cat3 t4_2007_cat3 t5_2007_cat3 t6_2007_cat3 t7_2007_cat3 t8_2007_cat3 t9_2007_cat3 t10_2007_cat3 t11_2007_cat3 t12_2007_cat3 ///
    partrend2007_cat3 ///
    t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4 ///
    t1_2007_cat4 t2_2007_cat4 t3_2007_cat4 t4_2007_cat4 t5_2007_cat4 t6_2007_cat4 t7_2007_cat4 t8_2007_cat4 t9_2007_cat4 t10_2007_cat4 t11_2007_cat4 t12_2007_cat4 ///
    partrend2007_cat4 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Salvar o número de observações
sca nobs_trend = e(N)

* Salvar os coeficientes completos
matrix betas_trend = e(b)

* Extrair coeficientes para cada categoria e tendência
* Para PE (2007) Categoria 1 - notamos que não temos mais t_7, então começamos em t_6
matrix betas2007_cat1_trend = ., betas_trend[1, 1..18], ., betas_trend[1, 19]
* Para PE (2007) Categoria 2
matrix betas2007_cat2_trend = ., betas_trend[1, 20..37], ., ., betas_trend[1, 38]
* Para PE (2007) Categoria 3
matrix betas2007_cat3_trend = ., betas_trend[1, 39..56], ., ., ., betas_trend[1, 57]
* Para PE (2007) Categoria 4
matrix betas2007_cat4_trend = ., betas_trend[1, 58..75], ., ., ., ., betas_trend[1, 76]

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007) Categoria 1
matrix vars2007_cat1_trend = ., A[1, 1..18], ., A[1, 19]
* Para PE (2007) Categoria 2
matrix vars2007_cat2_trend = ., A[1, 20..37], ., ., A[1, 38]
* Para PE (2007) Categoria 3
matrix vars2007_cat3_trend = ., A[1, 39..56], ., ., ., A[1, 57]
* Para PE (2007) Categoria 4
matrix vars2007_cat4_trend = ., A[1, 58..75], ., ., ., ., A[1, 76]

boottest {t_6_2007_cat1} {t_5_2007_cat1} {t_4_2007_cat1} {t_3_2007_cat1} {t_2_2007_cat1} {t_1_2007_cat1} ///
        {t1_2007_cat1} {t2_2007_cat1} {t3_2007_cat1} {t4_2007_cat1} {t5_2007_cat1} {t6_2007_cat1} {t7_2007_cat1} {t8_2007_cat1} {t9_2007_cat1} {t10_2007_cat1} {t11_2007_cat1} {t12_2007_cat1} ///
        {partrend2007_cat1} ///
        {t_6_2007_cat2} {t_5_2007_cat2} {t_4_2007_cat2} {t_3_2007_cat2} {t_2_2007_cat2} {t_1_2007_cat2} ///
        {t1_2007_cat2} {t2_2007_cat2} {t3_2007_cat2} {t4_2007_cat2} {t5_2007_cat2} {t6_2007_cat2} {t7_2007_cat2} {t8_2007_cat2} {t9_2007_cat2} {t10_2007_cat2} {t11_2007_cat2} {t12_2007_cat2} ///
        {partrend2007_cat2} ///
        {t_6_2007_cat3} {t_5_2007_cat3} {t_4_2007_cat3} {t_3_2007_cat3} {t_2_2007_cat3} {t_1_2007_cat3} ///
        {t1_2007_cat3} {t2_2007_cat3} {t3_2007_cat3} {t4_2007_cat3} {t5_2007_cat3} {t6_2007_cat3} {t7_2007_cat3} {t8_2007_cat3} {t9_2007_cat3} {t10_2007_cat3} {t11_2007_cat3} {t12_2007_cat3} ///
        {partrend2007_cat3} ///
        {t_6_2007_cat4} {t_5_2007_cat4} {t_4_2007_cat4} {t_3_2007_cat4} {t_2_2007_cat4} {t_1_2007_cat4} ///
        {t1_2007_cat4} {t2_2007_cat4} {t3_2007_cat4} {t4_2007_cat4} {t5_2007_cat4} {t6_2007_cat4} {t7_2007_cat4} {t8_2007_cat4} {t9_2007_cat4} {t10_2007_cat4} {t11_2007_cat4} {t12_2007_cat4} ///
        {partrend2007_cat4}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)

* Guardar p-values para cada categoria e tendência
* Por causa da remoção de t_7, ajustamos os índices
matrix pvalue2007_cat1_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), ., r(p_19)

matrix pvalue2007_cat2_trend = ., r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), ///
                  r(p_26), r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), ., ., r(p_38)

matrix pvalue2007_cat3_trend = ., r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), ///
                  r(p_45), r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), r(p_54), r(p_55), r(p_56), ., ., ., r(p_57)

matrix pvalue2007_cat4_trend = ., r(p_58), r(p_59), r(p_60), r(p_61), r(p_62), r(p_63), ///
                  r(p_64), r(p_65), r(p_66), r(p_67), r(p_68), r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75), ., ., ., ., r(p_76)

* Testes de tendências paralelas (pré-tratamento) - excluindo t_7 conforme especificação
* Para PE (2007) Categoria 1
test t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1
scalar f2007_cat1_trend = r(F)
scalar f2007p_cat1_trend = r(p)

* Para PE (2007) Categoria 2
test t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2
scalar f2007_cat2_trend = r(F)
scalar f2007p_cat2_trend = r(p)

* Para PE (2007) Categoria 3
test t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3
scalar f2007_cat3_trend = r(F)
scalar f2007p_cat3_trend = r(p)

* Para PE (2007) Categoria 4
test t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4
scalar f2007_cat4_trend = r(F)
scalar f2007p_cat4_trend = r(p)

********************************************************************************
* Criar gráficos de event study para PE com as 4 categorias
********************************************************************************

* PARTE 1: GRÁFICO SEM TENDÊNCIAS

* Criar dataset a partir das matrizes para facilitar a plotagem
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* PE (2007) - Categoria 1: low cap & close delegacia
gen coef_2007_cat1 = .
gen se_2007_cat1 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat1 = betas2007_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1 = vars2007_cat1[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat1 = 0 if rel_year == 0
replace se_2007_cat1 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat1 = betas2007_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1 = vars2007_cat1[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 2: low cap & far delegacia
gen coef_2007_cat2 = .
gen se_2007_cat2 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat2 = betas2007_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2 = vars2007_cat2[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat2 = 0 if rel_year == 0
replace se_2007_cat2 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat2 = betas2007_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2 = vars2007_cat2[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 3: high cap & close delegacia
gen coef_2007_cat3 = .
gen se_2007_cat3 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat3 = betas2007_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3 = vars2007_cat3[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat3 = 0 if rel_year == 0
replace se_2007_cat3 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat3 = betas2007_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3 = vars2007_cat3[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 4: high cap & far delegacia
gen coef_2007_cat4 = .
gen se_2007_cat4 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat4 = betas2007_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4 = vars2007_cat4[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat4 = 0 if rel_year == 0
replace se_2007_cat4 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat4 = betas2007_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4 = vars2007_cat4[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2007_cat1 = coef_2007_cat1 + 1.96 * se_2007_cat1
gen ci_lower_2007_cat1 = coef_2007_cat1 - 1.96 * se_2007_cat1
gen ci_upper_2007_cat2 = coef_2007_cat2 + 1.96 * se_2007_cat2
gen ci_lower_2007_cat2 = coef_2007_cat2 - 1.96 * se_2007_cat2
gen ci_upper_2007_cat3 = coef_2007_cat3 + 1.96 * se_2007_cat3
gen ci_lower_2007_cat3 = coef_2007_cat3 - 1.96 * se_2007_cat3
gen ci_upper_2007_cat4 = coef_2007_cat4 + 1.96 * se_2007_cat4
gen ci_lower_2007_cat4 = coef_2007_cat4 - 1.96 * se_2007_cat4

* Gráfico para PE (2007) - 4 categorias (Sem Tendências)
twoway (rcap ci_upper_2007_cat1 ci_lower_2007_cat1 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(midblue)) ///
       (scatter coef_2007_cat1 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2007_cat2 ci_lower_2007_cat2 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(cranberry)) ///
       (scatter coef_2007_cat2 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2007_cat3 ci_lower_2007_cat3 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(forest_green)) ///
       (scatter coef_2007_cat3 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2007_cat4 ci_lower_2007_cat4 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(gold)) ///
       (scatter coef_2007_cat4 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Pernambuco (2007)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)12) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(pe_sem_tendencia, replace) scheme(s1mono)
       
* Salvar gráfico
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_PE.pdf", replace

* PARTE 2: GRÁFICO COM TENDÊNCIAS LINEARES

* Repetir o mesmo processo para os modelos com tendências lineares
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* PE (2007) - Categoria 1 com tendência
gen coef_2007_cat1_trend = .
gen se_2007_cat1_trend = .

* Preencher valores dos coeficientes e erros padrão - Note que começamos em t-6 (não tem t-7)
replace coef_2007_cat1_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat1_trend = betas2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1_trend = vars2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat1_trend = 0 if rel_year == 0
replace se_2007_cat1_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat1_trend = betas2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1_trend = vars2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 2 com tendência
gen coef_2007_cat2_trend = .
gen se_2007_cat2_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2007_cat2_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat2_trend = betas2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2_trend = vars2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat2_trend = 0 if rel_year == 0
replace se_2007_cat2_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat2_trend = betas2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2_trend = vars2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 3 com tendência
gen coef_2007_cat3_trend = .
gen se_2007_cat3_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2007_cat3_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat3_trend = betas2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3_trend = vars2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat3_trend = 0 if rel_year == 0
replace se_2007_cat3_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat3_trend = betas2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3_trend = vars2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 4 com tendência
gen coef_2007_cat4_trend = .
gen se_2007_cat4_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2007_cat4_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat4_trend = betas2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4_trend = vars2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2007_cat4_trend = 0 if rel_year == 0
replace se_2007_cat4_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat4_trend = betas2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4_trend = vars2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2007_cat1_trend = coef_2007_cat1_trend + 1.96 * se_2007_cat1_trend
gen ci_lower_2007_cat1_trend = coef_2007_cat1_trend - 1.96 * se_2007_cat1_trend
gen ci_upper_2007_cat2_trend = coef_2007_cat2_trend + 1.96 * se_2007_cat2_trend
gen ci_lower_2007_cat2_trend = coef_2007_cat2_trend - 1.96 * se_2007_cat2_trend
gen ci_upper_2007_cat3_trend = coef_2007_cat3_trend + 1.96 * se_2007_cat3_trend
gen ci_lower_2007_cat3_trend = coef_2007_cat3_trend - 1.96 * se_2007_cat3_trend
gen ci_upper_2007_cat4_trend = coef_2007_cat4_trend + 1.96 * se_2007_cat4_trend
gen ci_lower_2007_cat4_trend = coef_2007_cat4_trend - 1.96 * se_2007_cat4_trend

* Gráfico para PE (2007) - 4 categorias (Com Tendências)
twoway (rcap ci_upper_2007_cat1_trend ci_lower_2007_cat1_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(midblue)) ///
       (scatter coef_2007_cat1_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2007_cat2_trend ci_lower_2007_cat2_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(cranberry)) ///
       (scatter coef_2007_cat2_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2007_cat3_trend ci_lower_2007_cat3_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(forest_green)) ///
       (scatter coef_2007_cat3_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2007_cat4_trend ci_lower_2007_cat4_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(gold)) ///
       (scatter coef_2007_cat4_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Pernambuco (2007)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)12) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(pe_com_tendencia, replace) scheme(s1mono)

* Salvar gráfico
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_trends_PE.pdf", replace
