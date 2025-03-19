********************************************************************************
* Event Study para PE com Heterogeneidade por Capacidade e Distância a Delegacias
********************************************************************************

* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

* Configurar o seed para bootstrap
set seed 982638

* Criar a variável de ano de adoção
gen treatment_year = 0
replace treatment_year = 2007 if state == "PE"
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"

* Criar a variável de tempo relatvo ao tratamento
gen rel_year = year - treatment_year

gen log_pop = log(population_muni)

* Definir ids para xtreg
xtset municipality_code year

* Criar dummies para as coortes de tratamento
gen t2007 = (treatment_year == 2007)  // PE
gen t2011 = (treatment_year == 2011)  // BA, PB
gen t2015 = (treatment_year == 2015)  // CE
gen t2016 = (treatment_year == 2016)  // MA

* Criar dummies de ano
forvalues y = 2000/2019 {
    gen d`y' = (year == `y')
}

* Preparar variável de capacidade conforme solicitado
preserve
keep if year == 2006
drop if perc_superior == .
* Calculando a estatística descritiva para identificar a mediana
sum perc_superior, detail
* Criando a dummy high_cap que é 1 se proporção > mediana, 0 caso contrário
gen high_cap = (perc_superior > r(p50))
* Mantendo apenas as variáveis necessárias para o merge
keep municipality_code high_cap
save "temp_high_cap.dta", replace
restore

* Fazendo o merge com o dataset principal
merge m:1 municipality_code using "temp_high_cap.dta", nogenerate
erase "temp_high_cap.dta"

drop if high_cap == .
drop if population_2000_muni == .

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

******************************************************************************
* Criar dummies de evento para BA/PB (2011) interagidas com as 4 categorias
******************************************************************************

* Para coorte 2011 (BA, PB) - Categoria 1: low cap & close delegacia
* Pré-tratamento
gen t_11_2011_cat1 = t2011 * d2000 * delcap1
gen t_10_2011_cat1 = t2011 * d2001 * delcap1
gen t_9_2011_cat1 = t2011 * d2002 * delcap1
gen t_8_2011_cat1 = t2011 * d2003 * delcap1
gen t_7_2011_cat1 = t2011 * d2004 * delcap1
gen t_6_2011_cat1 = t2011 * d2005 * delcap1
gen t_5_2011_cat1 = t2011 * d2006 * delcap1
gen t_4_2011_cat1 = t2011 * d2007 * delcap1
gen t_3_2011_cat1 = t2011 * d2008 * delcap1
gen t_2_2011_cat1 = t2011 * d2009 * delcap1
gen t_1_2011_cat1 = t2011 * d2010 * delcap1
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011_cat1 = t2011 * d2012 * delcap1
gen t2_2011_cat1 = t2011 * d2013 * delcap1
gen t3_2011_cat1 = t2011 * d2014 * delcap1
gen t4_2011_cat1 = t2011 * d2015 * delcap1
gen t5_2011_cat1 = t2011 * d2016 * delcap1
gen t6_2011_cat1 = t2011 * d2017 * delcap1
gen t7_2011_cat1 = t2011 * d2018 * delcap1
gen t8_2011_cat1 = t2011 * d2019 * delcap1

* Para coorte 2011 (BA, PB) - Categoria 2: low cap & far delegacia
* Pré-tratamento
gen t_11_2011_cat2 = t2011 * d2000 * delcap2
gen t_10_2011_cat2 = t2011 * d2001 * delcap2
gen t_9_2011_cat2 = t2011 * d2002 * delcap2
gen t_8_2011_cat2 = t2011 * d2003 * delcap2
gen t_7_2011_cat2 = t2011 * d2004 * delcap2
gen t_6_2011_cat2 = t2011 * d2005 * delcap2
gen t_5_2011_cat2 = t2011 * d2006 * delcap2
gen t_4_2011_cat2 = t2011 * d2007 * delcap2
gen t_3_2011_cat2 = t2011 * d2008 * delcap2
gen t_2_2011_cat2 = t2011 * d2009 * delcap2
gen t_1_2011_cat2 = t2011 * d2010 * delcap2
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011_cat2 = t2011 * d2012 * delcap2
gen t2_2011_cat2 = t2011 * d2013 * delcap2
gen t3_2011_cat2 = t2011 * d2014 * delcap2
gen t4_2011_cat2 = t2011 * d2015 * delcap2
gen t5_2011_cat2 = t2011 * d2016 * delcap2
gen t6_2011_cat2 = t2011 * d2017 * delcap2
gen t7_2011_cat2 = t2011 * d2018 * delcap2
gen t8_2011_cat2 = t2011 * d2019 * delcap2

* Para coorte 2011 (BA, PB) - Categoria 3: high cap & close delegacia
* Pré-tratamento
gen t_11_2011_cat3 = t2011 * d2000 * delcap3
gen t_10_2011_cat3 = t2011 * d2001 * delcap3
gen t_9_2011_cat3 = t2011 * d2002 * delcap3
gen t_8_2011_cat3 = t2011 * d2003 * delcap3
gen t_7_2011_cat3 = t2011 * d2004 * delcap3
gen t_6_2011_cat3 = t2011 * d2005 * delcap3
gen t_5_2011_cat3 = t2011 * d2006 * delcap3
gen t_4_2011_cat3 = t2011 * d2007 * delcap3
gen t_3_2011_cat3 = t2011 * d2008 * delcap3
gen t_2_2011_cat3 = t2011 * d2009 * delcap3
gen t_1_2011_cat3 = t2011 * d2010 * delcap3
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011_cat3 = t2011 * d2012 * delcap3
gen t2_2011_cat3 = t2011 * d2013 * delcap3
gen t3_2011_cat3 = t2011 * d2014 * delcap3
gen t4_2011_cat3 = t2011 * d2015 * delcap3
gen t5_2011_cat3 = t2011 * d2016 * delcap3
gen t6_2011_cat3 = t2011 * d2017 * delcap3
gen t7_2011_cat3 = t2011 * d2018 * delcap3
gen t8_2011_cat3 = t2011 * d2019 * delcap3

* Para coorte 2011 (BA, PB) - Categoria 4: high cap & far delegacia
* Pré-tratamento
gen t_11_2011_cat4 = t2011 * d2000 * delcap4
gen t_10_2011_cat4 = t2011 * d2001 * delcap4
gen t_9_2011_cat4 = t2011 * d2002 * delcap4
gen t_8_2011_cat4 = t2011 * d2003 * delcap4
gen t_7_2011_cat4 = t2011 * d2004 * delcap4
gen t_6_2011_cat4 = t2011 * d2005 * delcap4
gen t_5_2011_cat4 = t2011 * d2006 * delcap4
gen t_4_2011_cat4 = t2011 * d2007 * delcap4
gen t_3_2011_cat4 = t2011 * d2008 * delcap4
gen t_2_2011_cat4 = t2011 * d2009 * delcap4
gen t_1_2011_cat4 = t2011 * d2010 * delcap4
* Omitir o ano do tratamento (2011)
* Pós-tratamento
gen t1_2011_cat4 = t2011 * d2012 * delcap4
gen t2_2011_cat4 = t2011 * d2013 * delcap4
gen t3_2011_cat4 = t2011 * d2014 * delcap4
gen t4_2011_cat4 = t2011 * d2015 * delcap4
gen t5_2011_cat4 = t2011 * d2016 * delcap4
gen t6_2011_cat4 = t2011 * d2017 * delcap4
gen t7_2011_cat4 = t2011 * d2018 * delcap4
gen t8_2011_cat4 = t2011 * d2019 * delcap4

******************************************************************************
* Criar dummies de evento para CE (2015) interagidas com as 4 categorias
******************************************************************************

* Para coorte 2015 (CE) - Categoria 1: low cap & close delegacia
* Pré-tratamento
gen t_15_2015_cat1 = t2015 * d2000 * delcap1
gen t_14_2015_cat1 = t2015 * d2001 * delcap1
gen t_13_2015_cat1 = t2015 * d2002 * delcap1
gen t_12_2015_cat1 = t2015 * d2003 * delcap1
gen t_11_2015_cat1 = t2015 * d2004 * delcap1
gen t_10_2015_cat1 = t2015 * d2005 * delcap1
gen t_9_2015_cat1 = t2015 * d2006 * delcap1
gen t_8_2015_cat1 = t2015 * d2007 * delcap1
gen t_7_2015_cat1 = t2015 * d2008 * delcap1
gen t_6_2015_cat1 = t2015 * d2009 * delcap1
gen t_5_2015_cat1 = t2015 * d2010 * delcap1
gen t_4_2015_cat1 = t2015 * d2011 * delcap1
gen t_3_2015_cat1 = t2015 * d2012 * delcap1
gen t_2_2015_cat1 = t2015 * d2013 * delcap1
gen t_1_2015_cat1 = t2015 * d2014 * delcap1
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015_cat1 = t2015 * d2016 * delcap1
gen t2_2015_cat1 = t2015 * d2017 * delcap1
gen t3_2015_cat1 = t2015 * d2018 * delcap1
gen t4_2015_cat1 = t2015 * d2019 * delcap1

* Para coorte 2015 (CE) - Categoria 2: low cap & far delegacia
* Pré-tratamento
gen t_15_2015_cat2 = t2015 * d2000 * delcap2
gen t_14_2015_cat2 = t2015 * d2001 * delcap2
gen t_13_2015_cat2 = t2015 * d2002 * delcap2
gen t_12_2015_cat2 = t2015 * d2003 * delcap2
gen t_11_2015_cat2 = t2015 * d2004 * delcap2
gen t_10_2015_cat2 = t2015 * d2005 * delcap2
gen t_9_2015_cat2 = t2015 * d2006 * delcap2
gen t_8_2015_cat2 = t2015 * d2007 * delcap2
gen t_7_2015_cat2 = t2015 * d2008 * delcap2
gen t_6_2015_cat2 = t2015 * d2009 * delcap2
gen t_5_2015_cat2 = t2015 * d2010 * delcap2
gen t_4_2015_cat2 = t2015 * d2011 * delcap2
gen t_3_2015_cat2 = t2015 * d2012 * delcap2
gen t_2_2015_cat2 = t2015 * d2013 * delcap2
gen t_1_2015_cat2 = t2015 * d2014 * delcap2
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015_cat2 = t2015 * d2016 * delcap2
gen t2_2015_cat2 = t2015 * d2017 * delcap2
gen t3_2015_cat2 = t2015 * d2018 * delcap2
gen t4_2015_cat2 = t2015 * d2019 * delcap2

* Para coorte 2015 (CE) - Categoria 3: high cap & close delegacia
* Pré-tratamento
gen t_15_2015_cat3 = t2015 * d2000 * delcap3
gen t_14_2015_cat3 = t2015 * d2001 * delcap3
gen t_13_2015_cat3 = t2015 * d2002 * delcap3
gen t_12_2015_cat3 = t2015 * d2003 * delcap3
gen t_11_2015_cat3 = t2015 * d2004 * delcap3
gen t_10_2015_cat3 = t2015 * d2005 * delcap3
gen t_9_2015_cat3 = t2015 * d2006 * delcap3
gen t_8_2015_cat3 = t2015 * d2007 * delcap3
gen t_7_2015_cat3 = t2015 * d2008 * delcap3
gen t_6_2015_cat3 = t2015 * d2009 * delcap3
gen t_5_2015_cat3 = t2015 * d2010 * delcap3
gen t_4_2015_cat3 = t2015 * d2011 * delcap3
gen t_3_2015_cat3 = t2015 * d2012 * delcap3
gen t_2_2015_cat3 = t2015 * d2013 * delcap3
gen t_1_2015_cat3 = t2015 * d2014 * delcap3
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015_cat3 = t2015 * d2016 * delcap3
gen t2_2015_cat3 = t2015 * d2017 * delcap3
gen t3_2015_cat3 = t2015 * d2018 * delcap3
gen t4_2015_cat3 = t2015 * d2019 * delcap3

* Para coorte 2015 (CE) - Categoria 4: high cap & far delegacia
* Pré-tratamento
gen t_15_2015_cat4 = t2015 * d2000 * delcap4
gen t_14_2015_cat4 = t2015 * d2001 * delcap4
gen t_13_2015_cat4 = t2015 * d2002 * delcap4
gen t_12_2015_cat4 = t2015 * d2003 * delcap4
gen t_11_2015_cat4 = t2015 * d2004 * delcap4
gen t_10_2015_cat4 = t2015 * d2005 * delcap4
gen t_9_2015_cat4 = t2015 * d2006 * delcap4
gen t_8_2015_cat4 = t2015 * d2007 * delcap4
gen t_7_2015_cat4 = t2015 * d2008 * delcap4
gen t_6_2015_cat4 = t2015 * d2009 * delcap4
gen t_5_2015_cat4 = t2015 * d2010 * delcap4
gen t_4_2015_cat4 = t2015 * d2011 * delcap4
gen t_3_2015_cat4 = t2015 * d2012 * delcap4
gen t_2_2015_cat4 = t2015 * d2013 * delcap4
gen t_1_2015_cat4 = t2015 * d2014 * delcap4
* Omitir o ano do tratamento (2015)
* Pós-tratamento
gen t1_2015_cat4 = t2015 * d2016 * delcap4
gen t2_2015_cat4 = t2015 * d2017 * delcap4
gen t3_2015_cat4 = t2015 * d2018 * delcap4
gen t4_2015_cat4 = t2015 * d2019 * delcap4

