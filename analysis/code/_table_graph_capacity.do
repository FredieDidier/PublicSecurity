********************************************************************************
* Event Study em uma Única Regressão com Interação de Capacidade 
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

* Preparar variável de capacidade conforme solicitado
preserve
keep if year == 2006
* Calculando a porcentagem de funcionários com ensino superior em relação ao total
gen porc_func_superior = (funcionarios_superior / total_func_pub_munic) * 100
* Calculando a estatística descritiva para identificar a mediana
sum porc_func_superior, detail
* Criando a dummy high_cap_pc que é 1 se proporção > mediana, 0 caso contrário
gen high_cap_pc = (porc_func_superior > r(p50))
* Mantendo apenas as variáveis necessárias para o merge
keep municipality_code high_cap_pc
save "temp_high_cap_pc.dta", replace
restore

* Fazendo o merge com o dataset principal
merge m:1 municipality_code using "temp_high_cap_pc.dta", nogenerate
erase "temp_high_cap_pc.dta"

* Criar dummy para baixa capacidade
gen low_cap_pc = 1 - high_cap_pc

******************************************************************************
* Criar dummies de evento para todas as coortes interagidas com capacidade
******************************************************************************

* Para coorte 2007 (PE)
* Pré-tratamento: definir até t-7 com interações de capacidade
gen t_7_2007_high = t2007 * d2000 * high_cap_pc
gen t_7_2007_low = t2007 * d2000 * low_cap_pc
gen t_6_2007_high = t2007 * d2001 * high_cap_pc
gen t_6_2007_low = t2007 * d2001 * low_cap_pc
gen t_5_2007_high = t2007 * d2002 * high_cap_pc
gen t_5_2007_low = t2007 * d2002 * low_cap_pc
gen t_4_2007_high = t2007 * d2003 * high_cap_pc
gen t_4_2007_low = t2007 * d2003 * low_cap_pc
gen t_3_2007_high = t2007 * d2004 * high_cap_pc
gen t_3_2007_low = t2007 * d2004 * low_cap_pc
gen t_2_2007_high = t2007 * d2005 * high_cap_pc
gen t_2_2007_low = t2007 * d2005 * low_cap_pc
gen t_1_2007_high = t2007 * d2006 * high_cap_pc
gen t_1_2007_low = t2007 * d2006 * low_cap_pc
* Omitir o ano do tratamento (2007)
* Pós-tratamento
gen t1_2007_high = t2007 * d2008 * high_cap_pc
gen t1_2007_low = t2007 * d2008 * low_cap_pc
gen t2_2007_high = t2007 * d2009 * high_cap_pc
gen t2_2007_low = t2007 * d2009 * low_cap_pc
gen t3_2007_high = t2007 * d2010 * high_cap_pc
gen t3_2007_low = t2007 * d2010 * low_cap_pc
gen t4_2007_high = t2007 * d2011 * high_cap_pc
gen t4_2007_low = t2007 * d2011 * low_cap_pc
gen t5_2007_high = t2007 * d2012 * high_cap_pc
gen t5_2007_low = t2007 * d2012 * low_cap_pc
gen t6_2007_high = t2007 * d2013 * high_cap_pc
gen t6_2007_low = t2007 * d2013 * low_cap_pc
gen t7_2007_high = t2007 * d2014 * high_cap_pc
gen t7_2007_low = t2007 * d2014 * low_cap_pc
gen t8_2007_high = t2007 * d2015 * high_cap_pc
gen t8_2007_low = t2007 * d2015 * low_cap_pc
gen t9_2007_high = t2007 * d2016 * high_cap_pc
gen t9_2007_low = t2007 * d2016 * low_cap_pc
gen t10_2007_high = t2007 * d2017 * high_cap_pc
gen t10_2007_low = t2007 * d2017 * low_cap_pc
gen t11_2007_high = t2007 * d2018 * high_cap_pc
gen t11_2007_low = t2007 * d2018 * low_cap_pc
gen t12_2007_high = t2007 * d2019 * high_cap_pc
gen t12_2007_low = t2007 * d2019 * low_cap_pc

