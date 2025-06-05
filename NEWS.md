# LikertMakeR (development version)

# LikertMakeR 1.2.0 (2025-06-05)

## Improvements

- New `makeRepeated()` function : 
   takes summary statistics that are reported in a typical repeated-measures ANOVA study, and then returns 
   
   1. a correlation matrix of the vectors of repeated measures and
   
   2. a data frame based on the correlation matrix and summary moments, plus
   
   - diagnostic statistics, including possible F-statistics based on information provided. 
   

## Maintenance

- Vignettes minor updates.




# LikertMakeR 1.1.0 (2025-05-26)

## Improvements

- `lcor()` function rewrite: 
    previous version used a very systematic swapping of values in each column to minimise the difference between data correlation and a target correlation matrix. This algorithm had the effect of causing extreme values in each column to be highly-correlated (or lowly correlated as applicable), and leaving middle- values relatively uncorrelated. This property was probably not noticeable in most cases but was apparent when the range of scale values was great.

## Maintenance

- Vignettes minor updates.


# LikertMakeR 1.0.2 (2025-04-25)

## Improvements

- Some test examples updated.

## Maintenance

- Vignettes updated.

# LikertMakeR 1.0.1 (2025-04-07)

## Improvements

- Vignettes are now properly registered and included in the build.
- Improved documentation: two vignettes now illustrate package usage:
  - `LikertMakeR vignette`
  - `makeCorrLoadings validation`
- Updated `DESCRIPTION` metadata to comply with CRAN requirements.

## Maintenance

- Switched vignette engine to `knitr::rmarkdown` for better compatibility with CRAN and development tools.

# LikertMakeR 1.0.0 (2025-04-03)

## makeCorrLoadings() function added

makeCorrLoadings() generates a correlation matrix of
inter-item correlations based on item factor loadings as might be seen in
_Exploratory Factor Analysis_ (**EFA**) or a _Structural Equation Model_
(**SEM**).

Such a correlation matrix can be applied to the \code{makeItems()}
function to generate synthetic data with those predefined factor structures.


# LikertMakeR 1.0.0 (2025-01-08)

## update version number to correct major.minor.patch format

No update from V 0.4.5.

This will be the new numbered for submission to CRAN


# LikertMakeR 0.4.5 (2025-01-07)

## makePaired() function added

_makePaired()_ generates a dataframe of two paired vectors to emulate data 
for a paired-sample t-test


# LikertMakeR 0.4.0 (2024-11-17)

## target Cronbach's Alpha added to makeItemsScale() function 

generated scale items now defined by a target Cronbach's Alpha, 
as well as by variance within each scale item.
This latest version adds a little randomness to the selection of 
candidate row vectors.



# LikertMakeR 0.3.0 (2024-05-18)

## more randomness in swaps task to makeCorrAlpha() function

correlation matrix usually has values sorted lowest to highest. This happens less often 



# LikertMakeR 0.2.6 (2024-05-11)

## added 'precision' parameter to makeCorrAlpha() function

'precision' adds random variation around the target Cronbach's Alpha. Default = '0' (no variation giving Alpha exact to two decimal places)




# LikertMakeR 0.2.5 (2024-04-20)

## added correlateScales() function

Create a dataframe of correlated scales  from different dataframes of scale items



# LikertMakeR 0.2.2 (2024-03-31)

## added makeItemsScale() function

Generate rating-scale items from a given summated scale




# LikertMakeR 0.2.0 (2024-03-02)

## For submission to CRAN

Faster and more accurate functions: **_lcor()_** & **_lfast()_**

These replace the old **_lcor()_** & **_lfast()_** with the previous **_lcor_C()_** & **_lfast_R()_**


# LikertMakeR 0.1.9 (2024-02-11)

### Added a new functions: **_makeCorrAlpha()_**, **_makeItems()_**, _alpha()_, _eigenvalues()_

 * _makeCorrAlpha()_ constructs a random correlation matrix of given 
  dimensions and predefined Cronbach's Alpha. 

 * _makeItems()_ generates synthetic rating-scale data with predefined 
  first and second moments and a predefined correlation matrix

 * _alpha()_ calculate Cronbach's Alpha from a given correlation matrix
  or a given dataframe
  
 * _eigenvalues()_ calculates eigenvalues of a correlation matrix with 
  an optional scree plot  


# LikertMakeR 0.1.7 (2024-02-02)

### Added a new function: **_lcor_C()_**

* _lcor_C()_ is a C++ implementation of the _lcor()_ function. 
It should run considerably faster than _lcor()_.
When I'm confident that _lcor_C()_ works as well or better 
than _lcor()_, then I shall replace _lcor()_ with the C++ 
implementation in an update to CRAN. 



# LikertMakeR 0.1.6 (2024-01-18)

* Made code and examples more tidy - this makes code a few nanoseconds faster

* Added some further in-line comments. 

* setting up for some C++ mods to make lcor() faster, and to introduce make_items() function.




# LikertMakeR 0.1.5 (2022-12-20)

### Initial CRAN release

* Added references to DESCRIPTION file and expanded citations to vignettes

* Reduced runtime by setting target to zero instead of -Inf. 

* Specified one thread instead of attempting Parallel