******************************************************************************
* Criar dummies de evento para MA (2016) interagidas com as 4 categorias
******************************************************************************

* Para coorte 2016 (MA) - Categoria 1: low cap & close delegacia
* Pré-tratamento
gen t_16_2016_cat1 = t2016 * d2000 * delcap1
gen t_15_2016_cat1 = t2016 * d2001 * delcap1
gen t_14_2016_cat1 = t2016 * d2002 * delcap1
gen t_13_2016_cat1 = t2016 * d2003 * delcap1
gen t_12_2016_cat1 = t2016 * d2004 * delcap1
gen t_11_2016_cat1 = t2016 * d2005 * delcap1
gen t_10_2016_cat1 = t2016 * d2006 * delcap1
gen t_9_2016_cat1 = t2016 * d2007 * delcap1
gen t_8_2016_cat1 = t2016 * d2008 * delcap1
gen t_7_2016_cat1 = t2016 * d2009 * delcap1
gen t_6_2016_cat1 = t2016 * d2010 * delcap1
gen t_5_2016_cat1 = t2016 * d2011 * delcap1
gen t_4_2016_cat1 = t2016 * d2012 * delcap1
gen t_3_2016_cat1 = t2016 * d2013 * delcap1
gen t_2_2016_cat1 = t2016 * d2014 * delcap1
gen t_1_2016_cat1 = t2016 * d2015 * delcap1
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016_cat1 = t2016 * d2017 * delcap1
gen t2_2016_cat1 = t2016 * d2018 * delcap1
gen t3_2016_cat1 = t2016 * d2019 * delcap1

* Para coorte 2016 (MA) - Categoria 2: low cap & far delegacia
* Pré-tratamento
gen t_16_2016_cat2 = t2016 * d2000 * delcap2
gen t_15_2016_cat2 = t2016 * d2001 * delcap2
gen t_14_2016_cat2 = t2016 * d2002 * delcap2
gen t_13_2016_cat2 = t2016 * d2003 * delcap2
gen t_12_2016_cat2 = t2016 * d2004 * delcap2
gen t_11_2016_cat2 = t2016 * d2005 * delcap2
gen t_10_2016_cat2 = t2016 * d2006 * delcap2
gen t_9_2016_cat2 = t2016 * d2007 * delcap2
gen t_8_2016_cat2 = t2016 * d2008 * delcap2
gen t_7_2016_cat2 = t2016 * d2009 * delcap2
gen t_6_2016_cat2 = t2016 * d2010 * delcap2
gen t_5_2016_cat2 = t2016 * d2011 * delcap2
gen t_4_2016_cat2 = t2016 * d2012 * delcap2
gen t_3_2016_cat2 = t2016 * d2013 * delcap2
gen t_2_2016_cat2 = t2016 * d2014 * delcap2
gen t_1_2016_cat2 = t2016 * d2015 * delcap2
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016_cat2 = t2016 * d2017 * delcap2
gen t2_2016_cat2 = t2016 * d2018 * delcap2
gen t3_2016_cat2 = t2016 * d2019 * delcap2

* Para coorte 2016 (MA) - Categoria 3: high cap & close delegacia
* Pré-tratamento
gen t_16_2016_cat3 = t2016 * d2000 * delcap3
gen t_15_2016_cat3 = t2016 * d2001 * delcap3
gen t_14_2016_cat3 = t2016 * d2002 * delcap3
gen t_13_2016_cat3 = t2016 * d2003 * delcap3
gen t_12_2016_cat3 = t2016 * d2004 * delcap3
gen t_11_2016_cat3 = t2016 * d2005 * delcap3
gen t_10_2016_cat3 = t2016 * d2006 * delcap3
gen t_9_2016_cat3 = t2016 * d2007 * delcap3
gen t_8_2016_cat3 = t2016 * d2008 * delcap3
gen t_7_2016_cat3 = t2016 * d2009 * delcap3
gen t_6_2016_cat3 = t2016 * d2010 * delcap3
gen t_5_2016_cat3 = t2016 * d2011 * delcap3
gen t_4_2016_cat3 = t2016 * d2012 * delcap3
gen t_3_2016_cat3 = t2016 * d2013 * delcap3
gen t_2_2016_cat3 = t2016 * d2014 * delcap3
gen t_1_2016_cat3 = t2016 * d2015 * delcap3
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016_cat3 = t2016 * d2017 * delcap3
gen t2_2016_cat3 = t2016 * d2018 * delcap3
gen t3_2016_cat3 = t2016 * d2019 * delcap3

* Para coorte 2016 (MA) - Categoria 4: high cap & far delegacia
* Pré-tratamento
gen t_16_2016_cat4 = t2016 * d2000 * delcap4
gen t_15_2016_cat4 = t2016 * d2001 * delcap4
gen t_14_2016_cat4 = t2016 * d2002 * delcap4
gen t_13_2016_cat4 = t2016 * d2003 * delcap4
gen t_12_2016_cat4 = t2016 * d2004 * delcap4
gen t_11_2016_cat4 = t2016 * d2005 * delcap4
gen t_10_2016_cat4 = t2016 * d2006 * delcap4
gen t_9_2016_cat4 = t2016 * d2007 * delcap4
gen t_8_2016_cat4 = t2016 * d2008 * delcap4
gen t_7_2016_cat4 = t2016 * d2009 * delcap4
gen t_6_2016_cat4 = t2016 * d2010 * delcap4
gen t_5_2016_cat4 = t2016 * d2011 * delcap4
gen t_4_2016_cat4 = t2016 * d2012 * delcap4
gen t_3_2016_cat4 = t2016 * d2013 * delcap4
gen t_2_2016_cat4 = t2016 * d2014 * delcap4
gen t_1_2016_cat4 = t2016 * d2015 * delcap4
* Omitir o ano do tratamento (2016)
* Pós-tratamento
gen t1_2016_cat4 = t2016 * d2017 * delcap4
gen t2_2016_cat4 = t2016 * d2018 * delcap4
gen t3_2016_cat4 = t2016 * d2019 * delcap4

********************************************************************************
* Parte 1: Event Study em uma Única Regressão com as 4 Categorias
********************************************************************************

* Modelo com todas as variáveis e interações com as 4 categorias para PE, BA/PB, CE e MA
xtreg taxa_homicidios_total_por_100m_1 ///
    t_7_2007_cat1 t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1 ///
    t1_2007_cat1 t2_2007_cat1 t3_2007_cat1 t4_2007_cat1 t5_2007_cat1 t6_2007_cat1 t7_2007_cat1 t8_2007_cat1 t9_2007_cat1 t10_2007_cat1 t11_2007_cat1 t12_2007_cat1 ///
    t_7_2007_cat2 t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2 ///
    t1_2007_cat2 t2_2007_cat2 t3_2007_cat2 t4_2007_cat2 t5_2007_cat2 t6_2007_cat2 t7_2007_cat2 t8_2007_cat2 t9_2007_cat2 t10_2007_cat2 t11_2007_cat2 t12_2007_cat2 ///
    t_7_2007_cat3 t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3 ///
    t1_2007_cat3 t2_2007_cat3 t3_2007_cat3 t4_2007_cat3 t5_2007_cat3 t6_2007_cat3 t7_2007_cat3 t8_2007_cat3 t9_2007_cat3 t10_2007_cat3 t11_2007_cat3 t12_2007_cat3 ///
    t_7_2007_cat4 t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4 ///
    t1_2007_cat4 t2_2007_cat4 t3_2007_cat4 t4_2007_cat4 t5_2007_cat4 t6_2007_cat4 t7_2007_cat4 t8_2007_cat4 t9_2007_cat4 t10_2007_cat4 t11_2007_cat4 t12_2007_cat4 ///
     t_7_2011_cat1 t_6_2011_cat1 t_5_2011_cat1 t_4_2011_cat1 t_3_2011_cat1 t_2_2011_cat1 t_1_2011_cat1 ///
    t1_2011_cat1 t2_2011_cat1 t3_2011_cat1 t4_2011_cat1 t5_2011_cat1 t6_2011_cat1 t7_2011_cat1 t8_2011_cat1 ///
     t_7_2011_cat2 t_6_2011_cat2 t_5_2011_cat2 t_4_2011_cat2 t_3_2011_cat2 t_2_2011_cat2 t_1_2011_cat2 ///
    t1_2011_cat2 t2_2011_cat2 t3_2011_cat2 t4_2011_cat2 t5_2011_cat2 t6_2011_cat2 t7_2011_cat2 t8_2011_cat2 ///
     t_7_2011_cat3 t_6_2011_cat3 t_5_2011_cat3 t_4_2011_cat3 t_3_2011_cat3 t_2_2011_cat3 t_1_2011_cat3 ///
    t1_2011_cat3 t2_2011_cat3 t3_2011_cat3 t4_2011_cat3 t5_2011_cat3 t6_2011_cat3 t7_2011_cat3 t8_2011_cat3 ///
    t_7_2011_cat4 t_6_2011_cat4 t_5_2011_cat4 t_4_2011_cat4 t_3_2011_cat4 t_2_2011_cat4 t_1_2011_cat4 ///
    t1_2011_cat4 t2_2011_cat4 t3_2011_cat4 t4_2011_cat4 t5_2011_cat4 t6_2011_cat4 t7_2011_cat4 t8_2011_cat4 ///
     t_7_2015_cat1 t_6_2015_cat1 t_5_2015_cat1 t_4_2015_cat1 t_3_2015_cat1 t_2_2015_cat1 t_1_2015_cat1 ///
    t1_2015_cat1 t2_2015_cat1 t3_2015_cat1 t4_2015_cat1 ///
     t_7_2015_cat2 t_6_2015_cat2 t_5_2015_cat2 t_4_2015_cat2 t_3_2015_cat2 t_2_2015_cat2 t_1_2015_cat2 ///
    t1_2015_cat2 t2_2015_cat2 t3_2015_cat2 t4_2015_cat2 ///
     t_7_2015_cat3 t_6_2015_cat3 t_5_2015_cat3 t_4_2015_cat3 t_3_2015_cat3 t_2_2015_cat3 t_1_2015_cat3 ///
    t1_2015_cat3 t2_2015_cat3 t3_2015_cat3 t4_2015_cat3 ///
     t_7_2015_cat4 t_6_2015_cat4 t_5_2015_cat4 t_4_2015_cat4 t_3_2015_cat4 t_2_2015_cat4 t_1_2015_cat4 ///
    t1_2015_cat4 t2_2015_cat4 t3_2015_cat4 t4_2015_cat4 ///
    t_7_2016_cat1 t_6_2016_cat1 t_5_2016_cat1 t_4_2016_cat1 t_3_2016_cat1 t_2_2016_cat1 t_1_2016_cat1 ///
    t1_2016_cat1 t2_2016_cat1 t3_2016_cat1 ///
     t_7_2016_cat2 t_6_2016_cat2 t_5_2016_cat2 t_4_2016_cat2 t_3_2016_cat2 t_2_2016_cat2 t_1_2016_cat2 ///
    t1_2016_cat2 t2_2016_cat2 t3_2016_cat2 ///
     t_7_2016_cat3 t_6_2016_cat3 t_5_2016_cat3 t_4_2016_cat3 t_3_2016_cat3 t_2_2016_cat3 t_1_2016_cat3 ///
    t1_2016_cat3 t2_2016_cat3 t3_2016_cat3 ///
     t_7_2016_cat4 t_6_2016_cat4 t_5_2016_cat4 t_4_2016_cat4 t_3_2016_cat4 t_2_2016_cat4 t_1_2016_cat4 ///
    t1_2016_cat4 t2_2016_cat4 t3_2016_cat4 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)
	
* Salvar o número de observações
sca nobs = e(N)

* Salvar os coeficientes completos
matrix betas = e(b)

* Extrair coeficientes para cada categoria
* Para PE (2007) Categoria 1: low cap & close delegacia
matrix betas2007_cat1 = betas[1, 1..19]
* Para PE (2007) Categoria 2: low cap & far delegacia
matrix betas2007_cat2 = betas[1, 20..38]
* Para PE (2007) Categoria 3: high cap & close delegacia
matrix betas2007_cat3 = betas[1, 39..57]
* Para PE (2007) Categoria 4: high cap & far delegacia
matrix betas2007_cat4 = betas[1, 58..76]
* Para BA/PB (2011) Categoria 1: low cap & close delegacia
matrix betas2011_cat1 = betas[1, 77..91]
* Para BA/PB (2011) Categoria 2: low cap & far delegacia
matrix betas2011_cat2 = betas[1, 92..106]
* Para BA/PB (2011) Categoria 3: high cap & close delegacia
matrix betas2011_cat3 = betas[1, 107..121]
* Para BA/PB (2011) Categoria 4: high cap & far delegacia
matrix betas2011_cat4 = betas[1, 122..136]
* Para CE (2015) Categoria 1: low cap & close delegacia
matrix betas2015_cat1 = betas[1, 137..147]
* Para CE (2015) Categoria 2: low cap & far delegacia
matrix betas2015_cat2 = betas[1, 148..158]
* Para CE (2015) Categoria 3: high cap & close delegacia
matrix betas2015_cat3 = betas[1, 159..169]
* Para CE (2015) Categoria 4: high cap & far delegacia
matrix betas2015_cat4 = betas[1, 170..180]
* Para MA (2016) Categoria 1: low cap & close delegacia
matrix betas2016_cat1 = betas[1, 181..190]
* Para MA (2016) Categoria 2: low cap & far delegacia
matrix betas2016_cat2 = betas[1, 191..200]
* Para MA (2016) Categoria 3: high cap & close delegacia
matrix betas2016_cat3 = betas[1, 201..210]
* Para MA (2016) Categoria 4: high cap & far delegacia
matrix betas2016_cat4 = betas[1, 211..220]