* Para coorte 2011 (BA, PB)
* Pré-tratamento
gen t_7_2011_high = t2011 * d2004 * high_cap_pc
gen t_7_2011_low = t2011 * d2004 * low_cap_pc
gen t_6_2011_high = t2011 * d2005 * high_cap_pc
gen t_6_2011_low = t2011 * d2005 * low_cap_pc
gen t_5_2011_high = t2011 * d2006 * high_cap_pc
gen t_5_2011_low = t2011 * d2006 * low_cap_pc
gen t_4_2011_high = t2011 * d2007 * high_cap_pc
gen t_4_2011_low = t2011 * d2007 * low_cap_pc
gen t_3_2011_high = t2011 * d2008 * high_cap_pc
gen t_3_2011_low = t2011 * d2008 * low_cap_pc
gen t_2_2011_high = t2011 * d2009 * high_cap_pc
gen t_2_2011_low = t2011 * d2009 * low_cap_pc
gen t_1_2011_high = t2011 * d2010 * high_cap_pc
gen t_1_2011_low = t2011 * d2010 * low_cap_pc
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011_high = t2011 * d2012 * high_cap_pc
gen t1_2011_low = t2011 * d2012 * low_cap_pc
gen t2_2011_high = t2011 * d2013 * high_cap_pc
gen t2_2011_low = t2011 * d2013 * low_cap_pc
gen t3_2011_high = t2011 * d2014 * high_cap_pc
gen t3_2011_low = t2011 * d2014 * low_cap_pc
gen t4_2011_high = t2011 * d2015 * high_cap_pc
gen t4_2011_low = t2011 * d2015 * low_cap_pc
gen t5_2011_high = t2011 * d2016 * high_cap_pc
gen t5_2011_low = t2011 * d2016 * low_cap_pc
gen t6_2011_high = t2011 * d2017 * high_cap_pc
gen t6_2011_low = t2011 * d2017 * low_cap_pc
gen t7_2011_high = t2011 * d2018 * high_cap_pc
gen t7_2011_low = t2011 * d2018 * low_cap_pc
gen t8_2011_high = t2011 * d2019 * high_cap_pc
gen t8_2011_low = t2011 * d2019 * low_cap_pc

* Para coorte 2015 (CE)
* Pré-tratamento
gen t_7_2015_high = t2015 * d2008 * high_cap_pc
gen t_7_2015_low = t2015 * d2008 * low_cap_pc
gen t_6_2015_high = t2015 * d2009 * high_cap_pc
gen t_6_2015_low = t2015 * d2009 * low_cap_pc
gen t_5_2015_high = t2015 * d2010 * high_cap_pc
gen t_5_2015_low = t2015 * d2010 * low_cap_pc
gen t_4_2015_high = t2015 * d2011 * high_cap_pc
gen t_4_2015_low = t2015 * d2011 * low_cap_pc
gen t_3_2015_high = t2015 * d2012 * high_cap_pc
gen t_3_2015_low = t2015 * d2012 * low_cap_pc
gen t_2_2015_high = t2015 * d2013 * high_cap_pc
gen t_2_2015_low = t2015 * d2013 * low_cap_pc
gen t_1_2015_high = t2015 * d2014 * high_cap_pc
gen t_1_2015_low = t2015 * d2014 * low_cap_pc
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015_high = t2015 * d2016 * high_cap_pc
gen t1_2015_low = t2015 * d2016 * low_cap_pc
gen t2_2015_high = t2015 * d2017 * high_cap_pc
gen t2_2015_low = t2015 * d2017 * low_cap_pc
gen t3_2015_high = t2015 * d2018 * high_cap_pc
gen t3_2015_low = t2015 * d2018 * low_cap_pc
gen t4_2015_high = t2015 * d2019 * high_cap_pc
gen t4_2015_low = t2015 * d2019 * low_cap_pc

* Para coorte 2016 (MA)
* Pré-tratamento
gen t_7_2016_high = t2016 * d2009 * high_cap_pc
gen t_7_2016_low = t2016 * d2009 * low_cap_pc
gen t_6_2016_high = t2016 * d2010 * high_cap_pc
gen t_6_2016_low = t2016 * d2010 * low_cap_pc
gen t_5_2016_high = t2016 * d2011 * high_cap_pc
gen t_5_2016_low = t2016 * d2011 * low_cap_pc
gen t_4_2016_high = t2016 * d2012 * high_cap_pc
gen t_4_2016_low = t2016 * d2012 * low_cap_pc
gen t_3_2016_high = t2016 * d2013 * high_cap_pc
gen t_3_2016_low = t2016 * d2013 * low_cap_pc
gen t_2_2016_high = t2016 * d2014 * high_cap_pc
gen t_2_2016_low = t2016 * d2014 * low_cap_pc
gen t_1_2016_high = t2016 * d2015 * high_cap_pc
gen t_1_2016_low = t2016 * d2015 * low_cap_pc
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016_high = t2016 * d2017 * high_cap_pc
gen t1_2016_low = t2016 * d2017 * low_cap_pc
gen t2_2016_high = t2016 * d2018 * high_cap_pc
gen t2_2016_low = t2016 * d2018 * low_cap_pc
gen t3_2016_high = t2016 * d2019 * high_cap_pc
gen t3_2016_low = t2016 * d2019 * low_cap_pc

********************************************************************************
* Parte 1: Event Study em uma Única Regressão com Capacidade
********************************************************************************

