********************************************************************************
* Event Study em uma Única Regressão (seguindo o código original)
********************************************************************************

* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

* Configurar o seed para bootstrap
set seed 982638

* Criar a variável de tratamento
gen treated = 0
replace treated = 1 if (state == "PE" & year >= 2007) |(state == "BA" & year >= 2011) | ///
                      (state == "PB" & year >= 2011) | (state == "CE" & year >= 2015) | ///
                      (state == "MA" & year >= 2016)
* Criar a variável de ano de adoção (staggered treatment)
gen treatment_year = 0
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"
replace treatment_year = 2007 if state == "PE"
* Criar a variável de tempo relativo ao tratamento
gen rel_year = year - treatment_year

gen log_pop = log(population_muni)

* Definir ids para xtreg
xtset municipality_code year

* Changing Variable Name
gen hom_rate_outside_home = taxa_homicidios_fora_casa_por_10

* Criar dummies para as coortes de tratamento
gen t2007 = (treatment_year == 2007)  // PE
gen t2011 = (treatment_year == 2011)  // BA, PB
gen t2015 = (treatment_year == 2015)  // CE
gen t2016 = (treatment_year == 2016)  // MA
gen never = (treatment_year == 0)     // Nunca tratados

* Criar dummies de ano
forvalues y = 2000/2019 {
    gen d`y' = (year == `y')
}

******************************************************************************
* Criar dummies de evento para todas as coortes (seguindo formato original)
******************************************************************************

* Para coorte 2007 (PE)
* Pré-tratamento: definir até t-7 como no código original
gen t_7_2007 = t2007 * d2000
gen t_6_2007 = t2007 * d2001
gen t_5_2007 = t2007 * d2002
gen t_4_2007 = t2007 * d2003
gen t_3_2007 = t2007 * d2004
gen t_2_2007 = t2007 * d2005
gen t_1_2007 = t2007 * d2006
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007 = t2007 * d2008
gen t2_2007 = t2007 * d2009
gen t3_2007 = t2007 * d2010
gen t4_2007 = t2007 * d2011
gen t5_2007 = t2007 * d2012
gen t6_2007 = t2007 * d2013
gen t7_2007 = t2007 * d2014
gen t8_2007 = t2007 * d2015
gen t9_2007 = t2007 * d2016
gen t10_2007 = t2007 * d2017
gen t11_2007 = t2007 * d2018
gen t12_2007 = t2007 * d2019

* Para coorte 2011 (BA, PB)
* Pré-tratamento
gen t_7_2011 = t2011 * d2004
gen t_6_2011 = t2011 * d2005
gen t_5_2011 = t2011 * d2006
gen t_4_2011 = t2011 * d2007
gen t_3_2011 = t2011 * d2008
gen t_2_2011 = t2011 * d2009
gen t_1_2011 = t2011 * d2010
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011 = t2011 * d2012
gen t2_2011 = t2011 * d2013
gen t3_2011 = t2011 * d2014
gen t4_2011 = t2011 * d2015
gen t5_2011 = t2011 * d2016
gen t6_2011 = t2011 * d2017
gen t7_2011 = t2011 * d2018
gen t8_2011 = t2011 * d2019

* Para coorte 2015 (CE)
* Pré-tratamento
gen t_7_2015 = t2015 * d2008
gen t_6_2015 = t2015 * d2009
gen t_5_2015 = t2015 * d2010
gen t_4_2015 = t2015 * d2011
gen t_3_2015 = t2015 * d2012
gen t_2_2015 = t2015 * d2013
gen t_1_2015 = t2015 * d2014
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015 = t2015 * d2016
gen t2_2015 = t2015 * d2017
gen t3_2015 = t2015 * d2018
gen t4_2015 = t2015 * d2019

* Para coorte 2016 (MA)
* Pré-tratamento
gen t_7_2016 = t2016 * d2009
gen t_6_2016 = t2016 * d2010
gen t_5_2016 = t2016 * d2011
gen t_4_2016 = t2016 * d2012
gen t_3_2016 = t2016 * d2013
gen t_2_2016 = t2016 * d2014
gen t_1_2016 = t2016 * d2015
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016 = t2016 * d2017
gen t2_2016 = t2016 * d2018
gen t3_2016 = t2016 * d2019