* Extrair erros padrão
mata st_matrix("A", sqrt(diagonal(st_matrix("e(V)"))))
matrix A = A'

* Para PE (2007) Categoria 1
matrix vars2007_cat1 = A[1, 1..19]
* Para PE (2007) Categoria 2
matrix vars2007_cat2 = A[1, 20..38]
* Para PE (2007) Categoria 3
matrix vars2007_cat3 = A[1, 39..57]
* Para PE (2007) Categoria 4
matrix vars2007_cat4 = A[1, 58..76]
* Para BA/PB (2011) Categoria 1
matrix vars2011_cat1 = A[1, 77..91]
* Para BA/PB (2011) Categoria 2
matrix vars2011_cat2 = A[1, 92..106]
* Para BA/PB (2011) Categoria 3
matrix vars2011_cat3 = A[1, 107..121]
* Para BA/PB (2011) Categoria 4
matrix vars2011_cat4 = A[1, 122..136]
* Para CE (2015) Categoria 1
matrix vars2015_cat1 = A[1, 137..147]
* Para CE (2015) Categoria 2
matrix vars2015_cat2 = A[1, 148..158]
* Para CE (2015) Categoria 3
matrix vars2015_cat3 = A[1, 159..169]
* Para CE (2015) Categoria 4
matrix vars2015_cat4 = A[1, 170..180]
* Para MA (2016) Categoria 1
matrix vars2016_cat1 = A[1, 181..190]
* Para MA (2016) Categoria 2
matrix vars2016_cat2 = A[1, 191..200]
* Para MA (2016) Categoria 3
matrix vars2016_cat3 = A[1, 201..210]
* Para MA (2016) Categoria 4
matrix vars2016_cat4 = A[1, 211..220]

* Calcular p-values usando boottest com Webb weights incluindo todos os coeficientes de todas as coortes
boottest {t_7_2007_cat1} {t_6_2007_cat1} {t_5_2007_cat1} {t_4_2007_cat1} {t_3_2007_cat1} {t_2_2007_cat1} {t_1_2007_cat1} ///
        {t1_2007_cat1} {t2_2007_cat1} {t3_2007_cat1} {t4_2007_cat1} {t5_2007_cat1} {t6_2007_cat1} {t7_2007_cat1} {t8_2007_cat1} {t9_2007_cat1} {t10_2007_cat1} {t11_2007_cat1} {t12_2007_cat1} ///
        {t_7_2007_cat2} {t_6_2007_cat2} {t_5_2007_cat2} {t_4_2007_cat2} {t_3_2007_cat2} {t_2_2007_cat2} {t_1_2007_cat2} ///
        {t1_2007_cat2} {t2_2007_cat2} {t3_2007_cat2} {t4_2007_cat2} {t5_2007_cat2} {t6_2007_cat2} {t7_2007_cat2} {t8_2007_cat2} {t9_2007_cat2} {t10_2007_cat2} {t11_2007_cat2} {t12_2007_cat2} ///
        {t_7_2007_cat3} {t_6_2007_cat3} {t_5_2007_cat3} {t_4_2007_cat3} {t_3_2007_cat3} {t_2_2007_cat3} {t_1_2007_cat3} ///
        {t1_2007_cat3} {t2_2007_cat3} {t3_2007_cat3} {t4_2007_cat3} {t5_2007_cat3} {t6_2007_cat3} {t7_2007_cat3} {t8_2007_cat3} {t9_2007_cat3} {t10_2007_cat3} {t11_2007_cat3} {t12_2007_cat3} ///
        {t_7_2007_cat4} {t_6_2007_cat4} {t_5_2007_cat4} {t_4_2007_cat4} {t_3_2007_cat4} {t_2_2007_cat4} {t_1_2007_cat4} ///
        {t1_2007_cat4} {t2_2007_cat4} {t3_2007_cat4} {t4_2007_cat4} {t5_2007_cat4} {t6_2007_cat4} {t7_2007_cat4} {t8_2007_cat4} {t9_2007_cat4} {t10_2007_cat4} {t11_2007_cat4} {t12_2007_cat4} ///
        {t_7_2011_cat1} {t_6_2011_cat1} {t_5_2011_cat1} {t_4_2011_cat1} {t_3_2011_cat1} {t_2_2011_cat1} {t_1_2011_cat1} ///
        {t1_2011_cat1} {t2_2011_cat1} {t3_2011_cat1} {t4_2011_cat1} {t5_2011_cat1} {t6_2011_cat1} {t7_2011_cat1} {t8_2011_cat1} ///
        {t_7_2011_cat2} {t_6_2011_cat2} {t_5_2011_cat2} {t_4_2011_cat2} {t_3_2011_cat2} {t_2_2011_cat2} {t_1_2011_cat2} ///
        {t1_2011_cat2} {t2_2011_cat2} {t3_2011_cat2} {t4_2011_cat2} {t5_2011_cat2} {t6_2011_cat2} {t7_2011_cat2} {t8_2011_cat2} ///
        {t_7_2011_cat3} {t_6_2011_cat3} {t_5_2011_cat3} {t_4_2011_cat3} {t_3_2011_cat3} {t_2_2011_cat3} {t_1_2011_cat3} ///
        {t1_2011_cat3} {t2_2011_cat3} {t3_2011_cat3} {t4_2011_cat3} {t5_2011_cat3} {t6_2011_cat3} {t7_2011_cat3} {t8_2011_cat3} ///
        {t_7_2011_cat4} {t_6_2011_cat4} {t_5_2011_cat4} {t_4_2011_cat4} {t_3_2011_cat4} {t_2_2011_cat4} {t_1_2011_cat4} ///
        {t1_2011_cat4} {t2_2011_cat4} {t3_2011_cat4} {t4_2011_cat4} {t5_2011_cat4} {t6_2011_cat4} {t7_2011_cat4} {t8_2011_cat4} ///
        {t_7_2015_cat1} {t_6_2015_cat1} {t_5_2015_cat1} {t_4_2015_cat1} {t_3_2015_cat1} {t_2_2015_cat1} {t_1_2015_cat1} ///
        {t1_2015_cat1} {t2_2015_cat1} {t3_2015_cat1} {t4_2015_cat1} ///
        {t_7_2015_cat2} {t_6_2015_cat2} {t_5_2015_cat2} {t_4_2015_cat2} {t_3_2015_cat2} {t_2_2015_cat2} {t_1_2015_cat2} ///
        {t1_2015_cat2} {t2_2015_cat2} {t3_2015_cat2} {t4_2015_cat2} ///
        {t_7_2015_cat3} {t_6_2015_cat3} {t_5_2015_cat3} {t_4_2015_cat3} {t_3_2015_cat3} {t_2_2015_cat3} {t_1_2015_cat3} ///
        {t1_2015_cat3} {t2_2015_cat3} {t3_2015_cat3} {t4_2015_cat3} ///
        {t_7_2015_cat4} {t_6_2015_cat4} {t_5_2015_cat4} {t_4_2015_cat4} {t_3_2015_cat4} {t_2_2015_cat4} {t_1_2015_cat4} ///
        {t1_2015_cat4} {t2_2015_cat4} {t3_2015_cat4} {t4_2015_cat4} ///
        {t_7_2016_cat1} {t_6_2016_cat1} {t_5_2016_cat1} {t_4_2016_cat1} {t_3_2016_cat1} {t_2_2016_cat1} {t_1_2016_cat1} ///
        {t1_2016_cat1} {t2_2016_cat1} {t3_2016_cat1} ///
        {t_7_2016_cat2} {t_6_2016_cat2} {t_5_2016_cat2} {t_4_2016_cat2} {t_3_2016_cat2} {t_2_2016_cat2} {t_1_2016_cat2} ///
        {t1_2016_cat2} {t2_2016_cat2} {t3_2016_cat2} ///
        {t_7_2016_cat3} {t_6_2016_cat3} {t_5_2016_cat3} {t_4_2016_cat3} {t_3_2016_cat3} {t_2_2016_cat3} {t_1_2016_cat3} ///
        {t1_2016_cat3} {t2_2016_cat3} {t3_2016_cat3} ///
        {t_7_2016_cat4} {t_6_2016_cat4} {t_5_2016_cat4} {t_4_2016_cat4} {t_3_2016_cat4} {t_2_2016_cat4} {t_1_2016_cat4} ///
        {t1_2016_cat4} {t2_2016_cat4} {t3_2016_cat4}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)
		
* Guardar p-values para cada categoria
* Para PE (2007) Categoria 1 - posições 1-19
matrix pvalue2007_cat1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19)

* Para PE (2007) Categoria 2 - posições 20-38
matrix pvalue2007_cat2 = r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), r(p_26), ///
                  r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), r(p_38)

* Para PE (2007) Categoria 3 - posições 39-57
matrix pvalue2007_cat3 = r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), r(p_45), ///
                   r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), r(p_54), r(p_55), r(p_56), r(p_57)

* Para PE (2007) Categoria 4 - posições 58-76
matrix pvalue2007_cat4 = r(p_58), r(p_59), r(p_60), r(p_61), r(p_62), r(p_63), r(p_64), ///
                  r(p_65), r(p_66), r(p_67), r(p_68), r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75), r(p_76)

* Para BA/PB (2011) Categoria 1 - posições 77-91
matrix pvalue2011_cat1 = r(p_77), r(p_78), r(p_79), r(p_80), r(p_81), r(p_82), r(p_83), ///
                   r(p_84), r(p_85), r(p_86), r(p_87), r(p_88), r(p_89), r(p_90), r(p_91)

* Para BA/PB (2011) Categoria 2 - posições 92-106
matrix pvalue2011_cat2 = r(p_92), r(p_93), r(p_94), r(p_95), r(p_96), r(p_97), r(p_98), r(p_99), ///
                  r(p_100), r(p_101), r(p_102), r(p_103), r(p_104), r(p_105), r(p_106)

* Para BA/PB (2011) Categoria 3 - posições 107-121
matrix pvalue2011_cat3 = r(p_107), r(p_108), r(p_109), r(p_110), r(p_111), r(p_112), r(p_113), r(p_114), r(p_115), ///
                   r(p_116), r(p_117), r(p_118), r(p_119), r(p_120), r(p_121)

* Para BA/PB (2011) Categoria 4 - posições 122-136
matrix pvalue2011_cat4 = r(p_122), r(p_123), r(p_124), r(p_125), r(p_126), r(p_127), r(p_128), r(p_129), r(p_130), r(p_131), ///
                  r(p_132), r(p_133), r(p_134), r(p_135), r(p_136)

* Para CE (2015) Categoria 1 - posições 137-147
matrix pvalue2015_cat1 = r(p_137), r(p_138), r(p_139), r(p_140), r(p_141), r(p_142), r(p_143), r(p_144), r(p_145), r(p_146), r(p_147)

* Para CE (2015) Categoria 2 - posições 148-158
matrix pvalue2015_cat2 = r(p_148), r(p_149), r(p_150), r(p_151), r(p_152), r(p_153), r(p_154), r(p_155), r(p_156), r(p_157), r(p_158)

* Para CE (2015) Categoria 3 - posições 159-169
matrix pvalue2015_cat3 = r(p_159), r(p_160), r(p_161), r(p_162), r(p_163), r(p_164), r(p_165), r(p_166), r(p_167), r(p_168), r(p_169)

* Para CE (2015) Categoria 4 - posições 170-180
matrix pvalue2015_cat4 = r(p_170), r(p_171), r(p_172), r(p_173), r(p_174), r(p_175), r(p_176), r(p_177), r(p_178), r(p_179), r(p_180)

* Para MA (2016) Categoria 1 - posições 181-190
matrix pvalue2016_cat1 =  r(p_181), r(p_182), r(p_183), r(p_184), r(p_185), r(p_186), r(p_187), r(p_188), r(p_189), r(p_190)

* Para MA (2016) Categoria 2 - posições 191-200
matrix pvalue2016_cat2 =   r(p_191), r(p_192), r(p_193), r(p_194), r(p_195), r(p_196), r(p_197), r(p_198), r(p_199), r(p_200)

* Para MA (2016) Categoria 3 - posições 201-210
matrix pvalue2016_cat3 =  r(p_201), r(p_202), r(p_203), r(p_204), r(p_205), r(p_206), r(p_207), r(p_208), r(p_209), r(p_210)

* Para MA (2016) Categoria 4 - posições 211-220
matrix pvalue2016_cat4 =  r(p_211), r(p_212), r(p_213), r(p_214), r(p_215), r(p_216), r(p_217), r(p_218), r(p_219), r(p_220)

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
* Criar tendência específica por categoria para todos os estados tratados
********************************************************************************
gen trend = year - 2000 // Tendência linear começando em 2000

* Criar tendências específicas para cada categoria de PE (2007)
gen partrend2007_cat1 = trend * t2007 * delcap1
gen partrend2007_cat2 = trend * t2007 * delcap2
gen partrend2007_cat3 = trend * t2007 * delcap3
gen partrend2007_cat4 = trend * t2007 * delcap4

* Criar tendências específicas para cada categoria de BA/PB (2011)
gen partrend2011_cat1 = trend * t2011 * delcap1
gen partrend2011_cat2 = trend * t2011 * delcap2
gen partrend2011_cat3 = trend * t2011 * delcap3
gen partrend2011_cat4 = trend * t2011 * delcap4