* Modelo com todas as variáveis e interações com capacidade
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
matrix betas2007_low = betas[1, 20..38], ., .
* Para BA/PB (2011) HIGH
matrix betas2011_high = betas[1, 39..53], ., ., .
* Para BA/PB (2011) LOW
matrix betas2011_low = betas[1, 54..68], ., ., ., .
* Para CE (2015) HIGH
matrix betas2015_high = betas[1, 69..79], ., ., ., ., .
* Para CE (2015) LOW
matrix betas2015_low = betas[1, 80..90], ., ., ., ., ., .
* Para MA (2016) HIGH
matrix betas2016_high = betas[1, 91..100], ., ., ., ., ., ., .
* Para MA (2016) LOW
matrix betas2016_low = betas[1, 101..110], ., ., ., ., ., ., ., .

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007) HIGH
matrix vars2007_high = A[1, 1..19], .
* Para PE (2007) LOW
matrix vars2007_low = A[1, 20..38], ., .
* Para BA/PB (2011) HIGH
matrix vars2011_high = A[1, 39..53], ., ., .
* Para BA/PB (2011) LOW
matrix vars2011_low = A[1, 54..68], ., ., ., .
* Para CE (2015) HIGH
matrix vars2015_high = A[1, 69..79], ., ., ., ., .
* Para CE (2015) LOW
matrix vars2015_low = A[1, 80..90], ., ., ., ., ., .
* Para MA (2016) HIGH
matrix vars2016_high = A[1, 91..100], ., ., ., ., ., ., .
* Para MA (2016) LOW
matrix vars2016_low = A[1, 101..110], ., ., ., ., ., ., ., .

* Calcular p-values usando boottest com Webb weights
boottest {t_7_2007_high} {t_6_2007_high} {t_5_2007_high} {t_4_2007_high} {t_3_2007_high} {t_2_2007_high} {t_1_2007_high} ///
        {t1_2007_high} {t2_2007_high} {t3_2007_high} {t4_2007_high} {t5_2007_high} {t6_2007_high} {t7_2007_high} {t8_2007_high} {t9_2007_high} {t10_2007_high} {t11_2007_high} {t12_2007_high} ///
        {t_7_2007_low} {t_6_2007_low} {t_5_2007_low} {t_4_2007_low} {t_3_2007_low} {t_2_2007_low} {t_1_2007_low} ///
        {t1_2007_low} {t2_2007_low} {t3_2007_low} {t4_2007_low} {t5_2007_low} {t6_2007_low} {t7_2007_low} {t8_2007_low} {t9_2007_low} {t10_2007_low} {t11_2007_low} {t12_2007_low} ///
        {t_7_2011_high} {t_6_2011_high} {t_5_2011_high} {t_4_2011_high} {t_3_2011_high} {t_2_2011_high} {t_1_2011_high} ///
        {t1_2011_high} {t2_2011_high} {t3_2011_high} {t4_2011_high} {t5_2011_high} {t6_2011_high} {t7_2011_high} {t8_2011_high} ///
        {t_7_2011_low} {t_6_2011_low} {t_5_2011_low} {t_4_2011_low} {t_3_2011_low} {t_2_2011_low} {t_1_2011_low} ///
        {t1_2011_low} {t2_2011_low} {t3_2011_low} {t4_2011_low} {t5_2011_low} {t6_2011_low} {t7_2011_low} {t8_2011_low} ///
        {t_7_2015_high} {t_6_2015_high} {t_5_2015_high} {t_4_2015_high} {t_3_2015_high} {t_2_2015_high} {t_1_2015_high} ///
        {t1_2015_high} {t2_2015_high} {t3_2015_high} {t4_2015_high} ///
        {t_7_2015_low} {t_6_2015_low} {t_5_2015_low} {t_4_2015_low} {t_3_2015_low} {t_2_2015_low} {t_1_2015_low} ///
        {t1_2015_low} {t2_2015_low} {t3_2015_low} {t4_2015_low} ///
        {t_7_2016_high} {t_6_2016_high} {t_5_2016_high} {t_4_2016_high} {t_3_2016_high} {t_2_2016_high} {t_1_2016_high} ///
        {t1_2016_high} {t2_2016_high} {t3_2016_high} ///
        {t_7_2016_low} {t_6_2016_low} {t_5_2016_low} {t_4_2016_low} {t_3_2016_low} {t_2_2016_low} {t_1_2016_low} ///
        {t1_2016_low} {t2_2016_low} {t3_2016_low}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)

* Guardar p-values para cada coorte HIGH
matrix pvalue2007_high = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19), .

* Guardar p-values para cada coorte LOW
matrix pvalue2007_low = r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), r(p_26), ///
                  r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), r(p_38), ., .

matrix pvalue2011_high = r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), r(p_45), ///
                  r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), ., ., .

matrix pvalue2011_low = r(p_54), r(p_55), r(p_56), r(p_57), r(p_58), r(p_59), r(p_60), ///
                 r(p_61), r(p_62), r(p_63), r(p_64), r(p_65), r(p_66), r(p_67), r(p_68), ., ., ., .

matrix pvalue2015_high = r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75), ///
                  r(p_76), r(p_77), r(p_78), r(p_79), ., ., ., .

matrix pvalue2015_low = r(p_80), r(p_81), r(p_82), r(p_83), r(p_84), r(p_85), r(p_86), ///
                 r(p_87), r(p_88), r(p_89), r(p_90), ., ., ., ., .

