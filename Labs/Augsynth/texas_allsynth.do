* Name: texas_allsynth.do

* net from https://justinwiltshire.com/s
* net install allsynth, replace
* ssc install distinct
* ssc install elasticregress

* Load Smoking data -- Worse fit
use https://github.com/scunning1975/mixtape/raw/master/synth_smoking.dta, clear

tsset state year

* Define a temporary file to hold the keep results
tempfile allsynth_smoking

* Run allsynth with ridge bias correction, saving to a temporary file
allsynth cigsale ///
    cigsale(1992) cigsale(1991) cigsale(1990) cigsale(1989) ///
    cigsale(1988) cigsale(1987) cigsale(1986) cigsale(1985) ///
    cigsale(1984) cigsale(1983) cigsale(1982) cigsale(1981) ///
    cigsale(1980) cigsale(1979) cigsale(1978) cigsale(1977) ///
    cigsale(1976) cigsale(1975) cigsale(1974) cigsale(1973) ///
    cigsale(1972) cigsale(1971) cigsale(1970), ///
    trunit(3) trperiod(1988) ///
    bcorrect(merge ridge figure) ///
    gapfigure(classic bcorrect lineback) ///
    keep(`allsynth_smoking', replace)

	
* Load Texas data -- perfect fit
use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear

* Declare dataset as a panel
tsset statefip year

* Define a temporary file to hold the keep results
tempfile allsynth_bmprate

* Run allsynth with ridge bias correction, saving to a temporary file
allsynth bmprison ///
    bmprison(1992) bmprison(1991) bmprison(1990) bmprison(1989) ///
    bmprison(1988) bmprison(1987) bmprison(1986) bmprison(1985), ///
    trunit(48) trperiod(1993) ///
    bcorrect(merge ridge figure) ///
    gapfigure(classic bcorrect lineback) ///
    keep(`allsynth_bmprate', replace)
	

	