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