* Criar tendências específicas para cada categoria de CE (2015)
gen partrend2015_cat1 = trend * t2015 * delcap1
gen partrend2015_cat2 = trend * t2015 * delcap2
gen partrend2015_cat3 = trend * t2015 * delcap3
gen partrend2015_cat4 = trend * t2015 * delcap4

* Criar tendências específicas para cada categoria de MA (2016)
gen partrend2016_cat1 = trend * t2016 * delcap1
gen partrend2016_cat2 = trend * t2016 * delcap2
gen partrend2016_cat3 = trend * t2016 * delcap3
gen partrend2016_cat4 = trend * t2016 * delcap4


********************************************************************************
* Parte 2: Event Study com Tendências Lineares Específicas por Categoria para Todos os Estados
********************************************************************************

* IMPORTANTE: Omitindo t_7_2007, t_11_2011, t_15_2015, t_16_2016 para cada categoria
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
    t_6_2011_cat1 t_5_2011_cat1 t_4_2011_cat1 t_3_2011_cat1 t_2_2011_cat1 t_1_2011_cat1 ///
    t1_2011_cat1 t2_2011_cat1 t3_2011_cat1 t4_2011_cat1 t5_2011_cat1 t6_2011_cat1 t7_2011_cat1 t8_2011_cat1 ///
    partrend2011_cat1 ///
    t_6_2011_cat2 t_5_2011_cat2 t_4_2011_cat2 t_3_2011_cat2 t_2_2011_cat2 t_1_2011_cat2 ///
    t1_2011_cat2 t2_2011_cat2 t3_2011_cat2 t4_2011_cat2 t5_2011_cat2 t6_2011_cat2 t7_2011_cat2 t8_2011_cat2 ///
    partrend2011_cat2 ///
    t_6_2011_cat3 t_5_2011_cat3 t_4_2011_cat3 t_3_2011_cat3 t_2_2011_cat3 t_1_2011_cat3 ///
    t1_2011_cat3 t2_2011_cat3 t3_2011_cat3 t4_2011_cat3 t5_2011_cat3 t6_2011_cat3 t7_2011_cat3 t8_2011_cat3 ///
    partrend2011_cat3 ///
    t_6_2011_cat4 t_5_2011_cat4 t_4_2011_cat4 t_3_2011_cat4 t_2_2011_cat4 t_1_2011_cat4 ///
    t1_2011_cat4 t2_2011_cat4 t3_2011_cat4 t4_2011_cat4 t5_2011_cat4 t6_2011_cat4 t7_2011_cat4 t8_2011_cat4 ///
    partrend2011_cat4 ///
    t_6_2015_cat1 t_5_2015_cat1 t_4_2015_cat1 t_3_2015_cat1 t_2_2015_cat1 t_1_2015_cat1 ///
    t1_2015_cat1 t2_2015_cat1 t3_2015_cat1 t4_2015_cat1 ///
    partrend2015_cat1 ///
    t_6_2015_cat2 t_5_2015_cat2 t_4_2015_cat2 t_3_2015_cat2 t_2_2015_cat2 t_1_2015_cat2 ///
    t1_2015_cat2 t2_2015_cat2 t3_2015_cat2 t4_2015_cat2 ///
    partrend2015_cat2 ///
    t_6_2015_cat3 t_5_2015_cat3 t_4_2015_cat3 t_3_2015_cat3 t_2_2015_cat3 t_1_2015_cat3 ///
    t1_2015_cat3 t2_2015_cat3 t3_2015_cat3 t4_2015_cat3 ///
    partrend2015_cat3 ///
    t_6_2015_cat4 t_5_2015_cat4 t_4_2015_cat4 t_3_2015_cat4 t_2_2015_cat4 t_1_2015_cat4 ///
    t1_2015_cat4 t2_2015_cat4 t3_2015_cat4 t4_2015_cat4 ///
    partrend2015_cat4 ///
    t_6_2016_cat1 t_5_2016_cat1 t_4_2016_cat1 t_3_2016_cat1 t_2_2016_cat1 t_1_2016_cat1 ///
    t1_2016_cat1 t2_2016_cat1 t3_2016_cat1 ///
    partrend2016_cat1 ///
    t_6_2016_cat2 t_5_2016_cat2 t_4_2016_cat2 t_3_2016_cat2 t_2_2016_cat2 t_1_2016_cat2 ///
    t1_2016_cat2 t2_2016_cat2 t3_2016_cat2 ///
    partrend2016_cat2 ///
    t_6_2016_cat3 t_5_2016_cat3 t_4_2016_cat3 t_3_2016_cat3 t_2_2016_cat3 t_1_2016_cat3 ///
    t1_2016_cat3 t2_2016_cat3 t3_2016_cat3 ///
    partrend2016_cat3 ///
    t_6_2016_cat4 t_5_2016_cat4 t_4_2016_cat4 t_3_2016_cat4 t_2_2016_cat4 t_1_2016_cat4 ///
    t1_2016_cat4 t2_2016_cat4 t3_2016_cat4 ///
    partrend2016_cat4 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)
* Salvar o número de observações
sca nobs_trend = e(N)

* Salvar os coeficientes completos
matrix betas_trend = e(b)

* Extrair coeficientes para cada categoria e tendência
* Para PE (2007) Categoria 1 - notamos que não temos mais t_7, então começamos em t_6
matrix betas2007_cat1_trend = betas_trend[1, 1..18]
* Para PE (2007) Categoria 2
matrix betas2007_cat2_trend = betas_trend[1, 20..37]
* Para PE (2007) Categoria 3
matrix betas2007_cat3_trend = betas_trend[1, 39..56]
* Para PE (2007) Categoria 4
matrix betas2007_cat4_trend = betas_trend[1, 58..75]

* Para BA/PB (2011) Categoria 1
matrix betas2011_cat1_trend = betas_trend[1, 77..90]
* Para BA/PB (2011) Categoria 2
matrix betas2011_cat2_trend = betas_trend[1, 92..105]
* Para BA/PB (2011) Categoria 3
matrix betas2011_cat3_trend = betas_trend[1, 107..120]
* Para BA/PB (2011) Categoria 4
matrix betas2011_cat4_trend = betas_trend[1, 122..135]

* Para CE (2015) Categoria 1
matrix betas2015_cat1_trend = betas_trend[1, 137..146]
* Para CE (2015) Categoria 2
matrix betas2015_cat2_trend = betas_trend[1, 148..157]
* Para CE (2015) Categoria 3
matrix betas2015_cat3_trend = betas_trend[1, 159..168]
* Para CE (2015) Categoria 4
matrix betas2015_cat4_trend = betas_trend[1, 170..179]

* Para MA (2016) Categoria 1
matrix betas2016_cat1_trend = betas_trend[1, 181..189]
* Para MA (2016) Categoria 2
matrix betas2016_cat2_trend = betas_trend[1, 191..199]
* Para MA (2016) Categoria 3
matrix betas2016_cat3_trend = betas_trend[1, 201..209]
* Para MA (2016) Categoria 4
matrix betas2016_cat4_trend = betas_trend[1, 211..219]

* Extrair erros padrão
mata st_matrix("A", sqrt(diagonal(st_matrix("e(V)"))))
matrix A = A'

* Para PE (2007) Categoria 1
matrix vars2007_cat1_trend = A[1, 1..18]
* Para PE (2007) Categoria 2
matrix vars2007_cat2_trend = A[1, 20..37]
* Para PE (2007) Categoria 3
matrix vars2007_cat3_trend = A[1, 39..56]
* Para PE (2007) Categoria 4
matrix vars2007_cat4_trend = A[1, 58..75]

* Para BA/PB (2011) Categoria 1
matrix vars2011_cat1_trend = A[1, 77..90]
* Para BA/PB (2011) Categoria 2
matrix vars2011_cat2_trend = A[1, 92..105]
* Para BA/PB (2011) Categoria 3
matrix vars2011_cat3_trend = A[1, 107..120]
* Para BA/PB (2011) Categoria 4
matrix vars2011_cat4_trend = A[1, 122..135]

* Para CE (2015) Categoria 1
matrix vars2015_cat1_trend = A[1, 137..146]
* Para CE (2015) Categoria 2
matrix vars2015_cat2_trend = A[1, 148..157]
* Para CE (2015) Categoria 3
matrix vars2015_cat3_trend = A[1, 159..168]
* Para CE (2015) Categoria 4
matrix vars2015_cat4_trend = A[1, 170..179]

* Para MA (2016) Categoria 1
matrix vars2016_cat1_trend = A[1, 181..189]
* Para MA (2016) Categoria 2
matrix vars2016_cat2_trend = A[1, 191..199]
* Para MA (2016) Categoria 3
matrix vars2016_cat3_trend = A[1, 201..209]
* Para MA (2016) Categoria 4
matrix vars2016_cat4_trend = A[1, 211..219]

* Calcular p-values usando boottest para todos os coeficientes em um único teste
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
        {partrend2007_cat4} ///
        {t_6_2011_cat1} {t_5_2011_cat1} {t_4_2011_cat1} {t_3_2011_cat1} {t_2_2011_cat1} {t_1_2011_cat1} ///
        {t1_2011_cat1} {t2_2011_cat1} {t3_2011_cat1} {t4_2011_cat1} {t5_2011_cat1} {t6_2011_cat1} {t7_2011_cat1} {t8_2011_cat1} ///
        {partrend2011_cat1} ///
        {t_6_2011_cat2} {t_5_2011_cat2} {t_4_2011_cat2} {t_3_2011_cat2} {t_2_2011_cat2} {t_1_2011_cat2} ///
        {t1_2011_cat2} {t2_2011_cat2} {t3_2011_cat2} {t4_2011_cat2} {t5_2011_cat2} {t6_2011_cat2} {t7_2011_cat2} {t8_2011_cat2} ///
        {partrend2011_cat2} ///
        {t_6_2011_cat3} {t_5_2011_cat3} {t_4_2011_cat3} {t_3_2011_cat3} {t_2_2011_cat3} {t_1_2011_cat3} ///
        {t1_2011_cat3} {t2_2011_cat3} {t3_2011_cat3} {t4_2011_cat3} {t5_2011_cat3} {t6_2011_cat3} {t7_2011_cat3} {t8_2011_cat3} ///
        {partrend2011_cat3} ///
        {t_6_2011_cat4} {t_5_2011_cat4} {t_4_2011_cat4} {t_3_2011_cat4} {t_2_2011_cat4} {t_1_2011_cat4} ///
        {t1_2011_cat4} {t2_2011_cat4} {t3_2011_cat4} {t4_2011_cat4} {t5_2011_cat4} {t6_2011_cat4} {t7_2011_cat4} {t8_2011_cat4} ///
        {partrend2011_cat4} ///
        {t_6_2015_cat1} {t_5_2015_cat1} {t_4_2015_cat1} {t_3_2015_cat1} {t_2_2015_cat1} {t_1_2015_cat1} ///
        {t1_2015_cat1} {t2_2015_cat1} {t3_2015_cat1} {t4_2015_cat1} ///
        {partrend2015_cat1} ///
        {t_6_2015_cat2} {t_5_2015_cat2} {t_4_2015_cat2} {t_3_2015_cat2} {t_2_2015_cat2} {t_1_2015_cat2} ///
        {t1_2015_cat2} {t2_2015_cat2} {t3_2015_cat2} {t4_2015_cat2} ///
        {partrend2015_cat2} ///
        {t_6_2015_cat3} {t_5_2015_cat3} {t_4_2015_cat3} {t_3_2015_cat3} {t_2_2015_cat3} {t_1_2015_cat3} ///
        {t1_2015_cat3} {t2_2015_cat3} {t3_2015_cat3} {t4_2015_cat3} ///
        {partrend2015_cat3} ///
        {t_6_2015_cat4} {t_5_2015_cat4} {t_4_2015_cat4} {t_3_2015_cat4} {t_2_2015_cat4} {t_1_2015_cat4} ///
        {t1_2015_cat4} {t2_2015_cat4} {t3_2015_cat4} {t4_2015_cat4} ///
        {partrend2015_cat4} ///
        {t_6_2016_cat1} {t_5_2016_cat1} {t_4_2016_cat1} {t_3_2016_cat1} {t_2_2016_cat1} {t_1_2016_cat1} ///
        {t1_2016_cat1} {t2_2016_cat1} {t3_2016_cat1} ///
        {partrend2016_cat1} ///
        {t_6_2016_cat2} {t_5_2016_cat2} {t_4_2016_cat2} {t_3_2016_cat2} {t_2_2016_cat2} {t_1_2016_cat2} ///
        {t1_2016_cat2} {t2_2016_cat2} {t3_2016_cat2} ///
        {partrend2016_cat2} ///
        {t_6_2016_cat3} {t_5_2016_cat3} {t_4_2016_cat3} {t_3_2016_cat3} {t_2_2016_cat3} {t_1_2016_cat3} ///
        {t1_2016_cat3} {t2_2016_cat3} {t3_2016_cat3} ///
        {partrend2016_cat3} ///
        {t_6_2016_cat4} {t_5_2016_cat4} {t_4_2016_cat4} {t_3_2016_cat4} {t_2_2016_cat4} {t_1_2016_cat4} ///
        {t1_2016_cat4} {t2_2016_cat4} {t3_2016_cat4} ///
        {partrend2016_cat4}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)
		
	* Guardar p-values para cada categoria e tendência
