* Criar dataset com anos calendário
clear
set obs 100

* Criar variáveis
gen state = .
gen year = .
gen period = .
gen has_data = .
gen tipo = .

* Preencher dados para cada estado
local n = 1
foreach y in 2007 2011 2011 2015 2016 {
    forvalues cal_year = 2000/2019 {
        local obs = (`n'-1)*20 + `cal_year' - 1999
        replace state = `n' in `obs'
        replace year = `cal_year' in `obs'
        replace period = `cal_year' - `y' in `obs'
        replace has_data = 1 in `obs'
        
        * Classificar o tipo do período
        if `cal_year' == `y' {
            replace tipo = 1 in `obs'  // Ano do tratamento
        }
        else if `cal_year' > `y' & `cal_year' <= `y' + 12 {
            replace tipo = 2 in `obs'  // Pós-tratamento
        }
        else if `cal_year' < `y' & `cal_year' >= `y' - 7 {
            replace tipo = 3 in `obs'  // Pré-tratamento incluído
        }
        else {
            replace tipo = 4 in `obs'  // Pré-tratamento não incluído
        }
    }
    local n = `n' + 1
}

* Criar labels para os estados
label define states 1 "State (T=2007)" 2 "State (T=2011)" 3 "State (T=2011)" ///
    4 "State (T=2015)" 5 "State (T=2016)"
label values state states

* Criar o gráfico com ajustes de legibilidade
twoway (scatter state year if tipo==1, msymbol(D) mcolor(red) msize(vlarge)) ///
       (scatter state year if tipo==2, msymbol(square) mcolor(blue) msize(large)) ///
       (scatter state year if tipo==3, msymbol(square) mcolor(green) msize(large)) ///
       (scatter state year if tipo==4, msymbol(square) mcolor(gs12) msize(large)), ///
       ytitle("") xtitle("Year") ///
       ylabel(1(1)5, valuelabel angle(0) labsize(medium)) ///
       xlabel(2000(1)2019, angle(45) labsize(medium)) ///
       title("Temporal Coverage by State", size(large)) ///
       legend(order( ///
           1 "Treatment Year" ///
           2 "Post Treatment Years" ///
           3 "Pre Treatment Years" ///
           4 "Not Included Pre Treament Years" ///
       ) cols(2) position(6) size(small) symxsize(5) symysize(4) region(lcolor(white))) ///
       yline(1.5 2.5 3.5 4.5, lcolor(gs14)) ///
       xline(2007 2011 2015 2016, lpattern(dash) lcolor(gs10)) ///
       graphregion(color(white) margin(medium)) bgcolor(white) ///
       scheme(s2color) plotregion(margin(medium))

graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/temporal_coverage_state.pdf", as(pdf) replace