********************************************************************************
* Parte 1: Event Study em uma Única Regressão
********************************************************************************

* Modelo com todas as variáveis (similar ao código original)
xtreg hom_rate_outside_home ///
    t_7_2007 t_6_2007 t_5_2007 t_4_2007 t_3_2007 t_2_2007 t_1_2007 ///
    t1_2007 t2_2007 t3_2007 t4_2007 t5_2007 t6_2007 t7_2007 t8_2007 t9_2007 t10_2007 t11_2007 t12_2007 ///
    t_7_2011 t_6_2011 t_5_2011 t_4_2011 t_3_2011 t_2_2011 t_1_2011 ///
    t1_2011 t2_2011 t3_2011 t4_2011 t5_2011 t6_2011 t7_2011 t8_2011 ///
    t_7_2015 t_6_2015 t_5_2015 t_4_2015 t_3_2015 t_2_2015 t_1_2015 ///
    t1_2015 t2_2015 t3_2015 t4_2015 ///
    t_7_2016 t_6_2016 t_5_2016 t_4_2016 t_3_2016 t_2_2016 t_1_2016 ///
    t1_2016 t2_2016 t3_2016 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Salvar o número de observações
sca nobs = e(N)

* Salvar os coeficientes completos
matrix betas = e(b)

* Extrair coeficientes para cada coorte
* Para PE (2007)
matrix betas2007 = betas[1, 1..19], .
* Para BA/PB (2011)
matrix betas2011 = betas[1, 20..34], ., .
* Para CE (2015)
matrix betas2015 = betas[1, 35..45], ., ., .
* Para MA (2016)
matrix betas2016 = betas[1, 46..55], ., ., ., .

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007)
matrix vars2007 = A[1, 1..19], .
* Para BA/PB (2011)
matrix vars2011 = A[1, 20..34], ., .
* Para CE (2015)
matrix vars2015 = A[1, 35..45], ., ., .
* Para MA (2016)
matrix vars2016 = A[1, 46..55], ., ., ., .

* Calcular p-values usando boottest com Webb weights
boottest {t_7_2007} {t_6_2007} {t_5_2007} {t_4_2007} {t_3_2007} {t_2_2007} {t_1_2007} ///
        {t1_2007} {t2_2007} {t3_2007} {t4_2007} {t5_2007} {t6_2007} {t7_2007} {t8_2007} {t9_2007} {t10_2007} {t11_2007} {t12_2007} ///
        {t_7_2011} {t_6_2011} {t_5_2011} {t_4_2011} {t_3_2011} {t_2_2011} {t_1_2011} ///
        {t1_2011} {t2_2011} {t3_2011} {t4_2011} {t5_2011} {t6_2011} {t7_2011} {t8_2011} ///
        {t_7_2015} {t_6_2015} {t_5_2015} {t_4_2015} {t_3_2015} {t_2_2015} {t_1_2015} ///
        {t1_2015} {t2_2015} {t3_2015} {t4_2015} ///
        {t_7_2016} {t_6_2016} {t_5_2016} {t_4_2016} {t_3_2016} {t_2_2016} {t_1_2016} ///
        {t1_2016} {t2_2016} {t3_2016}, ///
        noci cluster(state_code) reps(999) weighttype(webb) seed(982638)

* Guardar p-values para cada coorte
matrix pvalue2007 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19), .

* Testes de tendências paralelas (pré-tratamento)
* Para PE (2007)
test t_7_2007 t_6_2007 t_5_2007 t_4_2007 t_3_2007 t_2_2007 t_1_2007
scalar f2007 = r(F)
scalar f2007p = r(p)

********************************************************************************
* Criar tendência específica por coorte
********************************************************************************
gen trend = year - 2000 // Tendência linear começando em 2000

* Criar tendências específicas para cada coorte
gen partrend2007 = trend * t2007
gen partrend2011 = trend * t2011
gen partrend2015 = trend * t2015
gen partrend2016 = trend * t2016

********************************************************************************
* Parte 2: Event Study com Tendências Lineares Específicas por Coorte
********************************************************************************

