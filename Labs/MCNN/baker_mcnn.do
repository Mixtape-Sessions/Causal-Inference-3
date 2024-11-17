* baker_mcnn.do

clear
capture log close

* Load in the baker dataset
use https://github.com/scunning1975/mixtape/raw/master/baker.dta, clear

* drop the after 2003
drop if year>2003

* MCNN with bootstrapping. True ATT is 68.3
fect y, treat(treat) unit(id) time(year) method("mc") cv se

* ATT estimate. SD is the bootstrapped standard error.
mat list e(ATT)

* Event study estimates. SD is the bootstrapped standard error
mat list e(ATTs)


