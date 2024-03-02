
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![metacran downloads total](https://cranlogs.r-pkg.org/badges/grand-total/LikertMakeR)](https://cran.r-project.org/package=LikertMakeR)
[![metacran downloads last month](https://cranlogs.r-pkg.org/badges/last-month/LikertMakeR)](https://cran.r-project.org/package=LikertMakeR)


# LikertMakeR

Synthesise and correlate rating-scale data with predefined first & second moments (mean and standard deviation)

<p align="center">
  <img src="vignettes/LikertMakeR_2.png" width="250" alt="LikertMakeR logo">
</p>


**_LikertMakeR_** synthesises Likert scale and related rating-scale data. 
Such scales are constrained by upper and lower bounds and discrete increments. 


## Purpose

The package is intended for 

  1. "reproducing" rating-scale data for further analysis and visualisation 
  when only summary statistics have been reported, 
   
  2. teaching. Helping researchers and students to better understand the 
  relationships among scale properties, sample size, number of items, etc.. 

  3. checking the feasibility of scale moments with given scale and 
  correlation properties 


Functions in this development version of **_LikertMakeR_** are:

  -  [**_lfast()_**](#lfast()-&-lfast()) draws repeated random samples from a 
  scaled _Beta_ distribution to approximate predefined first and second moments
  
  -  [**_lexact()_**](#lexact()) attempts to produce a vector with exact 
  predefined first and second moments 

  - [**_lcor()_**](#Correlating-vectors-of-synthetic-rating-scales) 
  rearranges the values in the columns of a dataframe so that 
  they are correlated to match a predefined correlation matrix

  - [**_makeCorrAlpha_**](#Generate-a-correlation-matrix-from-Cronbach's-Alpha)
  constructs a random correlation matrix of given 
  dimensions and predefined Cronbach's Alpha
  
  - [**_makeItems()_**](#Generate-a-dataframe-of-rating-scales-from-a-correlation-matrix-and-predefined-moments) 
  is a wrapper function for _lfast()_ and _lcor_C()_ 
  to generate synthetic rating-scale data with predefined first and second 
  moments and a predefined correlation matrix
  
  - [**_alpha()_**](#alpha()) calculates Cronbach's Alpha from a given 
  correlation matrix or a given dataframe
  
  - [**_eigenvalues()_**](#eigenvalues()) 
  calculates eigenvalues of a correlation matrix, 
  reports on positive-definite status of the matrix and, optionally, 
  displays a scree plot to visualise the eigenvalues

## Rating scale properties

A Likert scale is the mean, or sum, of several ordinal rating scales. 
They are bipolar (usually “agree-disagree”) responses to propositions 
that are determined to be moderately-to-highly correlated and 
capturing various facets of a theoretical construct.
    
Rating scales are not continuous or unbounded. 
    
For example, a 5-point Likert scale that is constructed with, say, 
five items (questions) will have a summed range of between 5 
(all rated ‘1’) and 25 (all rated ‘5’) with all integers in between, 
and the mean range will be ‘1’ to ‘5’ with intervals of 1/5=0.20.
A 7-point Likert scale constructed from eight items will have a 
summed range between 8 (all rated ‘1’) and 56 (all rated ‘7’) with 
all integers in between, and the mean range will be ‘1’ to ‘7’ with 
intervals of 1/8=0.125.


#### Alternative approaches

Typically, a researcher will synthesise rating-scale data by sampling with a predetermined probability distribution. For example, the following code will generate a vector of values for a single Likert-scale item, with approximately the given probabilities. 

          n <- 128
          sample(1:5, n, replace = TRUE,
            prob = c(0.1, 0.2, 0.4, 0.2, 0.1)
          )

This approach is good for testing Likert items but it does not help when 
working on complete Likert scales, or for when we want to specify means 
and standard deviations as they might be reported in published research.  

The functions `lfast()`, `lfast()`, and
   `lexact()` allow the user to specify exact 
univariate statistics as they might ordinarily be reported. 



## Install _LikertMakeR_

To download and install the package, run the following code from your R console.

From __CRAN__:


     install.packages('LikertMakeR')
    

The latest development version is available from the 
author's _GitHub_ repository.


     library(devtools)
     install_github("WinzarH/LikertMakeR")
     

## Generate synthetic rating scales

To synthesise a rating scale, the user must input the following parameters:

-  **_n_**: sample size 
  
-  **_mean_**: desired mean 
  
-  **_sd_**: desired standard deviation
  
-  **_lowerbound_**: desired lower bound
  
-  **_upperbound_**: desired upper bound 
  
-  **_items_**: number of items making the scale. Default&nbsp;=&nbsp;1 
  
-  **_seed_**: optional seed for reproducibility 
  
    
### lfast() 

  -  **_lfast()_** draws repeated random samples from a 
   scaled _Beta_ distribution. 
    It should be accurate to two decimal places.
 
#### _lfast()_ Example: a five-item, seven-point Likert scale

     x <- lfast(
       n = 256, 
       mean = 4.5, sd = 1.0, 
       lowerbound = 1, 
       upperbound = 7, 
       items = 5
       )
     

#### _lfast()_ Example:  an 11-point likelihood-of-purchase scale
 
     x <- lfast(256, 2.5, 2.5, 0, 10)
     
____

## Correlating vectors of synthetic rating scales

**_LikertMakeR_** offers another function, **_lcor()_**, which rearranges 
the values in the columns of a data set so that they are correlated at 
a specified level. 
**_lcor()_** does not change the values - it swaps their positions in each 
column so that univariate statistics do not change, 
but their correlations with other columns do.

To create the desired correlations, the user must define the 
following objects: 

  -  **_data_**: a starter data set of rating-scales 
  
  -  **_target_**: the target correlation matrix 




### **_lcor()_**  Example #1


####  generate synthetic data
     
     set.seed(42) ## for reproducibility
     
     n <- 64
     x1 <- lfast(n, 3.5, 1.00, 1, 5, 5) 
     x2 <- lfast(n, 1.5, 0.75, 1, 5, 5) 
     x3 <- lfast(n, 3.0, 1.70, 1, 5, 5) 
     x4 <- lfast(n, 2.5, 1.50, 1, 5, 5)   
     
     mydat4 <- data.frame(x1, x2, x3, x4) 
     
     head(mydat4)
     cor(mydat4) |> round(3)
     

####  Define a target correlation matrix

     tgt4 <- matrix(
     c(
       1.00, 0.55, 0.60, 0.75,
       0.55, 1.00, 0.25, 0.65,
       0.60, 0.25, 1.00, 0.80,
       0.75, 0.65, 0.80, 1.00
     ),
     nrow = 4
     )
     

####  Apply _lcor()_ to rearrange values in each column achieving desired correlations


##### _lcor()_ application


     new4 <- lcor(data = mydat4, target = tgt4)
     
     cor(new4) |> round(3)



### _lcor()_  example #2


#####  three starting columns and a different target correlation matrix

     mydat3 <- data.frame(x1, x2, x3) 
    
     tgt3 <- matrix(
       c(
          1.00, -0.50, -0.85,
         -0.50,  1.00,  0.60,
         -0.85,  0.60,  1.00
       ),
       nrow = 3
     )
     

##### Apply _lcor()_      


     new3 <- lcor(mydat3, tgt3) 
     
     cor(new3) |> round(3)

____

# Generate a correlation matrix from Cronbach's Alpha

## makeCorrAlpha()

**_makeCorrAlpha()_**, constructs a random correlation matrix of given 
 dimensions and predefined Cronbach's Alpha 

Random values generated by _makeCorrAlpha()_ are volatile.
 _makeCorrAlpha()_ may not generate a feasible (positive-definite)
 correlation matrix, especially when

  * variance is high relative to
  
     * desired Alpha, and
     
     * desired correlation dimensions

_makeCorrAlpha()_ will inform the user if the resulting correlation
 matrix is positive definite, or not.

If the returned correlation matrix is not positive-definite, 
because solutions are so volatile, 
a feasible solution still may be possible, and often is. 
The user is encouraged to try again, possibly several times, to find one.

## _makeCorrAlpha()_ examples


###  four variables, Alpha = 0.85

#### define parameters 

    items <- 4
    alpha <- 0.85
    variance <- 0.5  

#### apply makeCorrAlpha() function

    set.seed(42)
    
    cor_matrix_4 <- makeCorrAlpha(items, alpha, variance)

#### test output with Helper functions

    alpha(cor_matrix_4)
    eigenvalues(cor_matrix_4, 1)

###  four variables, Alpha = 0.90, larger variance

#### define parameters 

    items <- 12
    alpha <- 0.90
    variance <- 1.0

#### apply makeCorrAlpha() function

    set.seed(42) 

    cor_matrix_12 <- makeCorrAlpha(items, alpha, variance)

#### test output

    alpha(cor_matrix_12)
    eigenvalues(cor_matrix_12, 1)

____

## Generate a dataframe of rating scales from a correlation matrix and predefined moments

### makeItems()

**_makeItems()_** generates a dataframe of random discrete
values from a _scaled Beta distribution_ so the data replicate a rating
scale, and are correlated close to a predefined correlation matrix.

_makeItems()_ is a wrapper function for:

 * _lfast()_, which takes repeated samples selecting a vector that
  best fits the desired moments, and
  
 * _lcor()_, which rearranges values in each column of the dataframe
  so they closely match the desired correlation matrix.

### _makeItems()_ examples

#### define parameters

    n <- 16
    lowerbound <- rep(1, 4)
    upperbound <- rep(5, 4)
    
    corMat <- matrix(
    c(
     1.00, 0.25, 0.35, 0.40,
     0.25, 1.00, 0.70, 0.75,
     0.35, 0.70, 1.00, 0.80,
     0.40, 0.75, 0.80, 1.00
     ),
     nrow = 4, ncol = 4
    )

    dfMeans <- c(2.5, 3.0, 3.0, 3.5)
    dfSds <- c(1.0, 1.0, 1.5, 0.75)

#### apply function

    df <- makeItems(
       n = n, 
       lowerbound = lowerbound, 
       upperbound = upperbound, 
       means = dfMeans, 
       sds = dfSds, 
       cormatrix = corMat
       )

#### test function
 
    print(df)
    
    apply(df, 2, mean) |> round(3)
    
    apply(df, 2, sd) |> round(3)
    
    cor(df) |> round(3)

## Helper functions

_likertMakeR()_ includes two additional functions that may be of help 
 when examining parameters and output.

 * **_alpha()_** calculates Cronbach's Alpha from a given correlation 
  matrix or a given dataframe
  
 * **_eigenvalues()_** calculates eigenvalues of a correlation matrix, 
 a report on whether the correlation matrix is positive definite and 
 an optional scree plot

### alpha()

_alpha()_ accepts, as input, either a correlation matrix or a dataframe. 
If both are submitted, then the correlation matrix is used by default, 
with a message to that effect.

### alpha() examples

#### define parameters

##### Sample data frame

    df <- data.frame(
     V1  =  c(4, 2, 4, 3, 2, 2, 2, 1),
     V2  =  c(4, 1, 3, 4, 4, 3, 2, 3),
     V3  =  c(4, 1, 3, 5, 4, 1, 4, 2),
     V4  =  c(4, 3, 4, 5, 3, 3, 3, 3)
    )

##### example correlation matrix

    corMat <- matrix(
     c(
      1.00, 0.35, 0.45, 0.70,
      0.35, 1.00, 0.60, 0.55,
      0.45, 0.60, 1.00, 0.65,
      0.70, 0.55, 0.65, 1.00
     ),
     nrow = 4, ncol = 4
    )

#### apply function examples

    alpha(cormatrix = corMat)

    alpha(NULL, df)

    alpha(corMat, df)

### eigenvalues()

_eigenvalues()_ calculates eigenvalues of a correlation
 matrix, reports on whether the matrix is positive-definite,
 and optionally produces a scree plot.

### eigenvalues() examples

#### define parameters

    correlationMatrix <- matrix(
     c(
      1.00, 0.25, 0.35, 0.40,
      0.25, 1.00, 0.70, 0.75,
      0.35, 0.70, 1.00, 0.80,
      0.40, 0.75, 0.80, 1.00
     ),
     nrow = 4, ncol = 4
    )

#### apply function

    evals <- eigenvalues(cormatrix = correlationMatrix)
 
    print(evals)
 
    evals <- eigenvalues(correlationMatrix, 1)




****

### To cite _LikertMakeR_

Here’s how to cite this package:

     Winzar, H. (2022). LikertMakeR: Synthesise and correlate rating-scale 
    data with predefined first & second moments, 
    The Comprehensive R Archive Network (CRAN),
    <https://CRAN.R-project.org/package=LikertMakeR>
        
#### BIB:    

    @software{winzar2022,
    title = {LikertMakeR: Synthesise and correlate rating-scale data with predefined first & second moments},
    author = {Hume Winzar},
    abstract = {LikertMakeR synthesises Likert scale and related rating-scale data with predefined means and standard deviations, and optionally correlates these vectors to fit a predefined correlation matrix.},
    journal = {The Comprehensive R Archive Network (CRAN)},
    month = {12},
    year = {2022},
    url = {https://CRAN.R-project.org/package=LikertMakeR},
    }