* IMPORTANTE: Remover t_7 para cada coorte (seguindo a lógica do código original)
* Modelo com todas as variáveis incluindo tendências lineares específicas por coorte
xtreg hom_rate_outside_home ///
    t_6_2007 t_5_2007 t_4_2007 t_3_2007 t_2_2007 t_1_2007 ///
    t1_2007 t2_2007 t3_2007 t4_2007 t5_2007 t6_2007 t7_2007 t8_2007 t9_2007 t10_2007 t11_2007 t12_2007 ///
    partrend2007 ///
    t_6_2011 t_5_2011 t_4_2011 t_3_2011 t_2_2011 t_1_2011 ///
    t1_2011 t2_2011 t3_2011 t4_2011 t5_2011 t6_2011 t7_2011 t8_2011 ///
    partrend2011 ///
    t_6_2015 t_5_2015 t_4_2015 t_3_2015 t_2_2015 t_1_2015 ///
    t1_2015 t2_2015 t3_2015 t4_2015 ///
    partrend2015 ///
    t_6_2016 t_5_2016 t_4_2016 t_3_2016 t_2_2016 t_1_2016 ///
    t1_2016 t2_2016 t3_2016 ///
    partrend2016 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Salvar o número de observações
sca nobs_trend = e(N)

* Salvar os coeficientes completos
matrix betas_trend = e(b)

* Extrair coeficientes para cada coorte, incluindo as tendências
* Para PE (2007) - notamos que não temos mais t_7, então começamos em t_6
matrix betas2007_trend = ., betas_trend[1, 1..18], ., betas_trend[1, 19]

* Calcular p-values usando boottest com Webb weights
boottest {t_6_2007} {t_5_2007} {t_4_2007} {t_3_2007} {t_2_2007} {t_1_2007} ///
        {t1_2007} {t2_2007} {t3_2007} {t4_2007} {t5_2007} {t6_2007} {t7_2007} {t8_2007} {t9_2007} {t10_2007} {t11_2007} {t12_2007} ///
        {partrend2007} ///
        {t_6_2011} {t_5_2011} {t_4_2011} {t_3_2011} {t_2_2011} {t_1_2011} ///
        {t1_2011} {t2_2011} {t3_2011} {t4_2011} {t5_2011} {t6_2011} {t7_2011} {t8_2011} ///
        {partrend2011} ///
        {t_6_2015} {t_5_2015} {t_4_2015} {t_3_2015} {t_2_2015} {t_1_2015} ///
        {t1_2015} {t2_2015} {t3_2015} {t4_2015} ///
        {partrend2015} ///
        {t_6_2016} {t_5_2016} {t_4_2016} {t_3_2016} {t_2_2016} {t_1_2016} ///
        {t1_2016} {t2_2016} {t3_2016} ///
        {partrend2016}, ///
        noci cluster(state_code) reps(999) weighttype(webb) seed(982638)

* Guardar p-values para cada coorte, incluindo as tendências
* Por causa da remoção de t_7, ajustamos os índices
matrix pvalue2007_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), ., r(p_19)

* Testes de tendências paralelas (pré-tratamento) - excluindo t_7 conforme especificação
* Para PE (2007)
test t_6_2007 t_5_2007 t_4_2007 t_3_2007 t_2_2007 t_1_2007
scalar f2007_trend = r(F)
scalar f2007p_trend = r(p)

********************************************************************************
* Criar Tabela LaTeX para Event Study - Homicídios Fora de Casa PE (2007)
********************************************************************************

* Abrir arquivo para escrever
cap file close f1
file open f1 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/outside_home_event_study_PE.tex", write replace

* Escrever cabeçalho da tabela
file write f1 "\documentclass[12pt]{article}" _n
file write f1 "\usepackage{booktabs}" _n
file write f1 "\usepackage{amsmath}" _n
file write f1 "\usepackage{caption}" _n
file write f1 "\usepackage{float}" _n
file write f1 "\usepackage{threeparttable}" _n
file write f1 "\usepackage{geometry}" _n
file write f1 "\usepackage{adjustbox}" _n
file write f1 "\usepackage{array}" _n
file write f1 "\begin{document}" _n
file write f1 "\begin{table}[H]" _n
file write f1 "\centering" _n
file write f1 "\label{tab:outside_home_event_study_PE}" _n
file write f1 "\begin{tabular}{lcc}" _n
file write f1 "\toprule" _n
file write f1 "& \multicolumn{2}{c}{PE (2007)} \\" _n
file write f1 "\cmidrule(lr){2-3}" _n
file write f1 "\midrule" _n