matrix pvalue2016_high = r(p_91), r(p_92), r(p_93), r(p_94), r(p_95), r(p_96), r(p_97), ///
                  r(p_98), r(p_99), r(p_100), ., ., ., ., ., .

matrix pvalue2016_low = r(p_101), r(p_102), r(p_103), r(p_104), r(p_105), r(p_106), r(p_107), ///
                 r(p_108), r(p_109), r(p_110), ., ., ., ., ., ., .

* Testes de tendências paralelas (pré-tratamento)
* Para PE (2007) HIGH
test t_7_2007_high t_6_2007_high t_5_2007_high t_4_2007_high t_3_2007_high t_2_2007_high t_1_2007_high
scalar f2007_high = r(F)
scalar f2007p_high = r(p)

* Para PE (2007) LOW
test t_7_2007_low t_6_2007_low t_5_2007_low t_4_2007_low t_3_2007_low t_2_2007_low t_1_2007_low
scalar f2007_low = r(F)
scalar f2007p_low = r(p)

* Para BA/PB (2011) HIGH
test t_7_2011_high t_6_2011_high t_5_2011_high t_4_2011_high t_3_2011_high t_2_2011_high t_1_2011_high
scalar f2011_high = r(F)
scalar f2011p_high = r(p)

* Para BA/PB (2011) LOW
test t_7_2011_low t_6_2011_low t_5_2011_low t_4_2011_low t_3_2011_low t_2_2011_low t_1_2011_low
scalar f2011_low = r(F)
scalar f2011p_low = r(p)

* Para CE (2015) HIGH
test t_7_2015_high t_6_2015_high t_5_2015_high t_4_2015_high t_3_2015_high t_2_2015_high t_1_2015_high
scalar f2015_high = r(F)
scalar f2015p_high = r(p)


* Para CE (2015) LOW
test t_7_2015_low t_6_2015_low t_5_2015_low t_4_2015_low t_3_2015_low t_2_2015_low t_1_2015_low
scalar f2015_low = r(F)
scalar f2015p_low = r(p)

* Para MA (2016) HIGH
test t_7_2016_high t_6_2016_high t_5_2016_high t_4_2016_high t_3_2016_high t_2_2016_high t_1_2016_high
scalar f2016_high = r(F)
scalar f2016p_high = r(p)

* Para MA (2016) LOW
test t_7_2016_low t_6_2016_low t_5_2016_low t_4_2016_low t_3_2016_low t_2_2016_low t_1_2016_low
scalar f2016_low = r(F)
scalar f2016p_low = r(p)


********************************************************************************
* Criar tendência específica por coorte e capacidade
********************************************************************************
gen trend = year - 2000 // Tendência linear começando em 2000

* Criar tendências específicas para cada coorte e capacidade
gen partrend2007_high = trend * t2007 * high_cap_pc
gen partrend2007_low = trend * t2007 * low_cap_pc
gen partrend2011_high = trend * t2011 * high_cap_pc
gen partrend2011_low = trend * t2011 * low_cap_pc
gen partrend2015_high = trend * t2015 * high_cap_pc
gen partrend2015_low = trend * t2015 * low_cap_pc
gen partrend2016_high = trend * t2016 * high_cap_pc
gen partrend2016_low = trend * t2016 * low_cap_pc

********************************************************************************
* Parte 2: Event Study com Tendências Lineares Específicas por Coorte e Capacidade
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

* Extrair coeficientes para cada coorte e capacidade, incluindo as tendências
* Para PE (2007) HIGH - notamos que não temos mais t_7, então começamos em t_6
matrix betas2007_high_trend = ., betas_trend[1, 1..18], ., betas_trend[1, 19]
* Para PE (2007) LOW
matrix betas2007_low_trend = ., betas_trend[1, 20..37], ., ., betas_trend[1, 38]
* Para BA/PB (2011) HIGH
matrix betas2011_high_trend = ., betas_trend[1, 39..52], ., ., ., betas_trend[1, 53]
* Para BA/PB (2011) LOW
matrix betas2011_low_trend = ., betas_trend[1, 54..67], ., ., ., ., betas_trend[1, 68]
* Para CE (2015) HIGH
matrix betas2015_high_trend = ., betas_trend[1, 69..78], ., ., ., ., ., betas_trend[1, 79]
* Para CE (2015) LOW
matrix betas2015_low_trend = ., betas_trend[1, 80..89], ., ., ., ., ., ., betas_trend[1, 90]
* Para MA (2016) HIGH
matrix betas2016_high_trend = ., betas_trend[1, 91..99], ., ., ., ., ., ., ., betas_trend[1, 100]
* Para MA (2016) LOW
matrix betas2016_low_trend = ., betas_trend[1, 101..109], ., ., ., ., ., ., ., ., betas_trend[1, 110]

