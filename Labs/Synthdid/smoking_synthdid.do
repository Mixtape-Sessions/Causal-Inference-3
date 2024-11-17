* smoking_synthdid.do

capture log close
clear

global link "https://raw.githubusercontent.com/synth-inference/synthdid/"
import delimited "$link/master/data/california_prop99.csv", clear delim(";")
sdid packspercapita state year treated, vce(placebo) seed(123) reps(50) graph graph_export(sdid_, .eps) g1_opt(xtitle(""))

