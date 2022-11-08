# LikertMakeR

___LikertMakeR___ synthesises Likert scale and related rating-scale data. Such scales are constrained by upper and lower bounds and discrete increments. For example, a likelihood-of-purchase scale may be an 11-point, zero-to-10 rating scale.

 A Likert scale is the mean, or sum, of several ordinal rating scales. They are bipolar (usually “agree-disagree”) responses to propositions that are determined to be moderately-to-highly correlated and capturing various facets of a construct.
    
Rating scales are not continuous or unbounded. 
    
For example, a 5-point Likert scale that is constructed with, say, five items (questions) will have a summed range of between 5 (all rated ‘1’) and 25 (all rated ‘5’) with all integers in between, and 
the mean range will be ‘1’ to ‘5’ with intervals of 1/5=0.20.
A 7-point Likert scale constructed from eight items will have a summed range between 8 (all rated ‘1’) and 56 (all rated ‘7’) with all integers in between, 
and the mean range will be ‘1’ to ‘7’ with intervals of 1/8=0.125.

### Generating synthetic rating scales

To synthesise a rating scale, the user must input the following parameters:
  *  ___n___: sample size 
  *  ___mean___: desired mean 
  *  ___sd___: desired standard deviation
  *  ___lowerbound___: desired lower bound
  *  ___upperbound___: desired upper bound 
  *  ___items___: number of items making the scale - default is 1 
  *  ___seed___: optional seed for reproducibility
    
___LikertMakeR___ offers two different functions for synthesising a rating scale: 
  *  ___lbeta___ draws a random sample from a scaled Beta distribution. It is very fast but gives no guarantee that the mean and standard deviation are exact. Recommended for relatively large sample sizes.
  *  ___lexact___ attempts to produce a vector with exact first and second moments. It uses the (Differential Evolution) algorithm in the ___DEoptim___ package to find appropriate values within the desired constraints. 
___lexact___ can take some time to complete the optimisation task, but is excellent for simulating data from already-published reports where only summary statistics are reported. 

### Correlating vectors of synthetic rating scales

___LikertMakeR___ offers another function, ___lcor___, which rearranges the values in the columns of a data set so that they are correlated at a specified level. It does not change the values - it swaps their positions in a column so that univariate statistics do not change, but their correlations with other vectors do.

To create the desired correlations, the user must define the following data-frames:
  *  ___data___: a starter data set of rating-scales 
  *  ___target_cor___: the target correlation matrix 
  *  ___runs___: optional parameter to increase the number iterations to find an optimal solution. Default = 1. If the correlation matrix is at the edge of feasible, then this *may* improve fit.