* Extrair erros padrão
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* Para PE (2007) HIGH
matrix vars2007_high_trend = ., A[1, 1..18], ., A[1, 19]
* Para PE (2007) LOW
matrix vars2007_low_trend = ., A[1, 20..37], ., ., A[1, 38]
* Para BA/PB (2011) HIGH
matrix vars2011_high_trend = ., A[1, 39..52], ., ., ., A[1, 53]
* Para BA/PB (2011) LOW
matrix vars2011_low_trend = ., A[1, 54..67], ., ., ., ., A[1, 68]
* Para CE (2015) HIGH
matrix vars2015_high_trend = ., A[1, 69..78], ., ., ., ., ., A[1, 79]
* Para CE (2015) LOW
matrix vars2015_low_trend = ., A[1, 80..89], ., ., ., ., ., ., A[1, 90]
* Para MA (2016) HIGH
matrix vars2016_high_trend = ., A[1, 91..99], ., ., ., ., ., ., ., A[1, 100]
* Para MA (2016) LOW
matrix vars2016_low_trend = ., A[1, 101..109], ., ., ., ., ., ., ., ., A[1, 110]

* Calcular p-values usando boottest com Webb weights
boottest {t_6_2007_high} {t_5_2007_high} {t_4_2007_high} {t_3_2007_high} {t_2_2007_high} {t_1_2007_high} ///
        {t1_2007_high} {t2_2007_high} {t3_2007_high} {t4_2007_high} {t5_2007_high} {t6_2007_high} {t7_2007_high} {t8_2007_high} {t9_2007_high} {t10_2007_high} {t11_2007_high} {t12_2007_high} ///
        {partrend2007_high} ///
        {t_6_2007_low} {t_5_2007_low} {t_4_2007_low} {t_3_2007_low} {t_2_2007_low} {t_1_2007_low} ///
        {t1_2007_low} {t2_2007_low} {t3_2007_low} {t4_2007_low} {t5_2007_low} {t6_2007_low} {t7_2007_low} {t8_2007_low} {t9_2007_low} {t10_2007_low} {t11_2007_low} {t12_2007_low} ///
        {partrend2007_low} ///
        {t_6_2011_high} {t_5_2011_high} {t_4_2011_high} {t_3_2011_high} {t_2_2011_high} {t_1_2011_high} ///
        {t1_2011_high} {t2_2011_high} {t3_2011_high} {t4_2011_high} {t5_2011_high} {t6_2011_high} {t7_2011_high} {t8_2011_high} ///
        {partrend2011_high} ///
        {t_6_2011_low} {t_5_2011_low} {t_4_2011_low} {t_3_2011_low} {t_2_2011_low} {t_1_2011_low} ///
        {t1_2011_low} {t2_2011_low} {t3_2011_low} {t4_2011_low} {t5_2011_low} {t6_2011_low} {t7_2011_low} {t8_2011_low} ///
        {partrend2011_low} ///
        {t_6_2015_high} {t_5_2015_high} {t_4_2015_high} {t_3_2015_high} {t_2_2015_high} {t_1_2015_high} ///
        {t1_2015_high} {t2_2015_high} {t3_2015_high} {t4_2015_high} ///
        {partrend2015_high} ///
        {t_6_2015_low} {t_5_2015_low} {t_4_2015_low} {t_3_2015_low} {t_2_2015_low} {t_1_2015_low} ///
        {t1_2015_low} {t2_2015_low} {t3_2015_low} {t4_2015_low} ///
        {partrend2015_low} ///
        {t_6_2016_high} {t_5_2016_high} {t_4_2016_high} {t_3_2016_high} {t_2_2016_high} {t_1_2016_high} ///
        {t1_2016_high} {t2_2016_high} {t3_2016_high} ///
        {partrend2016_high} ///
        {t_6_2016_low} {t_5_2016_low} {t_4_2016_low} {t_3_2016_low} {t_2_2016_low} {t_1_2016_low} ///
        {t1_2016_low} {t2_2016_low} {t3_2016_low} ///
        {partrend2016_low}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)

* Guardar p-values para cada coorte e capacidade, incluindo as tendências
* Por causa da remoção de t_7, ajustamos os índices
matrix pvalue2007_high_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), ., r(p_19)

matrix pvalue2007_low_trend = ., r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), ///
                  r(p_26), r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), ., ., r(p_38)

matrix pvalue2011_high_trend = ., r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), ///
                  r(p_45), r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), ., ., ., r(p_53)

matrix pvalue2011_low_trend = ., r(p_54), r(p_55), r(p_56), r(p_57), r(p_58), r(p_59), ///
                  r(p_60), r(p_61), r(p_62), r(p_63), r(p_64), r(p_65), r(p_66), r(p_67), ., ., ., ., r(p_68)

matrix pvalue2015_high_trend = ., r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), ///
                  r(p_75), r(p_76), r(p_77), r(p_78), ., ., ., ., ., r(p_79)

matrix pvalue2015_low_trend = ., r(p_80), r(p_81), r(p_82), r(p_83), r(p_84), r(p_85), ///
                  r(p_86), r(p_87), r(p_88), r(p_89), ., ., ., ., ., ., r(p_90)