* Períodos pré-tratamento
* t-7 (apenas para o modelo sem tendência)
file write f1 "$\beta_{-7}$ & $" %7.3f (betas2007[1,1]) "$ & - \\" _n
file write f1 "& $(" %7.3f (vars2007[1,1]) ")$ & - \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,1]) "]$ & - \\" _n

* t-6
file write f1 "$\beta_{-6}$ & $" %7.3f (betas2007[1,2]) "$ & $" %7.3f (betas2007_trend[1,2]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,2]) ")$ & $(" %7.3f (vars2007_trend[1,2]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,2]) "]$ & $[" %7.3f (pvalue2007_trend[1,2]) "]$ \\" _n

* t-5
file write f1 "$\beta_{-5}$ & $" %7.3f (betas2007[1,3]) "$ & $" %7.3f (betas2007_trend[1,3]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,3]) ")$ & $(" %7.3f (vars2007_trend[1,3]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,3]) "]$ & $[" %7.3f (pvalue2007_trend[1,3]) "]$ \\" _n

* t-4
file write f1 "$\beta_{-4}$ & $" %7.3f (betas2007[1,4]) "$ & $" %7.3f (betas2007_trend[1,4]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,4]) ")$ & $(" %7.3f (vars2007_trend[1,4]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,4]) "]$ & $[" %7.3f (pvalue2007_trend[1,4]) "]$ \\" _n

* t-3
file write f1 "$\beta_{-3}$ & $" %7.3f (betas2007[1,5]) "$ & $" %7.3f (betas2007_trend[1,5]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,5]) ")$ & $(" %7.3f (vars2007_trend[1,5]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,5]) "]$ & $[" %7.3f (pvalue2007_trend[1,5]) "]$ \\" _n

* t-2
file write f1 "$\beta_{-2}$ & $" %7.3f (betas2007[1,6]) "$ & $" %7.3f (betas2007_trend[1,6]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,6]) ")$ & $(" %7.3f (vars2007_trend[1,6]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,6]) "]$ & $[" %7.3f (pvalue2007_trend[1,6]) "]$ \\" _n

* t-1
file write f1 "$\beta_{-1}$ & $" %7.3f (betas2007[1,7]) "$ & $" %7.3f (betas2007_trend[1,7]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,7]) ")$ & $(" %7.3f (vars2007_trend[1,7]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,7]) "]$ & $[" %7.3f (pvalue2007_trend[1,7]) "]$ \\" _n

* t+1
file write f1 "$\beta_{1}$ & $" %7.3f (betas2007[1,8]) "$ & $" %7.3f (betas2007_trend[1,8]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,8]) ")$ & $(" %7.3f (vars2007_trend[1,8]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,8]) "]$ & $[" %7.3f (pvalue2007_trend[1,8]) "]$ \\" _n

* t+2
file write f1 "$\beta_{2}$ & $" %7.3f (betas2007[1,9]) "$ & $" %7.3f (betas2007_trend[1,9]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,9]) ")$ & $(" %7.3f (vars2007_trend[1,9]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,9]) "]$ & $[" %7.3f (pvalue2007_trend[1,9]) "]$ \\" _n

* t+3
file write f1 "$\beta_{3}$ & $" %7.3f (betas2007[1,10]) "$ & $" %7.3f (betas2007_trend[1,10]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,10]) ")$ & $(" %7.3f (vars2007_trend[1,10]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,10]) "]$ & $[" %7.3f (pvalue2007_trend[1,10]) "]$ \\" _n

* t+4
file write f1 "$\beta_{4}$ & $" %7.3f (betas2007[1,11]) "$ & $" %7.3f (betas2007_trend[1,11]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,11]) ")$ & $(" %7.3f (vars2007_trend[1,11]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,11]) "]$ & $[" %7.3f (pvalue2007_trend[1,11]) "]$ \\" _n