* Para PE (2007) Categoria 1
matrix pvalue2007_cat1_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18)
* Para PE (2007) Categoria 2
matrix pvalue2007_cat2_trend = ., r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), ///
                  r(p_26), r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37)
* Para PE (2007) Categoria 3
matrix pvalue2007_cat3_trend = ., r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), ///
                  r(p_45), r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), r(p_54), r(p_55), r(p_56)
* Para PE (2007) Categoria 4
matrix pvalue2007_cat4_trend = ., r(p_58), r(p_59), r(p_60), r(p_61), r(p_62), r(p_63), ///
                  r(p_64), r(p_65), r(p_66), r(p_67), r(p_68), r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75)

* Para BA/PB (2011) Categoria 1
matrix pvalue2011_cat1_trend = ., r(p_77), r(p_78), r(p_79), r(p_80), r(p_81), r(p_82), ///
                  r(p_83), r(p_84), r(p_85), r(p_86), r(p_87), r(p_88), r(p_89), r(p_90)
				  
* Para BA/PB (2011) Categoria 2
matrix pvalue2011_cat2_trend = ., r(p_92), r(p_93), r(p_94), r(p_95), r(p_96), r(p_97), ///
                  r(p_98), r(p_99), r(p_100), r(p_101), r(p_102), r(p_103), r(p_104), r(p_105)
				
* Para BA/PB (2011) Categoria 3
matrix pvalue2011_cat3_trend = ., r(p_107), r(p_108), r(p_109), r(p_110), r(p_111), r(p_112), ///
                  r(p_113), r(p_114), r(p_115), r(p_116), r(p_117), r(p_118), r(p_119), r(p_120)
                  
* Para BA/PB (2011) Categoria 4
matrix pvalue2011_cat4_trend = ., r(p_122), r(p_123), r(p_124), r(p_125), r(p_126), r(p_127), ///
                  r(p_128), r(p_129), r(p_130), r(p_131), r(p_132), r(p_133), r(p_134), r(p_135)

* Para CE (2015) Categoria 1
matrix pvalue2015_cat1_trend = ., r(p_137), r(p_138), r(p_139), r(p_140), r(p_141), r(p_142), ///
                  r(p_143), r(p_144), r(p_145), r(p_146)

* Para CE (2015) Categoria 2
matrix pvalue2015_cat2_trend = ., r(p_148), r(p_149), r(p_150), r(p_151), r(p_152), r(p_153), ///
                  r(p_154), r(p_155), r(p_156), r(p_157)

* Para CE (2015) Categoria 3
matrix pvalue2015_cat3_trend = ., r(p_159), r(p_160), r(p_161), r(p_162), r(p_163), r(p_164), ///
                  r(p_165), r(p_166), r(p_167), r(p_168)

* Para CE (2015) Categoria 4
matrix pvalue2015_cat4_trend = ., r(p_170), r(p_171), r(p_172), r(p_173), r(p_174), r(p_175), ///
                  r(p_176), r(p_177), r(p_178), r(p_179)

* Para MA (2016) Categoria 1
matrix pvalue2016_cat1_trend = ., r(p_181), r(p_182), r(p_183), r(p_184), r(p_185), r(p_186), ///
                  r(p_187), r(p_188), r(p_189)

* Para MA (2016) Categoria 2
matrix pvalue2016_cat2_trend = ., r(p_191), r(p_192), r(p_193), r(p_194), r(p_195), r(p_196), ///
                  r(p_197), r(p_198), r(p_199)
                  
* Para MA (2016) Categoria 3
matrix pvalue2016_cat3_trend = ., r(p_201), r(p_202), r(p_203), r(p_204), r(p_205), r(p_206), ///
                  r(p_207), r(p_208), r(p_209)
                  
* Para MA (2016) Categoria 4
matrix pvalue2016_cat4_trend = ., r(p_211), r(p_212), r(p_213), r(p_214), r(p_215), r(p_216), ///
                  r(p_217), r(p_218), r(p_219)
				  

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

* PARTE 2: GRÁFICO COM TENDÊNCIAS LINEARES PARA PE
* Repetir o mesmo processo para os modelos com tendências lineares
clear
set obs 20
gen rel_year = _n - 8   // Cria valores de -7 a 12 para centralizar em 0 (ano de tratamento)

* PE (2007) - Categoria 1 com tendência
gen coef_2007_cat1_trend = .
gen se_2007_cat1_trend = .

drop if rel_year == -7

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -7 + `i'
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
    local pos = 6 + `i'
    replace coef_2007_cat1_trend = betas2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1_trend = vars2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 2 com tendência
gen coef_2007_cat2_trend = .
gen se_2007_cat2_trend = .

drop if rel_year == -7

forvalues i=1/7 {
    local rel_year = -7 + `i'
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
    local pos = 6 + `i'
    replace coef_2007_cat2_trend = betas2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2_trend = vars2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
}


* PE (2007) - Categoria 3 com tendência
gen coef_2007_cat3_trend = .
gen se_2007_cat3_trend = .

drop if rel_year == -7

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -7 + `i'
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
    local pos = 6 + `i'
    replace coef_2007_cat3_trend = betas2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3_trend = vars2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Categoria 4 com tendência
gen coef_2007_cat4_trend = .
gen se_2007_cat4_trend = .

drop if rel_year == -7