matrix pvalue2016_high_trend = ., r(p_91), r(p_92), r(p_93), r(p_94), r(p_95), r(p_96), ///
                  r(p_97), r(p_98), r(p_99), ., ., ., ., ., ., ., r(p_100)

matrix pvalue2016_low_trend = ., r(p_101), r(p_102), r(p_103), r(p_104), r(p_105), r(p_106), ///
                  r(p_107), r(p_108), r(p_109), ., ., ., ., ., ., ., ., r(p_110)

* Testes de tendências paralelas (pré-tratamento) - excluindo t_7 conforme especificação
* Para PE (2007) HIGH
test t_6_2007_high t_5_2007_high t_4_2007_high t_3_2007_high t_2_2007_high t_1_2007_high
scalar f2007_high_trend = r(F)
scalar f2007p_high_trend = r(p)

* Para PE (2007) LOW
test t_6_2007_low t_5_2007_low t_4_2007_low t_3_2007_low t_2_2007_low t_1_2007_low
scalar f2007_low_trend = r(F)
scalar f2007p_low_trend = r(p)

* Para BA/PB (2011) HIGH
test t_6_2011_high t_5_2011_high t_4_2011_high t_3_2011_high t_2_2011_high t_1_2011_high
scalar f2011_high_trend = r(F)
scalar f2011p_high_trend = r(p)

* Para BA/PB (2011) LOW
test t_6_2011_low t_5_2011_low t_4_2011_low t_3_2011_low t_2_2011_low t_1_2011_low
scalar f2011_low_trend = r(F)
scalar f2011p_low_trend = r(p)

* Para CE (2015) HIGH
test t_6_2015_high t_5_2015_high t_4_2015_high t_3_2015_high t_2_2015_high t_1_2015_high
scalar f2015_high_trend = r(F)
scalar f2015p_high_trend = r(p)

* Para CE (2015) LOW
test t_6_2015_low t_5_2015_low t_4_2015_low t_3_2015_low t_2_2015_low t_1_2015_low
scalar f2015_low_trend = r(F)
scalar f2015p_low_trend = r(p)

* Para MA (2016) HIGH
test t_6_2016_high t_5_2016_high t_4_2016_high t_3_2016_high t_2_2016_high t_1_2016_high
scalar f2016_high_trend = r(F)
scalar f2016p_high_trend = r(p)

* Para MA (2016) LOW
test t_6_2016_low t_5_2016_low t_4_2016_low t_3_2016_low t_2_2016_low t_1_2016_low
scalar f2016_low_trend = r(F)
scalar f2016p_low_trend = r(p)


********************************************************************************
* Criar gráficos de event study para cada coorte - alta e baixa capacidade
********************************************************************************

* PARTE 1: GRÁFICOS SEM TENDÊNCIAS

* Criar datasets a partir das matrizes para facilitar a plotagem
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* Primeira coorte: 2007 (PE)
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
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2007, replace) scheme(s1mono)
	   
	   * Salvar gráfico combinado
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/capacity_event_study_PE.pdf", replace

