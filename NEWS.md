
# LikertMakeR 0.4.0 (2024-10-28)

## target Cronbach's Alpha added to makeItemsScale() function 

generated scale items now defined by a target Cronbach's Alpha, 
as well as by variance within each scale item



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