forvalues i=1/7 {
    local rel_year = -7 + `i'
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
    local pos = 6 + `i'
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

*** Continuando gráficos sem tendências para outras coortes

* 2. BA/PB (2011)
clear
set obs 20
gen rel_year = _n - 12  
drop if rel_year == -11 | rel_year == -10 | rel_year == -9 | rel_year == -8

* BA/PB (2011) - Categoria 1: low cap & close delegacia
gen coef_2011_cat1 = .
gen se_2011_cat1 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_cat1 = betas2011_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat1 = vars2011_cat1[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat1 = 0 if rel_year == 0
replace se_2011_cat1 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_cat1 = betas2011_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat1 = vars2011_cat1[1,`pos'] if rel_year == `rel_year'
}

* BA/PB (2011) - Categoria 2: low cap & far delegacia
gen coef_2011_cat2 = .
gen se_2011_cat2 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_cat2 = betas2011_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat2 = vars2011_cat2[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat2 = 0 if rel_year == 0
replace se_2011_cat2 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_cat2 = betas2011_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat2 = vars2011_cat2[1,`pos'] if rel_year == `rel_year'
}

* BA/PB (2011) - Categoria 3: high cap & close delegacia
gen coef_2011_cat3 = .
gen se_2011_cat3 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_cat3 = betas2011_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat3 = vars2011_cat3[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat3 = 0 if rel_year == 0
replace se_2011_cat3 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_cat3 = betas2011_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat3 = vars2011_cat3[1,`pos'] if rel_year == `rel_year'
}

* BA/PB (2011) - Categoria 4: high cap & far delegacia
gen coef_2011_cat4 = .
gen se_2011_cat4 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2011_cat4 = betas2011_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat4 = vars2011_cat4[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat4 = 0 if rel_year == 0
replace se_2011_cat4 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2011_cat4 = betas2011_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat4 = vars2011_cat4[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2011_cat1 = coef_2011_cat1 + 1.96 * se_2011_cat1
gen ci_lower_2011_cat1 = coef_2011_cat1 - 1.96 * se_2011_cat1
gen ci_upper_2011_cat2 = coef_2011_cat2 + 1.96 * se_2011_cat2
gen ci_lower_2011_cat2 = coef_2011_cat2 - 1.96 * se_2011_cat2
gen ci_upper_2011_cat3 = coef_2011_cat3 + 1.96 * se_2011_cat3
gen ci_lower_2011_cat3 = coef_2011_cat3 - 1.96 * se_2011_cat3
gen ci_upper_2011_cat4 = coef_2011_cat4 + 1.96 * se_2011_cat4
gen ci_lower_2011_cat4 = coef_2011_cat4 - 1.96 * se_2011_cat4

* Gráfico para BA/PB (2011) - 4 categorias (Sem Tendências)
twoway (rcap ci_upper_2011_cat1 ci_lower_2011_cat1 rel_year if rel_year >= -7 & rel_year <= 8, lcolor(midblue)) ///
       (scatter coef_2011_cat1 rel_year if rel_year >= -7 & rel_year <= 8, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2011_cat2 ci_lower_2011_cat2 rel_year if rel_year >= -7 & rel_year <= 8, lcolor(cranberry)) ///
       (scatter coef_2011_cat2 rel_year if rel_year >= -7 & rel_year <= 8, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2011_cat3 ci_lower_2011_cat3 rel_year if rel_year >= -7 & rel_year <= 8, lcolor(forest_green)) ///
       (scatter coef_2011_cat3 rel_year if rel_year >= -7 & rel_year <= 8, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2011_cat4 ci_lower_2011_cat4 rel_year if rel_year >= -7 & rel_year <= 8, lcolor(gold)) ///
       (scatter coef_2011_cat4 rel_year if rel_year >= -7 & rel_year <= 8, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Bahia/Paraíba (2011)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)8) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(ba_pb_sem_tendencia, replace) scheme(s1mono)
	   
	   * Salvar gráfico
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_BA_PB.pdf", replace
       
* 3. CE (2015)
clear
set obs 20
gen rel_year = _n - 12 

drop if rel_year == -11 | rel_year == -10 | rel_year == -9 | rel_year == -8 | rel_year == 5 | rel_year == 6 | rel_year == 7 | rel_year == 8

* CE (2015) - Categoria 1: low cap & close delegacia
gen coef_2015_cat1 = .
gen se_2015_cat1 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_cat1 = betas2015_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat1 = vars2015_cat1[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat1 = 0 if rel_year == 0
replace se_2015_cat1 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_cat1 = betas2015_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat1 = vars2015_cat1[1,`pos'] if rel_year == `rel_year'
}

* CE (2015) - Categoria 2: low cap & far delegacia
gen coef_2015_cat2 = .
gen se_2015_cat2 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_cat2 = betas2015_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat2 = vars2015_cat2[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat2 = 0 if rel_year == 0
replace se_2015_cat2 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_cat2 = betas2015_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat2 = vars2015_cat2[1,`pos'] if rel_year == `rel_year'
}

* CE (2015) - Categoria 3: high cap & close delegacia
gen coef_2015_cat3 = .
gen se_2015_cat3 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_cat3 = betas2015_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat3 = vars2015_cat3[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat3 = 0 if rel_year == 0
replace se_2015_cat3 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_cat3 = betas2015_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat3 = vars2015_cat3[1,`pos'] if rel_year == `rel_year'
}

* CE (2015) - Categoria 4: high cap & far delegacia
gen coef_2015_cat4 = .
gen se_2015_cat4 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2015_cat4 = betas2015_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat4 = vars2015_cat4[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat4 = 0 if rel_year == 0
replace se_2015_cat4 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2015_cat4 = betas2015_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat4 = vars2015_cat4[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2015_cat1 = coef_2015_cat1 + 1.96 * se_2015_cat1
gen ci_lower_2015_cat1 = coef_2015_cat1 - 1.96 * se_2015_cat1
gen ci_upper_2015_cat2 = coef_2015_cat2 + 1.96 * se_2015_cat2
gen ci_lower_2015_cat2 = coef_2015_cat2 - 1.96 * se_2015_cat2
gen ci_upper_2015_cat3 = coef_2015_cat3 + 1.96 * se_2015_cat3
gen ci_lower_2015_cat3 = coef_2015_cat3 - 1.96 * se_2015_cat3
gen ci_upper_2015_cat4 = coef_2015_cat4 + 1.96 * se_2015_cat4
gen ci_lower_2015_cat4 = coef_2015_cat4 - 1.96 * se_2015_cat4

* Gráfico para CE (2015) - 4 categorias (Sem Tendências)
twoway (rcap ci_upper_2015_cat1 ci_lower_2015_cat1 rel_year if rel_year >= -7 & rel_year <= 4, lcolor(midblue)) ///
       (scatter coef_2015_cat1 rel_year if rel_year >= -7 & rel_year <= 4, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2015_cat2 ci_lower_2015_cat2 rel_year if rel_year >= -7 & rel_year <= 4, lcolor(cranberry)) ///
       (scatter coef_2015_cat2 rel_year if rel_year >= -7 & rel_year <= 4, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2015_cat3 ci_lower_2015_cat3 rel_year if rel_year >= -7 & rel_year <= 4, lcolor(forest_green)) ///
       (scatter coef_2015_cat3 rel_year if rel_year >= -7 & rel_year <= 4, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2015_cat4 ci_lower_2015_cat4 rel_year if rel_year >= -7 & rel_year <= 4, lcolor(gold)) ///
       (scatter coef_2015_cat4 rel_year if rel_year >= -7 & rel_year <= 4, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Ceará (2015)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)4) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(ce_sem_tendencia, replace) scheme(s1mono)
	   
	   * Salvar gráfico
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_CE.pdf", replace
       
* 4. MA (2016)
clear
set obs 20
gen rel_year = _n - 12   

drop if rel_year == -11 | rel_year == -10 | rel_year == -9 | rel_year == -8 | rel_year == 4 | rel_year == 5 | rel_year == 6 | rel_year == 7 | rel_year == 8

* MA (2016) - Categoria 1: low cap & close delegacia
gen coef_2016_cat1 = .
gen se_2016_cat1 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_cat1 = betas2016_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat1 = vars2016_cat1[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat1 = 0 if rel_year == 0
replace se_2016_cat1 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_cat1 = betas2016_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat1 = vars2016_cat1[1,`pos'] if rel_year == `rel_year'
}

* MA (2016) - Categoria 2: low cap & far delegacia
gen coef_2016_cat2 = .
gen se_2016_cat2 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_cat2 = betas2016_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat2 = vars2016_cat2[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat2 = 0 if rel_year == 0
replace se_2016_cat2 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_cat2 = betas2016_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat2 = vars2016_cat2[1,`pos'] if rel_year == `rel_year'
}

* MA (2016) - Categoria 3: high cap & close delegacia
gen coef_2016_cat3 = .
gen se_2016_cat3 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_cat3 = betas2016_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat3 = vars2016_cat3[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat3 = 0 if rel_year == 0
replace se_2016_cat3 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_cat3 = betas2016_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat3 = vars2016_cat3[1,`pos'] if rel_year == `rel_year'
}

* MA (2016) - Categoria 4: high cap & far delegacia
gen coef_2016_cat4 = .
gen se_2016_cat4 = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2016_cat4 = betas2016_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat4 = vars2016_cat4[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat4 = 0 if rel_year == 0
replace se_2016_cat4 = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2016_cat4 = betas2016_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat4 = vars2016_cat4[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2016_cat1 = coef_2016_cat1 + 1.96 * se_2016_cat1
gen ci_lower_2016_cat1 = coef_2016_cat1 - 1.96 * se_2016_cat1
gen ci_upper_2016_cat2 = coef_2016_cat2 + 1.96 * se_2016_cat2
gen ci_lower_2016_cat2 = coef_2016_cat2 - 1.96 * se_2016_cat2
gen ci_upper_2016_cat3 = coef_2016_cat3 + 1.96 * se_2016_cat3
gen ci_lower_2016_cat3 = coef_2016_cat3 - 1.96 * se_2016_cat3
gen ci_upper_2016_cat4 = coef_2016_cat4 + 1.96 * se_2016_cat4
gen ci_lower_2016_cat4 = coef_2016_cat4 - 1.96 * se_2016_cat4

* Gráfico para MA (2016) - 4 categorias (Sem Tendências)
twoway (rcap ci_upper_2016_cat1 ci_lower_2016_cat1 rel_year if rel_year >= -7 & rel_year <= 3, lcolor(midblue)) ///
       (scatter coef_2016_cat1 rel_year if rel_year >= -7 & rel_year <= 3, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2016_cat2 ci_lower_2016_cat2 rel_year if rel_year >= -7 & rel_year <= 3, lcolor(cranberry)) ///
       (scatter coef_2016_cat2 rel_year if rel_year >= -7 & rel_year <= 3, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2016_cat3 ci_lower_2016_cat3 rel_year if rel_year >= -7 & rel_year <= 3, lcolor(forest_green)) ///
       (scatter coef_2016_cat3 rel_year if rel_year >= -7 & rel_year <= 3, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2016_cat4 ci_lower_2016_cat4 rel_year if rel_year >= -7 & rel_year <= 3, lcolor(gold)) ///
       (scatter coef_2016_cat4 rel_year if rel_year >= -7 & rel_year <= 3, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Maranhão (2016)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)3) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(ma_sem_tendencia, replace) scheme(s1mono)
	   
	   * Salvar gráfico
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_MA.pdf", replace
      
********************************************************************************
* Criar gráficos de event study para todas as coortes - MODELO COM TENDÊNCIAS
********************************************************************************

* 1. PE (2007) - Já foi criado
* 2. BA/PB (2011)
clear
set obs 20
gen rel_year = _n - 12   // Cria valores de -11 a 8 para centralizar em 0 (ano de tratamento)
drop if rel_year == -11 | rel_year == -10 | rel_year == -9 | rel_year == -8

* BA/PB (2011) - Categoria 1 com tendência
gen coef_2011_cat1_trend = .
gen se_2011_cat1_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2011_cat1_trend = . if rel_year == -11
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2011_cat1_trend = betas2011_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat1_trend = vars2011_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat1_trend = 0 if rel_year == 0
replace se_2011_cat1_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2011_cat1_trend = betas2011_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat1_trend = vars2011_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* BA/PB (2011) - Categoria 2 com tendência
gen coef_2011_cat2_trend = .
gen se_2011_cat2_trend = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2011_cat2_trend = betas2011_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat2_trend = vars2011_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat2_trend = 0 if rel_year == 0
replace se_2011_cat2_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2011_cat2_trend = betas2011_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat2_trend = vars2011_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* BA/PB (2011) - Categoria 3 com tendência
gen coef_2011_cat3_trend = .
gen se_2011_cat3_trend = .

* BA/PB (2011) - Categoria 3 com tendência (continuação)
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2011_cat3_trend = betas2011_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat3_trend = vars2011_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat3_trend = 0 if rel_year == 0
replace se_2011_cat3_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2011_cat3_trend = betas2011_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat3_trend = vars2011_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* BA/PB (2011) - Categoria 4 com tendência
gen coef_2011_cat4_trend = .
gen se_2011_cat4_trend = .

* Preencher valores dos coeficientes e erros padrão
replace coef_2011_cat4_trend = . if rel_year == -11
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2011_cat4_trend = betas2011_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat4_trend = vars2011_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2011_cat4_trend = 0 if rel_year == 0
replace se_2011_cat4_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/8 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2011_cat4_trend = betas2011_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2011_cat4_trend = vars2011_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2011_cat1_trend = coef_2011_cat1_trend + 1.96 * se_2011_cat1_trend
gen ci_lower_2011_cat1_trend = coef_2011_cat1_trend - 1.96 * se_2011_cat1_trend
gen ci_upper_2011_cat2_trend = coef_2011_cat2_trend + 1.96 * se_2011_cat2_trend
gen ci_lower_2011_cat2_trend = coef_2011_cat2_trend - 1.96 * se_2011_cat2_trend
gen ci_upper_2011_cat3_trend = coef_2011_cat3_trend + 1.96 * se_2011_cat3_trend
gen ci_lower_2011_cat3_trend = coef_2011_cat3_trend - 1.96 * se_2011_cat3_trend
gen ci_upper_2011_cat4_trend = coef_2011_cat4_trend + 1.96 * se_2011_cat4_trend
gen ci_lower_2011_cat4_trend = coef_2011_cat4_trend - 1.96 * se_2011_cat4_trend

* Gráfico para BA/PB (2011) - 4 categorias (Com Tendências)
twoway (rcap ci_upper_2011_cat1_trend ci_lower_2011_cat1_trend rel_year if rel_year >= -6 & rel_year <= 8, lcolor(midblue)) ///
       (scatter coef_2011_cat1_trend rel_year if rel_year >= -6 & rel_year <= 8, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2011_cat2_trend ci_lower_2011_cat2_trend rel_year if rel_year >= -6 & rel_year <= 8, lcolor(cranberry)) ///
       (scatter coef_2011_cat2_trend rel_year if rel_year >= -6 & rel_year <= 8, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2011_cat3_trend ci_lower_2011_cat3_trend rel_year if rel_year >= -6 & rel_year <= 8, lcolor(forest_green)) ///
       (scatter coef_2011_cat3_trend rel_year if rel_year >= -6 & rel_year <= 8, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2011_cat4_trend ci_lower_2011_cat4_trend rel_year if rel_year >= -6 & rel_year <= 8, lcolor(gold)) ///
       (scatter coef_2011_cat4_trend rel_year if rel_year >= -6 & rel_year <= 8, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Bahia/Paraíba (2011)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)8) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(ba_pb_com_tendencia, replace) scheme(s1mono)
	   
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_trends_BA_PB.pdf", replace	  

* 3. CE (2015)
clear
set obs 20
gen rel_year = _n - 12 

drop if rel_year == -11 | rel_year == -10 | rel_year == -9 | rel_year == -8 | rel_year == 5 | rel_year == 6 | rel_year == 7 | rel_year == 8

* CE (2015) - Categoria 1 com tendência
gen coef_2015_cat1_trend = .
gen se_2015_cat1_trend = .

* Preencher valores dos coeficientes e erros padrão - note que não temos t-15
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2015_cat1_trend = betas2015_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat1_trend = vars2015_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat1_trend = 0 if rel_year == 0
replace se_2015_cat1_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2015_cat1_trend = betas2015_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat1_trend = vars2015_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* CE (2015) - Categoria 2 com tendência
gen coef_2015_cat2_trend = .
gen se_2015_cat2_trend = .

* Preencher valores dos coeficientes e erros padrão

forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2015_cat2_trend = betas2015_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat2_trend = vars2015_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat2_trend = 0 if rel_year == 0
replace se_2015_cat2_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2015_cat2_trend = betas2015_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat2_trend = vars2015_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* CE (2015) - Categoria 3 com tendência
gen coef_2015_cat3_trend = .
gen se_2015_cat3_trend = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2015_cat3_trend = betas2015_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat3_trend = vars2015_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat3_trend = 0 if rel_year == 0
replace se_2015_cat3_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2015_cat3_trend = betas2015_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat3_trend = vars2015_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* CE (2015) - Categoria 4 com tendência
gen coef_2015_cat4_trend = .
gen se_2015_cat4_trend = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2015_cat4_trend = betas2015_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat4_trend = vars2015_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2015_cat4_trend = 0 if rel_year == 0
replace se_2015_cat4_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/4 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2015_cat4_trend = betas2015_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2015_cat4_trend = vars2015_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2015_cat1_trend = coef_2015_cat1_trend + 1.96 * se_2015_cat1_trend
gen ci_lower_2015_cat1_trend = coef_2015_cat1_trend - 1.96 * se_2015_cat1_trend
gen ci_upper_2015_cat2_trend = coef_2015_cat2_trend + 1.96 * se_2015_cat2_trend
gen ci_lower_2015_cat2_trend = coef_2015_cat2_trend - 1.96 * se_2015_cat2_trend
gen ci_upper_2015_cat3_trend = coef_2015_cat3_trend + 1.96 * se_2015_cat3_trend
gen ci_lower_2015_cat3_trend = coef_2015_cat3_trend - 1.96 * se_2015_cat3_trend
gen ci_upper_2015_cat4_trend = coef_2015_cat4_trend + 1.96 * se_2015_cat4_trend
gen ci_lower_2015_cat4_trend = coef_2015_cat4_trend - 1.96 * se_2015_cat4_trend

* Gráfico para CE (2015) - 4 categorias (Com Tendências)
twoway (rcap ci_upper_2015_cat1_trend ci_lower_2015_cat1_trend rel_year if rel_year >= -6 & rel_year <= 4, lcolor(midblue)) ///
       (scatter coef_2015_cat1_trend rel_year if rel_year >= -6 & rel_year <= 4, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2015_cat2_trend ci_lower_2015_cat2_trend rel_year if rel_year >= -6 & rel_year <= 4, lcolor(cranberry)) ///
       (scatter coef_2015_cat2_trend rel_year if rel_year >= -6 & rel_year <= 4, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2015_cat3_trend ci_lower_2015_cat3_trend rel_year if rel_year >= -6 & rel_year <= 4, lcolor(forest_green)) ///
       (scatter coef_2015_cat3_trend rel_year if rel_year >= -6 & rel_year <= 4, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2015_cat4_trend ci_lower_2015_cat4_trend rel_year if rel_year >= -6 & rel_year <= 4, lcolor(gold)) ///
       (scatter coef_2015_cat4_trend rel_year if rel_year >= -6 & rel_year <= 4, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Ceará (2015)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)4) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(ce_com_tendencia, replace) scheme(s1mono)
	   
	 graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_trends_CE.pdf", replace	  

* 4. MA (2016)
clear
set obs 20
gen rel_year = _n - 12   

drop if rel_year == -11 | rel_year == -10 | rel_year == -9 | rel_year == -8 | rel_year == 4 | rel_year == 5 | rel_year == 6 | rel_year == 7 | rel_year == 8

* MA (2016) - Categoria 1 com tendência
gen coef_2016_cat1_trend = .
gen se_2016_cat1_trend = .

* Preencher valores dos coeficientes e erros padrão -
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2016_cat1_trend = betas2016_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat1_trend = vars2016_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat1_trend = 0 if rel_year == 0
replace se_2016_cat1_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2016_cat1_trend = betas2016_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat1_trend = vars2016_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* MA (2016) - Categoria 2 com tendência
gen coef_2016_cat2_trend = .
gen se_2016_cat2_trend = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2016_cat2_trend = betas2016_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat2_trend = vars2016_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat2_trend = 0 if rel_year == 0
replace se_2016_cat2_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2016_cat2_trend = betas2016_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat2_trend = vars2016_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* MA (2016) - Categoria 3 com tendência
gen coef_2016_cat3_trend = .
gen se_2016_cat3_trend = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2016_cat3_trend = betas2016_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat3_trend = vars2016_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat3_trend = 0 if rel_year == 0
replace se_2016_cat3_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2016_cat3_trend = betas2016_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat3_trend = vars2016_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* MA (2016) - Categoria 4 com tendência
gen coef_2016_cat4_trend = .
gen se_2016_cat4_trend = .

* Preencher valores dos coeficientes e erros padrão
forvalues i=1/6 {
    local rel_year = -7 + `i'
    local pos = `i'
    replace coef_2016_cat4_trend = betas2016_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat4_trend = vars2016_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Omitir ano 0 (tratamento)
replace coef_2016_cat4_trend = 0 if rel_year == 0
replace se_2016_cat4_trend = 0 if rel_year == 0

* Pós-tratamento
forvalues i=1/3 {
    local rel_year = `i'
    local pos = 6 + `i'
    replace coef_2016_cat4_trend = betas2016_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2016_cat4_trend = vars2016_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Calcular intervalos de confiança (95%)
gen ci_upper_2016_cat1_trend = coef_2016_cat1_trend + 1.96 * se_2016_cat1_trend
gen ci_lower_2016_cat1_trend = coef_2016_cat1_trend - 1.96 * se_2016_cat1_trend
gen ci_upper_2016_cat2_trend = coef_2016_cat2_trend + 1.96 * se_2016_cat2_trend
gen ci_lower_2016_cat2_trend = coef_2016_cat2_trend - 1.96 * se_2016_cat2_trend
gen ci_upper_2016_cat3_trend = coef_2016_cat3_trend + 1.96 * se_2016_cat3_trend
gen ci_lower_2016_cat3_trend = coef_2016_cat3_trend - 1.96 * se_2016_cat3_trend
gen ci_upper_2016_cat4_trend = coef_2016_cat4_trend + 1.96 * se_2016_cat4_trend
gen ci_lower_2016_cat4_trend = coef_2016_cat4_trend - 1.96 * se_2016_cat4_trend

* Gráfico para MA (2016) - 4 categorias (Com Tendências)
twoway (rcap ci_upper_2016_cat1_trend ci_lower_2016_cat1_trend rel_year if rel_year >= -6 & rel_year <= 3, lcolor(midblue)) ///
       (scatter coef_2016_cat1_trend rel_year if rel_year >= -6 & rel_year <= 3, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2016_cat2_trend ci_lower_2016_cat2_trend rel_year if rel_year >= -6 & rel_year <= 3, lcolor(cranberry)) ///
       (scatter coef_2016_cat2_trend rel_year if rel_year >= -6 & rel_year <= 3, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2016_cat3_trend ci_lower_2016_cat3_trend rel_year if rel_year >= -6 & rel_year <= 3, lcolor(forest_green)) ///
       (scatter coef_2016_cat3_trend rel_year if rel_year >= -6 & rel_year <= 3, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2016_cat4_trend ci_lower_2016_cat4_trend rel_year if rel_year >= -6 & rel_year <= 3, lcolor(gold)) ///
       (scatter coef_2016_cat4_trend rel_year if rel_year >= -6 & rel_year <= 3, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Maranhão (2016)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)3) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(ma_com_tendencia, replace) scheme(s1mono)
	   
	 graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/delcap_event_study_trends_MA.pdf", replace	  

	

********************************************************************************
* Criar Tabela LaTeX para Event Study de PE com Heterogeneidade
********************************************************************************

* Abrir arquivo para escrever
cap file close f1
file open f1 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/event_study_PE_heterogeneity.tex", write replace

* Escrever cabeçalho da tabela
file write f1 "\begin{table}[h!]" _n
file write f1 "\centering" _n
file write f1 "\caption{Event Study for Pernambuco (2007) by Capacity and Distance to Police Stations}" _n
file write f1 "\label{tab:event_study_PE_het}" _n
file write f1 "\begin{tabular}{lcccccccc}" _n
file write f1 "\hline\hline" _n
file write f1 "& \multicolumn{2}{c}{Low Cap \& Close} & \multicolumn{2}{c}{Low Cap \& Far} & \multicolumn{2}{c}{High Cap \& Close} & \multicolumn{2}{c}{High Cap \& Far} \\" _n
file write f1 "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9}" _n
file write f1 "Trends & No & Yes & No & Yes & No & Yes & No & Yes \\" _n
file write f1 "\hline" _n

* Parte 1: Períodos pré-tratamento
* t-7 (apenas para o modelo sem tendência)
file write f1 "$t_{-7}$ & $" %7.3f (betas2007_cat1[1,1]) "$ & - & $" %7.3f (betas2007_cat2[1,1]) "$ & - & $" %7.3f (betas2007_cat3[1,1]) "$ & - & $" %7.3f (betas2007_cat4[1,1]) "$ & - \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,1]) ")$ & - & $(" %7.3f (vars2007_cat2[1,1]) ")$ & - & $(" %7.3f (vars2007_cat3[1,1]) ")$ & - & $(" %7.3f (vars2007_cat4[1,1]) ")$ & - \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,1]) "]$ & - & $[" %7.3f (pvalue2007_cat2[1,1]) "]$ & - & $[" %7.3f (pvalue2007_cat3[1,1]) "]$ & - & $[" %7.3f (pvalue2007_cat4[1,1]) "]$ & - \\" _n
file write f1 "\hline" _n

* t-6
file write f1 "$t_{-6}$ & $" %7.3f (betas2007_cat1[1,2]) "$ & $" %7.3f (betas2007_cat1_trend[1,1]) "$ & $" %7.3f (betas2007_cat2[1,2]) "$ & $" %7.3f (betas2007_cat2_trend[1,1]) "$ & $" %7.3f (betas2007_cat3[1,2]) "$ & $" %7.3f (betas2007_cat3_trend[1,1]) "$ & $" %7.3f (betas2007_cat4[1,2]) "$ & $" %7.3f (betas2007_cat4_trend[1,1]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,2]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,1]) ")$ & $(" %7.3f (vars2007_cat2[1,2]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,1]) ")$ & $(" %7.3f (vars2007_cat3[1,2]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,1]) ")$ & $(" %7.3f (vars2007_cat4[1,2]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,1]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,2]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,2]) "]$ & $[" %7.3f (pvalue2007_cat2[1,2]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,2]) "]$ & $[" %7.3f (pvalue2007_cat3[1,2]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,2]) "]$ & $[" %7.3f (pvalue2007_cat4[1,2]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,2]) "]$ \\" _n
file write f1 "\hline" _n