* t+5
file write f1 "$\beta_{5}$ & $" %7.3f (betas2007[1,12]) "$ & $" %7.3f (betas2007_trend[1,12]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,12]) ")$ & $(" %7.3f (vars2007_trend[1,12]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,12]) "]$ & $[" %7.3f (pvalue2007_trend[1,12]) "]$ \\" _n

* t+6
file write f1 "$\beta_{6}$ & $" %7.3f (betas2007[1,13]) "$ & $" %7.3f (betas2007_trend[1,13]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,13]) ")$ & $(" %7.3f (vars2007_trend[1,13]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,13]) "]$ & $[" %7.3f (pvalue2007_trend[1,13]) "]$ \\" _n

* t+7
file write f1 "$\beta_{7}$ & $" %7.3f (betas2007[1,14]) "$ & $" %7.3f (betas2007_trend[1,14]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,14]) ")$ & $(" %7.3f (vars2007_trend[1,14]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,14]) "]$ & $[" %7.3f (pvalue2007_trend[1,14]) "]$ \\" _n

* t+8
file write f1 "$\beta_{8}$ & $" %7.3f (betas2007[1,15]) "$ & $" %7.3f (betas2007_trend[1,15]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,15]) ")$ & $(" %7.3f (vars2007_trend[1,15]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,15]) "]$ & $[" %7.3f (pvalue2007_trend[1,15]) "]$ \\" _n

* t+9
file write f1 "$\beta_{9}$ & $" %7.3f (betas2007[1,16]) "$ & $" %7.3f (betas2007_trend[1,16]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,16]) ")$ & $(" %7.3f (vars2007_trend[1,16]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,16]) "]$ & $[" %7.3f (pvalue2007_trend[1,16]) "]$ \\" _n

* t+10
file write f1 "$\beta_{10}$ & $" %7.3f (betas2007[1,17]) "$ & $" %7.3f (betas2007_trend[1,17]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,17]) ")$ & $(" %7.3f (vars2007_trend[1,17]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,17]) "]$ & $[" %7.3f (pvalue2007_trend[1,17]) "]$ \\" _n

* t+11
file write f1 "$\beta_{11}$ & $" %7.3f (betas2007[1,18]) "$ & $" %7.3f (betas2007_trend[1,18]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,18]) ")$ & $(" %7.3f (vars2007_trend[1,18]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,18]) "]$ & $[" %7.3f (pvalue2007_trend[1,18]) "]$ \\" _n

* t+12
file write f1 "$\beta_{12}$ & $" %7.3f (betas2007[1,19]) "$ & $" %7.3f (betas2007_trend[1,19]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,19]) ")$ & $(" %7.3f (vars2007_trend[1,19]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,19]) "]$ & $[" %7.3f (pvalue2007_trend[1,19]) "]$ \\" _n

* Adicionar informações sobre tendências e observações
file write f1 "\midrule" _n
file write f1 "Trends & No & Yes \\" _n
file write f1 "Observations & $" %9.0fc (nobs) "$ & $" %9.0fc (nobs_trend) "$ \\" _n
file write f1 "\bottomrule" _n

* Fechar tabela e adicionar notas
file write f1 "\end{tabular}" _n
file write f1 "\begin{threeparttable}" _n
file write f1 "\begin{tablenotes}" _n
file write f1 "\small" _n
file write f1 "\item Note: The dependent variable is the homicide rate outside home per 10k inhabitants. " _n
file write f1 "Standard errors clustered at the state level in parentheses. " _n
file write f1 "Wild bootstrap p-values (weighttype=webb) with 9999 replications in brackets. " _n
file write f1 "All regressions include municipality and year fixed effects, and are weighted by municipality population in 2000. " _n
file write f1 "Results are presented for Pernambuco, where the program was implemented in 2007. " _n
file write f1 "The model with trend includes a cohort-specific linear trend. " _n
file write f1 "\end{tablenotes}" _n
file write f1 "\end{threeparttable}" _n
file write f1 "\end{table}" _n
file write f1 "\end{document}" _n

* Fechar o arquivo
file close f1

