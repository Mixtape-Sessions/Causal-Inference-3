********************************************************************************
* name: texas_synthdid.do
* author: scott cunningham (baylor)
* description: estimating treatment effects for the texas prison expansion
********************************************************************************
clear
capture log close

net install sdid, from("https://raw.githubusercontent.com/daniel-pailanir/sdid/master") replace

use "https://raw.github.com/scunning1975/mixtape/master/texas.dta", clear

/* 
syntax

sdid Y S T D [if] [in], vce(method) seed(#) reps(#) covariates(varlist [, method])
                        zeta_lambda(real) zeta_omega(real) min_dec(real) max_iter(real)
                        method(methodtype) unstandardized graph_export([stub] , type) mattitles
                        graph g1on g1_opt(string) g2_opt(string) msize() 
						
example

#delimit ;
sdid packspercapita state year treated, vce(placebo) reps(100) seed(123) 
     graph g1on g1_opt(xtitle("") ylabel(-35(5)10) scheme(plotplainblind)) 
     g2_opt(ylabel(0(50)150) xlabel(1970(5)2000) ytitle("Packs per capita") 
            xtitle("") text(125 1995 "ATT = -15.604" " SE = (9.338)") scheme(plotplainblind))
    graph_export(sdid_, .png);
#delimit cr

						
*/


gen treated = 0
replace treated = 1 if state=="Texas" & year>=1993

#delimit ;

sdid bmprison statefip year treated, vce(placebo) reps(100) seed(123)
    graph g1on g1_opt(xtitle("") scheme(plotplainblind)) 
    g2_opt(ylabel(0(10000)75000) xlabel(1985(5)2000) ytitle("Packs per capita") 
    xtitle("") scheme(plotplainblind))
	graph_export(sdid_, .png);
	
#delimit cr



	