* t-5
file write f1 "$t_{-5}$ & $" %7.3f (betas2007_cat1[1,3]) "$ & $" %7.3f (betas2007_cat1_trend[1,2]) "$ & $" %7.3f (betas2007_cat2[1,3]) "$ & $" %7.3f (betas2007_cat2_trend[1,2]) "$ & $" %7.3f (betas2007_cat3[1,3]) "$ & $" %7.3f (betas2007_cat3_trend[1,2]) "$ & $" %7.3f (betas2007_cat4[1,3]) "$ & $" %7.3f (betas2007_cat4_trend[1,2]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,3]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,2]) ")$ & $(" %7.3f (vars2007_cat2[1,3]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,2]) ")$ & $(" %7.3f (vars2007_cat3[1,3]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,2]) ")$ & $(" %7.3f (vars2007_cat4[1,3]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,2]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,3]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,3]) "]$ & $[" %7.3f (pvalue2007_cat2[1,3]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,3]) "]$ & $[" %7.3f (pvalue2007_cat3[1,3]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,3]) "]$ & $[" %7.3f (pvalue2007_cat4[1,3]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,3]) "]$ \\" _n
file write f1 "\hline" _n

* t-4
file write f1 "$t_{-4}$ & $" %7.3f (betas2007_cat1[1,4]) "$ & $" %7.3f (betas2007_cat1_trend[1,3]) "$ & $" %7.3f (betas2007_cat2[1,4]) "$ & $" %7.3f (betas2007_cat2_trend[1,3]) "$ & $" %7.3f (betas2007_cat3[1,4]) "$ & $" %7.3f (betas2007_cat3_trend[1,3]) "$ & $" %7.3f (betas2007_cat4[1,4]) "$ & $" %7.3f (betas2007_cat4_trend[1,3]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,4]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,3]) ")$ & $(" %7.3f (vars2007_cat2[1,4]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,3]) ")$ & $(" %7.3f (vars2007_cat3[1,4]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,3]) ")$ & $(" %7.3f (vars2007_cat4[1,4]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,3]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,4]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,4]) "]$ & $[" %7.3f (pvalue2007_cat2[1,4]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,4]) "]$ & $[" %7.3f (pvalue2007_cat3[1,4]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,4]) "]$ & $[" %7.3f (pvalue2007_cat4[1,4]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,4]) "]$ \\" _n
file write f1 "\hline" _n

* t-3
file write f1 "$t_{-3}$ & $" %7.3f (betas2007_cat1[1,5]) "$ & $" %7.3f (betas2007_cat1_trend[1,4]) "$ & $" %7.3f (betas2007_cat2[1,5]) "$ & $" %7.3f (betas2007_cat2_trend[1,4]) "$ & $" %7.3f (betas2007_cat3[1,5]) "$ & $" %7.3f (betas2007_cat3_trend[1,4]) "$ & $" %7.3f (betas2007_cat4[1,5]) "$ & $" %7.3f (betas2007_cat4_trend[1,4]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,5]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,4]) ")$ & $(" %7.3f (vars2007_cat2[1,5]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,4]) ")$ & $(" %7.3f (vars2007_cat3[1,5]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,4]) ")$ & $(" %7.3f (vars2007_cat4[1,5]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,4]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,5]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,5]) "]$ & $[" %7.3f (pvalue2007_cat2[1,5]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,5]) "]$ & $[" %7.3f (pvalue2007_cat3[1,5]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,5]) "]$ & $[" %7.3f (pvalue2007_cat4[1,5]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,5]) "]$ \\" _n
file write f1 "\hline" _n

* t-2
file write f1 "$t_{-2}$ & $" %7.3f (betas2007_cat1[1,6]) "$ & $" %7.3f (betas2007_cat1_trend[1,5]) "$ & $" %7.3f (betas2007_cat2[1,6]) "$ & $" %7.3f (betas2007_cat2_trend[1,5]) "$ & $" %7.3f (betas2007_cat3[1,6]) "$ & $" %7.3f (betas2007_cat3_trend[1,5]) "$ & $" %7.3f (betas2007_cat4[1,6]) "$ & $" %7.3f (betas2007_cat4_trend[1,5]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,6]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,5]) ")$ & $(" %7.3f (vars2007_cat2[1,6]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,5]) ")$ & $(" %7.3f (vars2007_cat3[1,6]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,5]) ")$ & $(" %7.3f (vars2007_cat4[1,6]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,5]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,6]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,6]) "]$ & $[" %7.3f (pvalue2007_cat2[1,6]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,6]) "]$ & $[" %7.3f (pvalue2007_cat3[1,6]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,6]) "]$ & $[" %7.3f (pvalue2007_cat4[1,6]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,6]) "]$ \\" _n
file write f1 "\hline" _n

* t-1
file write f1 "$t_{-1}$ & $" %7.3f (betas2007_cat1[1,7]) "$ & $" %7.3f (betas2007_cat1_trend[1,6]) "$ & $" %7.3f (betas2007_cat2[1,7]) "$ & $" %7.3f (betas2007_cat2_trend[1,6]) "$ & $" %7.3f (betas2007_cat3[1,7]) "$ & $" %7.3f (betas2007_cat3_trend[1,6]) "$ & $" %7.3f (betas2007_cat4[1,7]) "$ & $" %7.3f (betas2007_cat4_trend[1,6]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,7]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,6]) ")$ & $(" %7.3f (vars2007_cat2[1,7]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,6]) ")$ & $(" %7.3f (vars2007_cat3[1,7]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,6]) ")$ & $(" %7.3f (vars2007_cat4[1,7]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,6]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,7]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,7]) "]$ & $[" %7.3f (pvalue2007_cat2[1,7]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,7]) "]$ & $[" %7.3f (pvalue2007_cat3[1,7]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,7]) "]$ & $[" %7.3f (pvalue2007_cat4[1,7]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,7]) "]$ \\" _n
file write f1 "\hline" _n

* Escrever linha para indicar que t0 é omitido
file write f1 "$t_{0}$ & \multicolumn{8}{c}{(omitido - ano do tratamento)} \\" _n
file write f1 "\hline" _n

* Parte 2: Períodos pós-tratamento
* t+1
file write f1 "$t_{+1}$ & $" %7.3f (betas2007_cat1[1,8]) "$ & $" %7.3f (betas2007_cat1_trend[1,7]) "$ & $" %7.3f (betas2007_cat2[1,8]) "$ & $" %7.3f (betas2007_cat2_trend[1,7]) "$ & $" %7.3f (betas2007_cat3[1,8]) "$ & $" %7.3f (betas2007_cat3_trend[1,7]) "$ & $" %7.3f (betas2007_cat4[1,8]) "$ & $" %7.3f (betas2007_cat4_trend[1,7]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,8]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,7]) ")$ & $(" %7.3f (vars2007_cat2[1,8]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,7]) ")$ & $(" %7.3f (vars2007_cat3[1,8]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,7]) ")$ & $(" %7.3f (vars2007_cat4[1,8]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,7]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,8]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,8]) "]$ & $[" %7.3f (pvalue2007_cat2[1,8]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,8]) "]$ & $[" %7.3f (pvalue2007_cat3[1,8]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,8]) "]$ & $[" %7.3f (pvalue2007_cat4[1,8]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,8]) "]$ \\" _n
file write f1 "\hline" _n