********************************************************************************
* Parte 2: Gráficos de Event Study para cada coorte
********************************************************************************

* Converter matrizes para datasets para facilitar a plotagem
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12

* Gráfico para PE (2007)
gen coef_2007 = .
gen se_2007 = .
gen pvalue_2007 = .

* Preenchendo valores para a coorte 2007 (PE)
replace coef_2007 = betas2007[1,1] if rel_year == -7
replace coef_2007 = betas2007[1,2] if rel_year == -6
replace coef_2007 = betas2007[1,3] if rel_year == -5
replace coef_2007 = betas2007[1,4] if rel_year == -4
replace coef_2007 = betas2007[1,5] if rel_year == -3
replace coef_2007 = betas2007[1,6] if rel_year == -2
replace coef_2007 = betas2007[1,7] if rel_year == -1
replace coef_2007 = 0 if rel_year == 0  // Ano base (omitido)
replace coef_2007 = betas2007[1,8] if rel_year == 1
replace coef_2007 = betas2007[1,9] if rel_year == 2
replace coef_2007 = betas2007[1,10] if rel_year == 3
replace coef_2007 = betas2007[1,11] if rel_year == 4
replace coef_2007 = betas2007[1,12] if rel_year == 5
replace coef_2007 = betas2007[1,13] if rel_year == 6
replace coef_2007 = betas2007[1,14] if rel_year == 7
replace coef_2007 = betas2007[1,15] if rel_year == 8
replace coef_2007 = betas2007[1,16] if rel_year == 9
replace coef_2007 = betas2007[1,17] if rel_year == 10
replace coef_2007 = betas2007[1,18] if rel_year == 11
replace coef_2007 = betas2007[1,19] if rel_year == 12

* Preenchendo erros padrão para a coorte 2007
replace se_2007 = vars2007[1,1] if rel_year == -7
replace se_2007 = vars2007[1,2] if rel_year == -6
replace se_2007 = vars2007[1,3] if rel_year == -5
replace se_2007 = vars2007[1,4] if rel_year == -4
replace se_2007 = vars2007[1,5] if rel_year == -3
replace se_2007 = vars2007[1,6] if rel_year == -2
replace se_2007 = vars2007[1,7] if rel_year == -1
replace se_2007 = 0 if rel_year == 0  // Ano base (omitido)
replace se_2007 = vars2007[1,8] if rel_year == 1
replace se_2007 = vars2007[1,9] if rel_year == 2
replace se_2007 = vars2007[1,10] if rel_year == 3
replace se_2007 = vars2007[1,11] if rel_year == 4
replace se_2007 = vars2007[1,12] if rel_year == 5
replace se_2007 = vars2007[1,13] if rel_year == 6
replace se_2007 = vars2007[1,14] if rel_year == 7
replace se_2007 = vars2007[1,15] if rel_year == 8
replace se_2007 = vars2007[1,16] if rel_year == 9
replace se_2007 = vars2007[1,17] if rel_year == 10
replace se_2007 = vars2007[1,18] if rel_year == 11
replace se_2007 = vars2007[1,19] if rel_year == 12

* Calculando intervalos de confiança (95%)
gen ci_upper_2007 = coef_2007 + 1.96 * se_2007
gen ci_lower_2007 = coef_2007 - 1.96 * se_2007

