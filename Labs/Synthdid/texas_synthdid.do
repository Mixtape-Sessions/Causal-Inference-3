* texas_synthdid.do

clear
capture log close

* installation
net install sdid, from("https://raw.githubusercontent.com/daniel-pailanir/sdid/master") replace

* Load the dataset
use "https://raw.github.com/scunning1975/mixtape/master/texas.dta", clear

* Create the treated variable
gen 	treated = 0
replace treated = 1 if state == "Texas" & year >= 1993

* Run the Synthetic Difference-in-Differences estimator
#delimit ;
sdid bmprison statefip year treated, vce(placebo) reps(100) seed(123)
    graph g1on g1_opt(xtitle("") scheme(plotplainblind)) 
    g2_opt(ylabel(0(10000)75000) xlabel(1985(5)2000) ytitle("Black Male Imprisonment") 
           xtitle("") scheme(plotplainblind))
    graph_export(sdid_, .png);
#delimit cr

* Generate a uniform variable for use as a control
gen r = runiform()

* Run sdid with and without covariates
eststo sdid_1: sdid bmprison statefip year treated, vce(placebo) seed(2022)
eststo sdid_2: sdid bmprison statefip year treated, vce(placebo) seed(2022) covariates(r, projected)

* Create a results table
esttab sdid_1 sdid_2, starlevel ("*" 0.10 "**" 0.05 "***" 0.01) b(%-9.3f) se(%-9.3f)