* t+2
file write f1 "$t_{+2}$ & $" %7.3f (betas2007_cat1[1,9]) "$ & $" %7.3f (betas2007_cat1_trend[1,8]) "$ & $" %7.3f (betas2007_cat2[1,9]) "$ & $" %7.3f (betas2007_cat2_trend[1,8]) "$ & $" %7.3f (betas2007_cat3[1,9]) "$ & $" %7.3f (betas2007_cat3_trend[1,8]) "$ & $" %7.3f (betas2007_cat4[1,9]) "$ & $" %7.3f (betas2007_cat4_trend[1,8]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,9]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,8]) ")$ & $(" %7.3f (vars2007_cat2[1,9]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,8]) ")$ & $(" %7.3f (vars2007_cat3[1,9]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,8]) ")$ & $(" %7.3f (vars2007_cat4[1,9]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,8]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,9]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,9]) "]$ & $[" %7.3f (pvalue2007_cat2[1,9]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,9]) "]$ & $[" %7.3f (pvalue2007_cat3[1,9]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,9]) "]$ & $[" %7.3f (pvalue2007_cat4[1,9]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,9]) "]$ \\" _n
file write f1 "\hline" _n

* t+3
file write f1 "$t_{+3}$ & $" %7.3f (betas2007_cat1[1,10]) "$ & $" %7.3f (betas2007_cat1_trend[1,9]) "$ & $" %7.3f (betas2007_cat2[1,10]) "$ & $" %7.3f (betas2007_cat2_trend[1,9]) "$ & $" %7.3f (betas2007_cat3[1,10]) "$ & $" %7.3f (betas2007_cat3_trend[1,9]) "$ & $" %7.3f (betas2007_cat4[1,10]) "$ & $" %7.3f (betas2007_cat4_trend[1,9]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,10]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,9]) ")$ & $(" %7.3f (vars2007_cat2[1,10]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,9]) ")$ & $(" %7.3f (vars2007_cat3[1,10]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,9]) ")$ & $(" %7.3f (vars2007_cat4[1,10]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,9]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,10]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,10]) "]$ & $[" %7.3f (pvalue2007_cat2[1,10]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,10]) "]$ & $[" %7.3f (pvalue2007_cat3[1,10]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,10]) "]$ & $[" %7.3f (pvalue2007_cat4[1,10]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,10]) "]$ \\" _n
file write f1 "\hline" _n

* t+4
file write f1 "$t_{+4}$ & $" %7.3f (betas2007_cat1[1,11]) "$ & $" %7.3f (betas2007_cat1_trend[1,10]) "$ & $" %7.3f (betas2007_cat2[1,11]) "$ & $" %7.3f (betas2007_cat2_trend[1,10]) "$ & $" %7.3f (betas2007_cat3[1,11]) "$ & $" %7.3f (betas2007_cat3_trend[1,10]) "$ & $" %7.3f (betas2007_cat4[1,11]) "$ & $" %7.3f (betas2007_cat4_trend[1,10]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,11]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,10]) ")$ & $(" %7.3f (vars2007_cat2[1,11]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,10]) ")$ & $(" %7.3f (vars2007_cat3[1,11]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,10]) ")$ & $(" %7.3f (vars2007_cat4[1,11]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,10]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,11]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,11]) "]$ & $[" %7.3f (pvalue2007_cat2[1,11]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,11]) "]$ & $[" %7.3f (pvalue2007_cat3[1,11]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,11]) "]$ & $[" %7.3f (pvalue2007_cat4[1,11]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,11]) "]$ \\" _n
file write f1 "\hline" _n

* t+5
file write f1 "$t_{+5}$ & $" %7.3f (betas2007_cat1[1,12]) "$ & $" %7.3f (betas2007_cat1_trend[1,11]) "$ & $" %7.3f (betas2007_cat2[1,12]) "$ & $" %7.3f (betas2007_cat2_trend[1,11]) "$ & $" %7.3f (betas2007_cat3[1,12]) "$ & $" %7.3f (betas2007_cat3_trend[1,11]) "$ & $" %7.3f (betas2007_cat4[1,12]) "$ & $" %7.3f (betas2007_cat4_trend[1,11]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,12]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,11]) ")$ & $(" %7.3f (vars2007_cat2[1,12]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,11]) ")$ & $(" %7.3f (vars2007_cat3[1,12]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,11]) ")$ & $(" %7.3f (vars2007_cat4[1,12]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,11]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,12]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,12]) "]$ & $[" %7.3f (pvalue2007_cat2[1,12]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,12]) "]$ & $[" %7.3f (pvalue2007_cat3[1,12]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,12]) "]$ & $[" %7.3f (pvalue2007_cat4[1,12]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,12]) "]$ \\" _n
file write f1 "\hline" _n

* t+6
file write f1 "$t_{+6}$ & $" %7.3f (betas2007_cat1[1,13]) "$ & $" %7.3f (betas2007_cat1_trend[1,12]) "$ & $" %7.3f (betas2007_cat2[1,13]) "$ & $" %7.3f (betas2007_cat2_trend[1,12]) "$ & $" %7.3f (betas2007_cat3[1,13]) "$ & $" %7.3f (betas2007_cat3_trend[1,12]) "$ & $" %7.3f (betas2007_cat4[1,13]) "$ & $" %7.3f (betas2007_cat4_trend[1,12]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,13]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,12]) ")$ & $(" %7.3f (vars2007_cat2[1,13]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,12]) ")$ & $(" %7.3f (vars2007_cat3[1,13]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,12]) ")$ & $(" %7.3f (vars2007_cat4[1,13]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,12]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,13]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,13]) "]$ & $[" %7.3f (pvalue2007_cat2[1,13]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,13]) "]$ & $[" %7.3f (pvalue2007_cat3[1,13]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,13]) "]$ & $[" %7.3f (pvalue2007_cat4[1,13]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,13]) "]$ \\" _n
file write f1 "\hline" _n

* t+7
file write f1 "$t_{+7}$ & $" %7.3f (betas2007_cat1[1,14]) "$ & $" %7.3f (betas2007_cat1_trend[1,13]) "$ & $" %7.3f (betas2007_cat2[1,14]) "$ & $" %7.3f (betas2007_cat2_trend[1,13]) "$ & $" %7.3f (betas2007_cat3[1,14]) "$ & $" %7.3f (betas2007_cat3_trend[1,13]) "$ & $" %7.3f (betas2007_cat4[1,14]) "$ & $" %7.3f (betas2007_cat4_trend[1,13]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,14]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,13]) ")$ & $(" %7.3f (vars2007_cat2[1,14]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,13]) ")$ & $(" %7.3f (vars2007_cat3[1,14]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,13]) ")$ & $(" %7.3f (vars2007_cat4[1,14]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,13]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,14]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,14]) "]$ & $[" %7.3f (pvalue2007_cat2[1,14]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,14]) "]$ & $[" %7.3f (pvalue2007_cat3[1,14]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,14]) "]$ & $[" %7.3f (pvalue2007_cat4[1,14]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,14]) "]$ \\" _n
file write f1 "\hline" _n

* t+8
file write f1 "$t_{+8}$ & $" %7.3f (betas2007_cat1[1,15]) "$ & $" %7.3f (betas2007_cat1_trend[1,14]) "$ & $" %7.3f (betas2007_cat2[1,15]) "$ & $" %7.3f (betas2007_cat2_trend[1,14]) "$ & $" %7.3f (betas2007_cat3[1,15]) "$ & $" %7.3f (betas2007_cat3_trend[1,14]) "$ & $" %7.3f (betas2007_cat4[1,15]) "$ & $" %7.3f (betas2007_cat4_trend[1,14]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,15]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,14]) ")$ & $(" %7.3f (vars2007_cat2[1,15]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,14]) ")$ & $(" %7.3f (vars2007_cat3[1,15]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,14]) ")$ & $(" %7.3f (vars2007_cat4[1,15]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,14]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,15]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,15]) "]$ & $[" %7.3f (pvalue2007_cat2[1,15]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,15]) "]$ & $[" %7.3f (pvalue2007_cat3[1,15]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,15]) "]$ & $[" %7.3f (pvalue2007_cat4[1,15]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,15]) "]$ \\" _n
file write f1 "\hline" _n

* t+9
file write f1 "$t_{+9}$ & $" %7.3f (betas2007_cat1[1,16]) "$ & $" %7.3f (betas2007_cat1_trend[1,15]) "$ & $" %7.3f (betas2007_cat2[1,16]) "$ & $" %7.3f (betas2007_cat2_trend[1,15]) "$ & $" %7.3f (betas2007_cat3[1,16]) "$ & $" %7.3f (betas2007_cat3_trend[1,15]) "$ & $" %7.3f (betas2007_cat4[1,16]) "$ & $" %7.3f (betas2007_cat4_trend[1,15]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,16]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,15]) ")$ & $(" %7.3f (vars2007_cat2[1,16]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,15]) ")$ & $(" %7.3f (vars2007_cat3[1,16]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,15]) ")$ & $(" %7.3f (vars2007_cat4[1,16]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,15]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,16]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,16]) "]$ & $[" %7.3f (pvalue2007_cat2[1,16]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,16]) "]$ & $[" %7.3f (pvalue2007_cat3[1,16]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,16]) "]$ & $[" %7.3f (pvalue2007_cat4[1,16]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,16]) "]$ \\" _n
file write f1 "\hline" _n

* t+10
file write f1 "$t_{+10}$ & $" %7.3f (betas2007_cat1[1,17]) "$ & $" %7.3f (betas2007_cat1_trend[1,16]) "$ & $" %7.3f (betas2007_cat2[1,17]) "$ & $" %7.3f (betas2007_cat2_trend[1,16]) "$ & $" %7.3f (betas2007_cat3[1,17]) "$ & $" %7.3f (betas2007_cat3_trend[1,16]) "$ & $" %7.3f (betas2007_cat4[1,17]) "$ & $" %7.3f (betas2007_cat4_trend[1,16]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,17]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,16]) ")$ & $(" %7.3f (vars2007_cat2[1,17]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,16]) ")$ & $(" %7.3f (vars2007_cat3[1,17]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,16]) ")$ & $(" %7.3f (vars2007_cat4[1,17]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,16]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,17]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,17]) "]$ & $[" %7.3f (pvalue2007_cat2[1,17]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,17]) "]$ & $[" %7.3f (pvalue2007_cat3[1,17]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,17]) "]$ & $[" %7.3f (pvalue2007_cat4[1,17]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,17]) "]$ \\" _n
file write f1 "\hline" _n

* t+11
file write f1 "$t_{+11}$ & $" %7.3f (betas2007_cat1[1,18]) "$ & $" %7.3f (betas2007_cat1_trend[1,17]) "$ & $" %7.3f (betas2007_cat2[1,18]) "$ & $" %7.3f (betas2007_cat2_trend[1,17]) "$ & $" %7.3f (betas2007_cat3[1,18]) "$ & $" %7.3f (betas2007_cat3_trend[1,17]) "$ & $" %7.3f (betas2007_cat4[1,18]) "$ & $" %7.3f (betas2007_cat4_trend[1,17]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,18]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,17]) ")$ & $(" %7.3f (vars2007_cat2[1,18]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,17]) ")$ & $(" %7.3f (vars2007_cat3[1,18]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,17]) ")$ & $(" %7.3f (vars2007_cat4[1,18]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,17]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,18]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,18]) "]$ & $[" %7.3f (pvalue2007_cat2[1,18]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,18]) "]$ & $[" %7.3f (pvalue2007_cat3[1,18]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,18]) "]$ & $[" %7.3f (pvalue2007_cat4[1,18]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,18]) "]$ \\" _n
file write f1 "\hline" _n

* t+12
file write f1 "$t_{+12}$ & $" %7.3f (betas2007_cat1[1,19]) "$ & $" %7.3f (betas2007_cat1_trend[1,18]) "$ & $" %7.3f (betas2007_cat2[1,19]) "$ & $" %7.3f (betas2007_cat2_trend[1,18]) "$ & $" %7.3f (betas2007_cat3[1,19]) "$ & $" %7.3f (betas2007_cat3_trend[1,18]) "$ & $" %7.3f (betas2007_cat4[1,19]) "$ & $" %7.3f (betas2007_cat4_trend[1,18]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,19]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,18]) ")$ & $(" %7.3f (vars2007_cat2[1,19]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,18]) ")$ & $(" %7.3f (vars2007_cat3[1,19]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,18]) ")$ & $(" %7.3f (vars2007_cat4[1,19]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,18]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,19]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,19]) "]$ & $[" %7.3f (pvalue2007_cat2[1,19]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,19]) "]$ & $[" %7.3f (pvalue2007_cat3[1,19]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,19]) "]$ & $[" %7.3f (pvalue2007_cat4[1,19]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,19]) "]$ \\" _n
file write f1 "\hline" _n

* Número de observações
file write f1 "Observations & \multicolumn{4}{c}{$" %10.0f (nobs) "$} & \multicolumn{4}{c}{$" %10.0f (nobs_trend) "$} \\" _n
file write f1 "\hline\hline" _n

* Adicionar notas de rodapé
file write f1 "\end{tabular}" _n
file write f1 "\begin{tablenotes}" _n
file write f1 "\small" _n
file write f1 "\item Nota: Esta tabela apresenta os coeficientes do event study para Pernambuco (2007), divididos por categorias de capacidade policial e distância a delegacias. Categoria 1: Baixa capacidade \& Delegacia próxima; Categoria 2: Baixa capacidade \& Delegacia distante; Categoria 3: Alta capacidade \& Delegacia próxima; Categoria 4: Alta capacidade \& Delegacia distante. Erros padrão entre parênteses e p-values do bootstrap wild cluster entre colchetes. Os modelos incluem efeitos fixos de município e ano, além do logaritmo da população. Os testes F avaliam a hipótese nula de que todos os coeficientes pré-tratamento são conjuntamente iguais a zero." _n
file write f1 "\end{tablenotes}" _n
file write f1 "\end{table}" _n

* Fechar o arquivo
file close f1