* Gráfico para PE (2007)
twoway (rcap ci_upper_2007 ci_lower_2007 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(navy) msymbol(circle)) ///
       (connect coef_2007 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007 rel_year if rel_year == 0, msymbol(diamond) mcolor(red) msize(large)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       xline(0, lpattern(dash) lcolor(red)) yline(0, lpattern(dash) lcolor(black)) ///
       xlabel(-7(1)12) ///
       title("Pernambuco (2007)") ///
       legend(off) name(graph_2007, replace)
	   
	 graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/outside_home_event_study_PE.pdf", replace


********************************************************************************
* Graficos de Event Study com Tendências Específicas por Coorte
********************************************************************************

* Similar ao código original, mas agora para as estimativas com tendências lineares
* Primeiro vamos limpar o workspace para o novo dataset
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12

* Gráfico para PE (2007) com tendência
gen coef_2007_trend = .
gen se_2007_trend = .

* Preenchendo valores para a coorte 2007 (PE) com tendência
* Note que não temos mais o coeficiente para t-7 devido à especificação sem ele
replace coef_2007_trend = . if rel_year == -7
replace coef_2007_trend = betas2007_trend[1,2] if rel_year == -6
replace coef_2007_trend = betas2007_trend[1,3] if rel_year == -5
replace coef_2007_trend = betas2007_trend[1,4] if rel_year == -4
replace coef_2007_trend = betas2007_trend[1,5] if rel_year == -3
replace coef_2007_trend = betas2007_trend[1,6] if rel_year == -2
replace coef_2007_trend = betas2007_trend[1,7] if rel_year == -1
replace coef_2007_trend = 0 if rel_year == 0  // Ano base (omitido)
replace coef_2007_trend = betas2007_trend[1,8] if rel_year == 1
replace coef_2007_trend = betas2007_trend[1,9] if rel_year == 2
replace coef_2007_trend = betas2007_trend[1,10] if rel_year == 3
replace coef_2007_trend = betas2007_trend[1,11] if rel_year == 4
replace coef_2007_trend = betas2007_trend[1,12] if rel_year == 5
replace coef_2007_trend = betas2007_trend[1,13] if rel_year == 6
replace coef_2007_trend = betas2007_trend[1,14] if rel_year == 7
replace coef_2007_trend = betas2007_trend[1,15] if rel_year == 8
replace coef_2007_trend = betas2007_trend[1,16] if rel_year == 9
replace coef_2007_trend = betas2007_trend[1,17] if rel_year == 10
replace coef_2007_trend = betas2007_trend[1,18] if rel_year == 11
replace coef_2007_trend = betas2007_trend[1,19] if rel_year == 12

* Preenchendo erros padrão para a coorte 2007 com tendência
replace se_2007_trend = . if rel_year == -7
replace se_2007_trend = vars2007_trend[1,2] if rel_year == -6
replace se_2007_trend = vars2007_trend[1,3] if rel_year == -5
replace se_2007_trend = vars2007_trend[1,4] if rel_year == -4
replace se_2007_trend = vars2007_trend[1,5] if rel_year == -3
replace se_2007_trend = vars2007_trend[1,6] if rel_year == -2
replace se_2007_trend = vars2007_trend[1,7] if rel_year == -1
replace se_2007_trend = 0 if rel_year == 0  // Ano base (omitido)
replace se_2007_trend = vars2007_trend[1,8] if rel_year == 1
replace se_2007_trend = vars2007_trend[1,9] if rel_year == 2
replace se_2007_trend = vars2007_trend[1,10] if rel_year == 3
replace se_2007_trend = vars2007_trend[1,11] if rel_year == 4
replace se_2007_trend = vars2007_trend[1,12] if rel_year == 5
replace se_2007_trend = vars2007_trend[1,13] if rel_year == 6
replace se_2007_trend = vars2007_trend[1,14] if rel_year == 7
replace se_2007_trend = vars2007_trend[1,15] if rel_year == 8
replace se_2007_trend = vars2007_trend[1,16] if rel_year == 9
replace se_2007_trend = vars2007_trend[1,17] if rel_year == 10
replace se_2007_trend = vars2007_trend[1,18] if rel_year == 11
replace se_2007_trend = vars2007_trend[1,19] if rel_year == 12

* Calculando intervalos de confiança (95%)
gen ci_upper_2007_trend = coef_2007_trend + 1.96 * se_2007_trend
gen ci_lower_2007_trend = coef_2007_trend - 1.96 * se_2007_trend

* Gráfico para PE (2007) com tendência
twoway (rcap ci_upper_2007_trend ci_lower_2007_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(navy) msymbol(circle)) ///
       (connect coef_2007_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007_trend rel_year if rel_year == 0, msymbol(diamond) mcolor(red) msize(large)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       xline(0, lpattern(dash) lcolor(red)) yline(0, lpattern(dash) lcolor(black)) ///
       xlabel(-6(1)12) ///
       title("Pernambuco (2007)") ///
       legend(off) name(graph_2007_trend, replace)
	   
	   graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/outside_home_event_study_PE_trends.pdf", replace
