# Changelog

## LikertMakeR (development version)

## LikertMakeR 1.4.0 (February 2026)

### Improvements

- New
  [`reliability()`](https://winzarh.github.io/LikertMakeR/reference/reliability.md)
  function: Calculates various reliability statistics:

  - Cronbach’s alpha ($`\alpha`$)

  - McDonald’s omega-total ($`\omega_t`$)

  - Guttman’s lambda 6 ($`\lambda 6`$)

  - Zumbo’s ordinal alpha (Cronbach’s alpha from polychoric
    correlations)

  - ordinal-omega-total (McDonald’s omega total from polychoric
    correlations)

  - coefficient H

  with bootstrapped Confidence Intervals for each as an option.

- correlateScales() function runs 3 to 8 times faster

  - due to some pre-calculation and vectorisation replacing “for loops”

### Maintenance

- Fixed typos and simplified examples.

- removed redundant `makeItems()` function

- reduced length of **README** file and moved most content to vignettes

## LikertMakeR 1.3.0 (2025-11-24)

CRAN release: 2025-11-26

### Improvements

- New
  [`makeScalesRegression()`](https://winzarh.github.io/LikertMakeR/reference/makeScalesRegression.md)
  function: Generates synthetic rating-scale data that replicates
  reported regression results, and then returns

  1.  a data frame that provides the requested statistical properties
      and

  2.  a correlation matrix and summary moments of the data frame, plus

  3.  diagnostic statistics, including comparison of target values
      against achieved values.

- [`makeScales()`](https://winzarh.github.io/LikertMakeR/reference/makeScales.md)
  function replaces `makeItems()` function:

  - I finally worked out how to turn a single value into a vector of
    length `k`.
  - Embarrassingly straightforward.

- Updated version of
  [`makeCorrAlpha()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrAlpha.md)
  function produces a more “natural-looking” correlation matrix, plus
  diagnostics:

  - previous version sorted correlations in the correlation matrix to
    improve likelihood of extracting a positive-definite matrix. Fast,
    but unnatural results.
  - I have applied a slightly faster algorithm for rearranging the
    correlations in a draft matrix to produce one that is
    positive-definite.  
  - Additional parameter `sort_cors = FALSE`. If `TRUE`, results are
    similar to the earlier version of
    [`makeCorrAlpha()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrAlpha.md).
    A little faster but not as “natural-looking”.
  - Additional parameter `diagnostics = FALSE`. If `TRUE`, returns a
    list containing the correlation matrix and a diagnostics list
    (target/achieved alpha, average inter-item correlation, eigenvalues,
    PD flag, and key arguments). If `FALSE` (default), returns the
    correlation matrix only.

- Updated version of
  [`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md)
  function

  - runs slightly faster

### Maintenance

- new vignette for the new function
  [`makeScalesRegression()`](https://winzarh.github.io/LikertMakeR/reference/makeScalesRegression.md).

- updated examples for
  [`makeScales()`](https://winzarh.github.io/LikertMakeR/reference/makeScales.md)
  function.

- updated badges in readme file.

## LikertMakeR 1.2.0 (2025-10-10)

CRAN release: 2025-10-09

### Improvements

- New
  [`makeRepeated()`](https://winzarh.github.io/LikertMakeR/reference/makeRepeated.md)
  function : takes summary statistics that are reported in a typical
  repeated-measures ANOVA study, and then returns

  1.  a correlation matrix of the vectors of repeated measures and

  2.  a data frame based on the correlation matrix and summary moments,
      plus

  3.  diagnostic statistics, including possible F-statistics based on
      information provided.

- \#lfast_validation# vignette shows that \#LikertMaker# does a
  remarkably good job of replicating real rating-scale data.

### Maintenance

- Vignettes are too large with so many images, so CRAN files include
  only the \#LikertMakeR_vignette# file. Two vignettes that validate
  [`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md)
  and
  [`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
  appear only in the package website.

## LikertMakeR 1.1.0 (2025-05-26)

CRAN release: 2025-05-30

### Improvements

- new
  [`makePaired()`](https://winzarh.github.io/LikertMakeR/reference/makePaired.md)
  function: takes summary statistics from a paired-sample t-test and
  produces a data frame of rating-scale data that would deliver such
  summary statistics

- [`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md)
  function rewrite: previous version used a very systematic swapping of
  values in each column to minimise the difference between data
  correlation and a target correlation matrix. This algorithm had the
  effect of causing extreme values in each column to be
  highly-correlated (or lowly correlated as applicable), and leaving
  middle-values relatively uncorrelated. This property was probably not
  noticeable in most cases but was apparent when the range of scale
  values was great.

### Maintenance

- Vignettes minor updates.

## LikertMakeR 1.0.2 (2025-04-25)

### Improvements

- Some test examples updated.

### Maintenance

- Vignettes updated.

## LikertMakeR 1.0.1 (2025-04-07)

### Improvements

- Vignettes are now properly registered and included in the build.
- Improved documentation: two vignettes now illustrate package usage:
  - `LikertMakeR vignette`
  - `makeCorrLoadings validation`
- Updated `DESCRIPTION` metadata to comply with CRAN requirements.

### Maintenance

- Switched vignette engine to `knitr::rmarkdown` for better
  compatibility with CRAN and development tools.

## LikertMakeR 1.0.0 (2025-04-03)

CRAN release: 2025-04-04

### makeCorrLoadings() function added

makeCorrLoadings() generates a correlation matrix of inter-item
correlations based on item factor loadings as might be seen in
*Exploratory Factor Analysis* (**EFA**) or a *Structural Equation Model*
(**SEM**).

Such a correlation matrix can be applied to the function to generate
synthetic data with those predefined factor structures.

## LikertMakeR 1.0.0 (2025-01-08)

CRAN release: 2025-04-04

### update version number to correct major.minor.patch format

No update from V 0.4.5.

This will be the new numbered for submission to CRAN

## LikertMakeR 0.4.5 (2025-01-07)

### makePaired() function added

*makePaired()* generates a dataframe of two paired vectors to emulate
data for a paired-sample t-test

## LikertMakeR 0.4.0 (2024-11-17)

CRAN release: 2024-11-19

### target Cronbach’s Alpha added to makeItemsScale() function

generated scale items now defined by a target Cronbach’s Alpha, as well
as by variance within each scale item. This latest version adds a little
randomness to the selection of candidate row vectors.

## LikertMakeR 0.3.0 (2024-05-18)

CRAN release: 2024-05-19

### more randomness in swaps task to makeCorrAlpha() function

correlation matrix usually has values sorted lowest to highest. This
happens less often

## LikertMakeR 0.2.6 (2024-05-11)

### added ‘precision’ parameter to makeCorrAlpha() function

‘precision’ adds random variation around the target Cronbach’s Alpha.
Default = ‘0’ (no variation giving Alpha exact to two decimal places)

## LikertMakeR 0.2.5 (2024-04-20)

### added correlateScales() function

Create a dataframe of correlated scales from different dataframes of
scale items

## LikertMakeR 0.2.2 (2024-03-31)

### added makeItemsScale() function

Generate rating-scale items from a given summated scale

## LikertMakeR 0.2.0 (2024-03-02)

CRAN release: 2024-03-02

### For submission to CRAN

Faster and more accurate functions: ***lcor()*** & ***lfast()***

These replace the old ***lcor()*** & ***lfast()*** with the previous
***lcor_C()*** & ***lfast_R()***

## LikertMakeR 0.1.9 (2024-02-11)

#### Added a new functions: ***makeCorrAlpha()***, ***makeItems()***, *alpha()*, *eigenvalues()*

- *makeCorrAlpha()* constructs a random correlation matrix of given
  dimensions and predefined Cronbach’s Alpha.

- *makeItems()* generates synthetic rating-scale data with predefined
  first and second moments and a predefined correlation matrix

- *alpha()* calculate Cronbach’s Alpha from a given correlation matrix
  or a given dataframe

- *eigenvalues()* calculates eigenvalues of a correlation matrix with an
  optional scree plot

## LikertMakeR 0.1.7 (2024-02-02)

#### Added a new function: ***lcor_C()***

- *lcor_C()* is a C++ implementation of the *lcor()* function. It should
  run considerably faster than *lcor()*. When I’m confident that
  *lcor_C()* works as well or better than *lcor()*, then I shall replace
  *lcor()* with the C++ implementation in an update to CRAN.

## LikertMakeR 0.1.6 (2024-01-18)

- Made code and examples more tidy - this makes code a few nanoseconds
  faster

- Added some further in-line comments.

- setting up for some C++ mods to make lcor() faster, and to introduce
  make_items() function.

## LikertMakeR 0.1.5 (2022-12-20)

CRAN release: 2022-12-22

#### Initial CRAN release

- Added references to DESCRIPTION file and expanded citations to
  vignettes

- Reduced runtime by setting target to zero instead of -Inf.

- Specified one thread instead of attempting Parallel
