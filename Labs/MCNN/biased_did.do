* DGP parallel trends
tempname handle
postfile `handle' att did mcnn using results.dta, replace

* Loop through the iterations
forvalues i = 1/100 {
quietly clear
quietly drop _all 
quietly set seed `i'

* States, Groups, and Time Setup
quietly set obs 40
quietly gen state = _n

* Generate treatment groups
quietly gen experimental = 0
quietly replace experimental = 1 in 1/20

* 50 cities per state
quietly expand 50
quietly bysort state: gen city_no = _n
quietly egen city = group(city_no state)
quietly drop city_no

* Time, 10 years
quietly expand 10
quietly sort state
quietly bysort state city: gen year = _n

* Setting years
quietly foreach y of numlist 1/10 {
    quietly local year 2010 + `y' - 1
    quietly replace year = `year' if year == `y'
}

* Define the after period (post-2015)
quietly gen after = year >= 2015

* Baseline earnings in 2010 with different values for experimental and non-experimental states
quietly gen 	baseline = 40000 // Married women

* Adjust baseline for experimental states
quietly replace baseline = 2 * baseline if experimental == 1

* Trend
quietly gen year_diff = year - 2010

* Annual wage growth for Y(0) incorporating state and group trends
quietly gen y0 = baseline + year_diff*1000 

* Adding random error to Y(0)
quietly gen error = rnormal(0, 2000)
quietly replace y0 = y0 + error

* Define Y(1) with an ATT of -$5000 for married women in experimental states post-2015
quietly gen 	y1 = y0
quietly replace y1 = y0 - 1000 if experimental == 1 & after == 1

* Treatment effect
quietly gen delta = y1-y0
quietly su delta if after==1 & experimental ==1
quietly local att = r(mean)
quietly scalar att = `att'
quietly gen att=`att'

* Treatment indicator
quietly gen 	treat = 0
quietly replace treat = 1 if experimental == 1 & after==1

* Final earnings using switching equation
quietly gen earnings = treat * y1 + (1 - treat) * y0

* Panel set
quietly xtset city year

* Diff-in-differences
quietly reg earnings experimental##after, robust
quietly local did = _b[1.experimental#1.after]
quietly scalar did=`did'
quietly gen did=`did'


* Matrix completion
quietly fect earnings, treat(treat) unit(city) time(year) method("mc") nlambda(10) se nboots(10) 

quietly mat b=e(ATT)
quietly local mcnn = b[1,1]
quietly scalar mcnn=`mcnn'
quietly gen mcnn=`mcnn'

display "Iteration `i' out of 100 completed"


* Post the results to the results file
post `handle' (`att') (`did') (`mcnn')

}
	
* Close the postfile
postclose `handle'

* Use the results
use results.dta, clear

* bias terms
gen bias_did = did-att 
gen mcnn_did = mcnn-att


kdensity bias_did, xtitle("Bias") title("Bias of Diff-in-Diff estimator") note("ATT was -$1000 and mean bias is -9.31313.") xline(0)

graph export "./figures/did_bias.png", as(png) name("Graph") replace
		

	
kdensity mcnn_did, xtitle("Bias") title("Bias of MCNN estimator") note("ATT was -$1000 and mean bias is -9.313012.") xline(0)

graph export "./figures/mcnn_bias.png", as(png) name("Graph") replace


