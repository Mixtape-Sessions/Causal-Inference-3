# Synthetic Control Lab

The asks you to estimate causal effects using synthetic control methods including performing inference as described in Abadie, Diamond and Hainmueller (2010). This exercise is based on an illustrating example of a Texas natural experiment in which the state signiﬁcantly expanded its prison capacity by the building of new prisons andexpansion of prison capacity on old prisons in 1993 (Cornwell and Cunningham, 2016).

Texas expanded its operational capacity in prisons starting in 1993. For three years – 1993, 1994, 1995 – operational capacity expanded 35% per year causing its overall operational capacity to approximately double in three years. This expansion is described in more detail in Cornwell and Cunningham (2016) and Perkinson (2010). We use the 1993-1995 expansion as a natural experiment to examine the effect of prison expansion on incarceration rates.

## Data

The data is contained in `texas.dta`. You can load this in R with `haven::read_dta`. The main variable of interest are `state`, `year`, and `bmprison`. The later is the outcome of interest and is the number of Black males in prison in the given state-year.

## Exercises

Follow these steps to complete the assignment:
  1. Load the data
	2. Create a new variable called 'treated'. Assign a value of 1 to 'treated' if the state is 'Texas' and the year is greater than or equal to 1993, otherwise assign 0.
	3.	Estimate a standard synthetic control estimator. In stata, this can be done using the `synth` function. In R, I recommend the `augsynth` package and the corresponding `augsynth()` function. Make sure to pass the options `progfunc = "None", scm = T` to the function call. 
  4. Plot the results. In stata, this should be done automatically with the `synth` function. In R, use `plot(est, inf_type = "jackknife+")` where `est` is the object returned by `augsynth()`.
  5. Now, we will perform placebo-based inference. This requires a for loop where we one-by-one assign each control state to be the "placebo" treated state and reestimate our synthetic control. Do this for each state and store the treatment effect estimates in a big dataset keeping track of the state. It should have columns `state`, `year`, `te_hat`.
  6. Plot each placebo estimate in grey and the Texas treatment effect estimate in purple. Does the result seem to be statistically significant using the placebo estimates?

  7. *Bonus* Try using the `scpi` package to estimate a synthetic control that places a LASSO and/or a Ridge penalty on the synthetic control weights. How do the results compare to the standard synthetic control estimator?
  8. *Bonus* Try the augmented synthetic-control method using the `augsynth` package (`R` only unfortunately). Use the following as covariates: `poverty + income + alcohol + aidscapita + black + perc1519`. How do the results compare to the standard synthetic control estimator? Explain why this result may be preferred by a researcher. 
