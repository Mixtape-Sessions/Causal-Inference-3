* smoking_synthdid.do

capture log close
clear

* Load Smoking data -- Worse fit
use https://github.com/scunning1975/mixtape/raw/master/synth_smoking.dta, clear

tsset state year

gen 	treated=0
replace treated=1 if state==3 & year>=1988

* Run the Synthetic Difference-in-Differences estimator
#delimit ;
sdid cigsale state year treated, vce(placebo) reps(100) seed(123)
    graph g1on g1_opt(xtitle("") scheme(plotplainblind)) 
    g2_opt(ylabel(0(25)150) xlabel(1970(5)2000) ytitle("Packs of Cigarettes Per Capita") 
           xtitle("") scheme(plotplainblind))
    graph_export(sdid_, .png);
#delimit cr

