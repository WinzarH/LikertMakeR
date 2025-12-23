# Package index

## Data Generators

- [`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md)
  : Synthesise rating-scale data with predefined mean and standard
  deviation
- [`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md) :
  Rearrange elements in each column of a data-frame to fit a predefined
  correlation matrix
- [`makeScales()`](https://winzarh.github.io/LikertMakeR/reference/makeScales.md)
  : Synthesise rating-scale data with given first and second moments and
  a predefined correlation matrix
- [`correlateScales()`](https://winzarh.github.io/LikertMakeR/reference/correlateScales.md)
  : Dataframe of correlated scales from different dataframes of scale
  items
- [`makeItemsScale()`](https://winzarh.github.io/LikertMakeR/reference/makeItemsScale.md)
  : Generate scale items from a summated scale, with desired Cronbach's
  Alpha
- [`makePaired()`](https://winzarh.github.io/LikertMakeR/reference/makePaired.md)
  : Synthesise a dataset from paired-sample t-test summary statistics
- [`makeRepeated()`](https://winzarh.github.io/LikertMakeR/reference/makeRepeated.md)
  : Reproduce Repeated-Measures Data from ANOVA Summary Statistics
- [`makeScalesRegression()`](https://winzarh.github.io/LikertMakeR/reference/makeScalesRegression.md)
  : Generate Data from Multiple-Regression Summary Statistics

## Correlation matrices

- [`makeCorrAlpha()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrAlpha.md)
  : Correlation matrix from Cronbach's Alpha
- [`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
  : Generate Inter-Item Correlation Matrix from Factor Loadings
- [`print(`*`<makeScalesRegression>`*`)`](https://winzarh.github.io/LikertMakeR/reference/print.makeScalesRegression.md)
  : Print method for makeScalesRegression objects

## Helper functions

- [`alpha()`](https://winzarh.github.io/LikertMakeR/reference/alpha.md)
  : Calculate Cronbach's Alpha from a correlation matrix or dataframe
- [`eigenvalues()`](https://winzarh.github.io/LikertMakeR/reference/eigenvalues.md)
  : calculate eigenvalues of a correlation matrix with optional scree
  plot
- [`reliability()`](https://winzarh.github.io/LikertMakeR/reference/reliability.md)
  : Estimate scale reliability for Likert and rating-scale data
- [`ordinal_diagnostics()`](https://winzarh.github.io/LikertMakeR/reference/ordinal_diagnostics.md)
  : Extract ordinal diagnostics from a reliability() result

## Deprecated functions

- [`lexact()`](https://winzarh.github.io/LikertMakeR/reference/lexact.md)
  : Deprecated. Use lfast() instead
