* Name: smoking_synth.do

cd "/Users/scott_cunningham/Documents/Causal-Inference-3/Labs/Smoking/Do"
use https://github.com/scunning1975/mixtape/raw/master/synth_smoking.dta, clear
tsset state year

label variable cigsale "per-capita cigarette sales (in packs)"
label variable year "Year"

synth cigsale ///
    lnincome age15to24 beer retprice ///
    cigsale(1975) cigsale(1980) cigsale(1988), ///
    trunit(3) trperiod(1988) ///
    mspeperiod(1970(1)1988) resultsperiod(1970(1)2000) ///
    keep(../Permutations/synth_ca.dta) replace fig

mat list e(V_matrix)

graph save Graph ../Figures/synth_ca.gph, replace


* Plot the gap in predicted error
use ../Permutations/synth_ca.dta, clear
keep _Y_treated _Y_synthetic _time
drop if _time==.
rename _time year
rename _Y_treated  treat
rename _Y_synthetic counterfact
gen gap3=treat-counterfact
sort year 
twoway (line gap3 year,lp(solid)lw(thick)lcolor(black)), yline(0, lpattern(shortdash) lcolor(black)) xline(1988, lpattern(shortdash) lcolor(black)) xtitle("",si(medsmall)) xlabel(#10) ytitle("Gap in per-capita cigarette sales (in packs)", size(medsmall)) legend(off)
save ../Permutations/synth_3.dta, replace


* Placebo inference
clear
use https://github.com/scunning1975/mixtape/raw/master/synth_smoking.dta, clear

* Define the time-series structure
tsset state year

* Define statelist
local statelist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39

* Create output folder for results
!mkdir -p ../Permutations

* Use foreach to loop through states
foreach i of local statelist {
    di "Running synth for state `i'"
    capture synth cigsale ///
        lnincome age15to24 beer retprice ///
        cigsale(1975) cigsale(1980) cigsale(1988), ///
        trunit(`i') trperiod(1988) ///
        mspeperiod(1970(1)1988) resultsperiod(1970(1)2000) ///
        keep("../Permutations/synth_`i'.dta") replace

    if _rc != 0 {
        di as error "Error running synth for state `i'"
    } 
	
	else {
        matrix state`i' = e(RMSPE)
    }
}


* Define statelist
local statelist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
foreach i of local statelist {
	matrix rownames state`i'=`i'
	matlist state`i', names(rows)
	}


#delimit cr
local statelist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39

 foreach i of local statelist {
 	
 	use ../Permutations/synth_`i' ,clear
 	keep _Y_treated _Y_synthetic _time
 	drop if _time==.
	rename _time year
 	rename _Y_treated  treat`i'
 	rename _Y_synthetic counterfact`i'
 	gen gap`i'=treat`i'-counterfact`i'
 	sort year 
 	save ../Permutations/synth_gap_`i', replace
}

use ../Permutations/synth_gap_3.dta, clear
sort year
save ../Permutations/placebo_3.dta, replace

foreach i of local statelist {
		
		merge year using ../Permutations/synth_gap_`i'
		drop _merge
		sort year
		
	save ../Permutations/placebo_smoking.dta, replace
}

** Inference 2: Estimate the pre- and post-RMSPE and calculate the ratio of the
*  post-pre RMSPE	
set more off
local statelist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39

foreach i of local statelist {
	use ../Permutations/synth_gap_`i', clear
	
	gen gap_sq=gap`i'*gap`i'
	egen postmean=mean(gap_sq) if year>1988
	egen premean=mean(gap_sq) if year<=1988
	gen rmspe=sqrt(premean) if year<=1988
	replace rmspe=sqrt(postmean) if year>1988
	gen ratio=rmspe/rmspe[_n-1] if year==1989
	gen rmspe_post=sqrt(postmean) if year>1988
	gen rmspe_pre=rmspe[_n-1] if year==1989
	
	mkmat rmspe_pre rmspe_post ratio if year==1989, matrix (state`i')
								}

* show post/pre-expansion RMSPE ratio for all states, generate histogram
foreach i of local statelist {
	matrix rownames state`i'=`i'
	matlist state`i', names(rows)
								}

* ssc install mat2txt, replace

mat state=state1\state2\state3\state4\state5\state6\state7\state8\state9\state10\state11\state12\state13\state14\state15\state16\state17\state18\state19\state20\state21\state22\state23\state24\state25\state26\state27\state28\state29\state30\state31\state32\state33\state34\state35\state36\state37\state38\state39

	mat2txt, matrix(state) saving(../inference/rmspe.txt) replace
	insheet using ../inference/rmspe.txt, clear
	ren v1 state
	drop v5
	gsort -ratio
	gen rank=_n
	gen p=rank/39
	
	export excel using ../inference/rmspe, firstrow(variables) replace

	import excel ../Inference/rmspe.xlsx, sheet("Sheet1") firstrow clear
	
	histogram ratio, bin(20) frequency fcolor(gs13) lcolor(black) ylabel(0(2)12) xtitle(Post/pre RMSPE ratio) xlabel(0(2)10, format(%9.0f)) title("Randomization inference on post to pre RMSPE")

	* Show the post/pre RMSPE ratio for all states, generate the histogram.
list rank p if state==3


* Inference 3: all the placeboes on the same picture
use ../Permutations/placebo_smoking.dta, replace

#delimit ;
twoway 
(line gap1 year , lp(solid) lw(vthin)) 
(line gap2 year , lp(solid) lw(vthin)) 
(line gap3 year , lp(solid) lw(vthin)) 
(line gap4 year , lp(solid) lw(vthin)) 
(line gap5 year , lp(solid) lw(vthin)) 
(line gap6 year , lp(solid) lw(vthin)) 
(line gap7 year , lp(solid) lw(vthin)) 
(line gap8 year , lp(solid) lw(vthin)) 
(line gap9 year , lp(solid) lw(vthin)) 
(line gap10 year , lp(solid) lw(vthin)) 
(line gap11 year , lp(solid) lw(vthin)) 
(line gap12 year , lp(solid) lw(vthin)) 
(line gap13 year , lp(solid) lw(vthin)) 
(line gap14 year , lp(solid) lw(vthin)) 
(line gap15 year , lp(solid) lw(vthin)) 
(line gap16 year , lp(solid) lw(vthin)) 
(line gap17 year , lp(solid) lw(vthin)) 
(line gap18 year , lp(solid) lw(vthin)) 
(line gap19 year , lp(solid) lw(vthin)) 
(line gap20 year , lp(solid) lw(vthin)) 
(line gap21 year , lp(solid) lw(vthin)) 
(line gap22 year , lp(solid) lw(vthin)) 
(line gap23 year , lp(solid) lw(vthin)) 
(line gap24 year , lp(solid) lw(vthin)) 
(line gap25 year , lp(solid) lw(vthin)) 
(line gap26 year , lp(solid) lw(vthin)) 
(line gap27 year , lp(solid) lw(vthin)) 
(line gap28 year , lp(solid) lw(vthin)) 
(line gap29 year , lp(solid) lw(vthin)) 
(line gap30 year , lp(solid) lw(vthin)) 
(line gap31 year , lp(solid) lw(vthin)) 
(line gap32 year , lp(solid) lw(vthin)) 
(line gap33 year , lp(solid) lw(vthin)) 
(line gap34 year , lp(solid) lw(vthin)) 
(line gap35 year , lp(solid) lw(vthin)) 
(line gap36 year , lp(solid) lw(vthin)) 
(line gap37 year , lp(solid) lw(vthin)) 
(line gap38 year , lp(solid) lw(vthin)) 
(line gap39 year , lp(solid) lw(vthin)) 
(line gap3 year , lp(solid) lw(thick) lcolor(black)), /* treatment unit, California */
yline(0, lpattern(shortdash) lcolor(black)) 
xline(1988, lpattern(shortdash) lcolor(black)) 
xtitle("", si(small)) 
xlabel(#10) 
ytitle("Gap in per-capita smoking (in packs)", size(small)) 
legend(off);

#delimit cr


* Drop the outliers 
#delimit ;
twoway 
(line gap3 year , lp(solid) lw(thick) lcolor(black)) /* treatment unit, California */
(line gap7 year , lp(solid) lw(vthin)) 
(line gap36 year , lp(solid) lw(vthin)) 
(line gap37 year , lp(solid) lw(vthin)) 
(line gap32 year , lp(solid) lw(vthin)) 
(line gap33 year , lp(solid) lw(vthin)) 
(line gap18 year , lp(solid) lw(vthin)) 
(line gap27 year , lp(solid) lw(vthin)) 
(line gap23 year , lp(solid) lw(vthin)) 
(line gap30 year , lp(solid) lw(vthin)) 
(line gap9 year , lp(solid) lw(vthin)) 
(line gap19 year , lp(solid) lw(vthin)) 
(line gap14 year , lp(solid) lw(vthin)) 
(line gap17 year , lp(solid) lw(vthin)) 
(line gap8 year , lp(solid) lw(vthin)) 
(line gap2 year , lp(solid) lw(vthin)) 
(line gap31 year , lp(solid) lw(vthin)) 
(line gap38 year , lp(solid) lw(vthin)) 
(line gap20 year , lp(solid) lw(vthin)) 
(line gap28 year , lp(solid) lw(vthin)) 
(line gap1 year , lp(solid) lw(vthin)) 
(line gap26 year , lp(solid) lw(vthin)), 
yline(0, lpattern(shortdash) lcolor(black)) 
xline(1988, lpattern(shortdash) lcolor(black)) 
xtitle("", si(small)) 
xlabel(#10) 
ytitle("Gap in per-capita smoking (in packs)", size(small)) 
legend(off);
#delimit cr
