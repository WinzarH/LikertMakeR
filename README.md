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
  *  ___lfast___ draws a random sample from a scaled _Beta_ distribution. It is very fast but gives no guarantee that the mean and standard deviation are exact. Recommended for relatively large sample sizes.
  
  > ###### Example
  > a five-item, seven-point Likert scale
  > ```
  > x <- lfast(n = 256, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5)
  > ```
  >  ###### Example
  > an 11-point likelihood of purchase scale
  > ```
  > x <- lfast(256, 2, 1.8, 0, 10, seed = 42)
  > ```
  
  *  ___lexact___ attempts to produce a vector with exact first and second moments. It uses the _Differential Evolution_ algorithm in the ___DEoptim___ package to find appropriate values within the desired constraints. 
___lexact___ can take some time to complete the optimisation task, but is excellent for simulating data from already-published reports where only summary statistics are reported. 
  
  > ###### Example
  > a five-item, seven-point Likert scale
  > ```
  > x <- lexact(n = 64, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5)
  > ```
  >  ###### Example
  > an 11-point likelihood of purchase scale
  > ```
  > x <- lexact(128, 2, 1.8, 0, 10, seed = 42)
  > ```
  >  ###### Example
  > a seven-point negative-to-positive scale with 6 items
  > ```
  > x <- lexact(n = 64, mean = 1.2, sd = 1.00, lowerbound = -3, upperbound = 3, items = 6)
  > ```
  

  
## Correlating vectors of synthetic rating scales

___LikertMakeR___ offers another function, ___lcor___, which rearranges the values in the columns of a data set so that they are correlated at a specified level. It does not change the values - it swaps their positions in a column so that univariate statistics do not change, but their correlations with other vectors do.

To create the desired correlations, the user must define the following data-frames:
  -  ___data___: a starter data set of rating-scales 
  -  ___target___: the target correlation matrix 

## Examples

####  generate synthetic data

```

set.seed(42) # for reproducibility

x1 <- lexact(64, 3.5, 1.0, 1, 5, 5);
x2 <- lexact(64, 1.5, 0.75, 1, 5, 5);
x3 <- lexact(64, 3.0, 2.0, 1, 5, 5);
x4 <- lexact(64, 2.5, 1.5, 1, 5, 10);  

mydat4 <- cbind(x1, x2, x3, x4) |> 
    data.frame()
cor(mydat4)

```

####  Define a target correlation matrix

```
tgt4 <- matrix(
c(
  1.00, 0.50, 0.50, 0.75,
  0.50, 1.00, 0.25, 0.65,
  0.50, 0.25, 1.00, 0.80,
  0.75, 0.65, 0.80, 1.00
),
nrow = 4
)

```

####  Rearrange values in each column to achieve desired correlations

```
new4 <- lcor(data = mydat4, target = tgt4);
cor(new4)

```

####  Same starting values with a different target correlation matrix

```

mydat3 <- cbind(x1, x2, x3) |> data.frame()

tgt3 <- matrix(
  c(
    1.00, 0.50, 0.95,
    0.50, 1.00, 0.65,
    0.95, 0.65, 1.00
  ),
  nrow = 3
)
cor(mydat3)

new3 <- lcor(mydat3, tgt3)
cor(new3)
```

####  And another target correlation matrix

```
tgt3 <- matrix(
  c(
     1.00, -0.50, -0.85,
    -0.50,  1.00,  0.60,
    -0.85,  0.60,  1.00
  ),
  nrow = 3
)

new3 <- lcor(mydat3, tgt3)
cor(new3)

```
"A line from my own computer" 