* Segunda coorte: 2011 (BA, PB)
* Alta capacidade
gen coef_2011_high = .
gen se_2011_high = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_high = betas2011_high[1,`pos'] if rel_year == `rel_year'
    replace se_2011_high = vars2011_high[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_high = 0 if rel_year == 0
replace se_2011_high = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_high = betas2011_high[1,`pos'] if rel_year == `rel_year'
    replace se_2011_high = vars2011_high[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2011_low = .
gen se_2011_low = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_low = betas2011_low[1,`pos'] if rel_year == `rel_year'
    replace se_2011_low = vars2011_low[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_low = 0 if rel_year == 0
replace se_2011_low = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_low = betas2011_low[1,`pos'] if rel_year == `rel_year'
    replace se_2011_low = vars2011_low[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2011_high = coef_2011_high + 1.96 * se_2011_high
gen ci_lower_2011_high = coef_2011_high - 1.96 * se_2011_high
gen ci_upper_2011_low = coef_2011_low + 1.96 * se_2011_low
gen ci_lower_2011_low = coef_2011_low - 1.96 * se_2011_low

* Gráfico para BA/PB (2011) - Alta vs Baixa capacidade
twoway (rcap ci_upper_2011_high ci_lower_2011_high rel_year if rel_year >= -7 & rel_year <= 8, lcolor(midblue)) ///
       (scatter coef_2011_high rel_year if rel_year >= -7 & rel_year <= 8, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2011_low ci_lower_2011_low rel_year if rel_year >= -7 & rel_year <= 8, lcolor(cranberry)) ///
       (scatter coef_2011_low rel_year if rel_year >= -7 & rel_year <= 8, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Bahia/Paraíba", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)8) ylabel(, angle(horizontal)) ///
       legend(order(2 "High Capacity" 4 "Low Capavity") position(6) rows(1)) ///
       name(coorte2011, replace) scheme(s1mono)

* Terceira coorte: 2015 (CE)
* Alta capacidade
gen coef_2015_high = .
gen se_2015_high = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_high = betas2015_high[1,`pos'] if rel_year == `rel_year'
    replace se_2015_high = vars2015_high[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_high = 0 if rel_year == 0
replace se_2015_high = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_high = betas2015_high[1,`pos'] if rel_year == `rel_year'
    replace se_2015_high = vars2015_high[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2015_low = .
gen se_2015_low = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_low = betas2015_low[1,`pos'] if rel_year == `rel_year'
    replace se_2015_low = vars2015_low[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_low = 0 if rel_year == 0
replace se_2015_low = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_low = betas2015_low[1,`pos'] if rel_year == `rel_year'
    replace se_2015_low = vars2015_low[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2015_high = coef_2015_high + 1.96 * se_2015_high
gen ci_lower_2015_high = coef_2015_high - 1.96 * se_2015_high
gen ci_upper_2015_low = coef_2015_low + 1.96 * se_2015_low
gen ci_lower_2015_low = coef_2015_low - 1.96 * se_2015_low

* Gráfico para CE (2015) - Alta vs Baixa capacidade
twoway (rcap ci_upper_2015_high ci_lower_2015_high rel_year if rel_year >= -7 & rel_year <= 4, lcolor(midblue)) ///
       (scatter coef_2015_high rel_year if rel_year >= -7 & rel_year <= 4, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2015_low ci_lower_2015_low rel_year if rel_year >= -7 & rel_year <= 4, lcolor(cranberry)) ///
       (scatter coef_2015_low rel_year if rel_year >= -7 & rel_year <= 4, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Ceará (2015)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)4) ylabel(, angle(horizontal)) ///
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2015, replace) scheme(s1mono)

* Quarta coorte: 2016 (MA)
* Alta capacidade
gen coef_2016_high = .
gen se_2016_high = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_high = betas2016_high[1,`pos'] if rel_year == `rel_year'
    replace se_2016_high = vars2016_high[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_high = 0 if rel_year == 0
replace se_2016_high = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_high = betas2016_high[1,`pos'] if rel_year == `rel_year'
    replace se_2016_high = vars2016_high[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2016_low = .
gen se_2016_low = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_low = betas2016_low[1,`pos'] if rel_year == `rel_year'
    replace se_2016_low = vars2016_low[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_low = 0 if rel_year == 0
replace se_2016_low = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_low = betas2016_low[1,`pos'] if rel_year == `rel_year'
    replace se_2016_low = vars2016_low[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2016_high = coef_2016_high + 1.96 * se_2016_high
gen ci_lower_2016_high = coef_2016_high - 1.96 * se_2016_high
gen ci_upper_2016_low = coef_2016_low + 1.96 * se_2016_low
gen ci_lower_2016_low = coef_2016_low - 1.96 * se_2016_low

* Gráfico para MA (2016) - Alta vs Baixa capacidade
twoway (rcap ci_upper_2016_high ci_lower_2016_high rel_year if rel_year >= -7 & rel_year <= 3, lcolor(midblue)) ///
       (scatter coef_2016_high rel_year if rel_year >= -7 & rel_year <= 3, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2016_low ci_lower_2016_low rel_year if rel_year >= -7 & rel_year <= 3, lcolor(cranberry)) ///
       (scatter coef_2016_low rel_year if rel_year >= -7 & rel_year <= 3, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Maranhão (2016)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)3) ylabel(, angle(horizontal)) ///
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2016, replace) scheme(s1mono)

* Combinar os quatro gráficos sem tendências
graph combine coorte2007 coorte2011 coorte2015 coorte2016, ///
              rows(2) cols(2) xsize(12) ysize(8) scale(0.8) name(combined_no_trend, replace)

* Salvar gráfico combinado
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/capacity_event_study.pdf", replace


********************************************************************************
* PARTE 2: GRÁFICOS COM TENDÊNCIAS LINEARES
********************************************************************************

* Repetir o mesmo processo para os modelos com tendências lineares
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* Primeira coorte: 2007 (PE) com tendência
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
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2007_trend, replace) scheme(s1mono)
	   
	   * Salvar gráfico combinado
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/capacity_event_study_PE_trends.pdf", replace

* Demais coortes com mesmo padrão
* Segunda coorte: 2011 (BA, PB) com tendência
* Alta capacidade
gen coef_2011_high_trend = .
gen se_2011_high_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2011_high_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_high_trend = betas2011_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_high_trend = vars2011_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_high_trend = 0 if rel_year == 0
replace se_2011_high_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_high_trend = betas2011_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_high_trend = vars2011_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2011_low_trend = .
gen se_2011_low_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2011_low_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_low_trend = betas2011_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_low_trend = vars2011_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_low_trend = 0 if rel_year == 0
replace se_2011_low_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_low_trend = betas2011_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_low_trend = vars2011_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2011_high_trend = coef_2011_high_trend + 1.96 * se_2011_high_trend
gen ci_lower_2011_high_trend = coef_2011_high_trend - 1.96 * se_2011_high_trend
gen ci_upper_2011_low_trend = coef_2011_low_trend + 1.96 * se_2011_low_trend
gen ci_lower_2011_low_trend = coef_2011_low_trend - 1.96 * se_2011_low_trend

* Gráfico para BA/PB (2011) - Alta vs Baixa capacidade com tendência
twoway (rcap ci_upper_2011_high_trend ci_lower_2011_high_trend rel_year if rel_year >= -6 & rel_year <= 8, lcolor(midblue)) ///
       (scatter coef_2011_high_trend rel_year if rel_year >= -6 & rel_year <= 8, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2011_low_trend ci_lower_2011_low_trend rel_year if rel_year >= -6 & rel_year <= 8, lcolor(cranberry)) ///
       (scatter coef_2011_low_trend rel_year if rel_year >= -6 & rel_year <= 8, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Bahia/Paraíba (2011)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)8) ylabel(, angle(horizontal)) ///
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2011_trend, replace) scheme(s1mono)

* Terceira coorte: 2015 (CE) com tendência
* Alta capacidade
gen coef_2015_high_trend = .
gen se_2015_high_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2015_high_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_high_trend = betas2015_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_high_trend = vars2015_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_high_trend = 0 if rel_year == 0
replace se_2015_high_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_high_trend = betas2015_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_high_trend = vars2015_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2015_low_trend = .
gen se_2015_low_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2015_low_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_low_trend = betas2015_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_low_trend = vars2015_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_low_trend = 0 if rel_year == 0
replace se_2015_low_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_low_trend = betas2015_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_low_trend = vars2015_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2015_high_trend = coef_2015_high_trend + 1.96 * se_2015_high_trend
gen ci_lower_2015_high_trend = coef_2015_high_trend - 1.96 * se_2015_high_trend
gen ci_upper_2015_low_trend = coef_2015_low_trend + 1.96 * se_2015_low_trend
gen ci_lower_2015_low_trend = coef_2015_low_trend - 1.96 * se_2015_low_trend

* Gráfico para CE (2015) - Alta vs Baixa capacidade com tendência
twoway (rcap ci_upper_2015_high_trend ci_lower_2015_high_trend rel_year if rel_year >= -6 & rel_year <= 4, lcolor(midblue)) ///
       (scatter coef_2015_high_trend rel_year if rel_year >= -6 & rel_year <= 4, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2015_low_trend ci_lower_2015_low_trend rel_year if rel_year >= -6 & rel_year <= 4, lcolor(cranberry)) ///
       (scatter coef_2015_low_trend rel_year if rel_year >= -6 & rel_year <= 4, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Ceará (2015)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)4) ylabel(, angle(horizontal)) ///
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2015_trend, replace) scheme(s1mono)

* Quarta coorte: 2016 (MA) com tendência
* Alta capacidade
gen coef_2016_high_trend = .
gen se_2016_high_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2016_high_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_high_trend = betas2016_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_high_trend = vars2016_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_high_trend = 0 if rel_year == 0
replace se_2016_high_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_high_trend = betas2016_high_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_high_trend = vars2016_high_trend[1,`pos'] if rel_year == `rel_year'
}

* Baixa capacidade
gen coef_2016_low_trend = .
gen se_2016_low_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2016_low_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_low_trend = betas2016_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_low_trend = vars2016_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_low_trend = 0 if rel_year == 0
replace se_2016_low_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_low_trend = betas2016_low_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_low_trend = vars2016_low_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2016_high_trend = coef_2016_high_trend + 1.96 * se_2016_high_trend
gen ci_lower_2016_high_trend = coef_2016_high_trend - 1.96 * se_2016_high_trend
gen ci_upper_2016_low_trend = coef_2016_low_trend + 1.96 * se_2016_low_trend
gen ci_lower_2016_low_trend = coef_2016_low_trend - 1.96 * se_2016_low_trend

* Gráfico para MA (2016) - Alta vs Baixa capacidade com tendência
twoway (rcap ci_upper_2016_high_trend ci_lower_2016_high_trend rel_year if rel_year >= -6 & rel_year <= 3, lcolor(midblue)) ///
       (scatter coef_2016_high_trend rel_year if rel_year >= -6 & rel_year <= 3, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2016_low_trend ci_lower_2016_low_trend rel_year if rel_year >= -6 & rel_year <= 3, lcolor(cranberry)) ///
       (scatter coef_2016_low_trend rel_year if rel_year >= -6 & rel_year <= 3, mcolor(cranberry) msymbol(triangle) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Maranhão (2016)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)3) ylabel(, angle(horizontal)) ///
       legend(order(2 "High Capacity" 4 "Low Capacity") position(6) rows(1)) ///
       name(coorte2016_trend, replace) scheme(s1mono)

* Combinar os quatro gráficos COM tendências
graph combine coorte2007_trend coorte2011_trend coorte2015_trend coorte2016_trend, ///
              rows(2) cols(2) xsize(12) ysize(8) scale(0.8) name(combined_trend, replace)

* Salvar gráfico combinado
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/capacity_event_study_trends.pdf", replace



