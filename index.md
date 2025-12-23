# LikertMakeR

**LikertMakeR** synthesises Likert-scale and related bounded
rating-scale data with predefined *means*, *standard deviations*, and
(optionally) *correlations*, *Cronbach’s alpha*, and
*factor-loading-based structure*.

## Purpose

1.  *Reverse-engineer* published results when only summary statistics
    are reported (for re-analysis, visualisation, or teaching).
2.  *Teaching & demos*: generate data with known properties without
    collecting real data.
3.  *Methods work / simulation*: explore how reliability, items, bounds,
    and sample size interact.

For a full introduction and worked examples, see the package website:
<https://winzarh.github.io/LikertMakeR/>

------------------------------------------------------------------------

## Installation

From ***CRAN***:

``` r

  install.packages("LikertMakeR")
```

The latest development version is available from the author’s
***GitHub*** repository.

``` r

 library(devtools)
 
 install_github("WinzarH/LikertMakeR")
```

## Quick Start

1.  Make a target correlation matrix from desired Cronbach’s alpha

``` r

library(LikertMakeR)

R <- makeCorrAlpha(items = 4, alpha = 0.80)
    
R
```

2.  Generate synthetic rating-scale data with predefined moments

``` r

dat <- makeScales(
  n = 64,
  means = c(2.75, 3.00, 3.25, 3.50),
  sds   = c(1.25, 1.50, 1.30, 1.25),
  lowerbound = rep(1, 4),
  upperbound = rep(5, 4),
  items = 4,
  cormatrix = R
)

head(dat)
cor(dat) |> round(2)
```

## Key functions

- [`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md):
  generate bounded/discrete data with target mean & SD

- [`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md):
  rearrange columns to approximate a target correlation matrix

- [`makeCorrAlpha()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrAlpha.md):
  generate an item correlation matrix with target Cronbach’s alpha

- [`makeScales()`](https://winzarh.github.io/LikertMakeR/reference/makeScales.md):
  wrapper for lfast() + lcor() to generate full datasets

- [`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md):
  build an item correlation matrix from factor loadings (and factor
  correlations)

- [`makeItemsScale()`](https://winzarh.github.io/LikertMakeR/reference/makeItemsScale.md):
  generate items from a summated scale with target alpha

- [`makePaired()`](https://winzarh.github.io/LikertMakeR/reference/makePaired.md)
  /
  [`makeRepeated()`](https://winzarh.github.io/LikertMakeR/reference/makeRepeated.md):
  reconstruct data from paired t-test / repeated-measures summaries

- [`makeScalesRegression()`](https://winzarh.github.io/LikertMakeR/reference/makeScalesRegression.md):
  generate data that reproduce regression summaries

- [`correlateScales()`](https://winzarh.github.io/LikertMakeR/reference/correlateScales.md):
  combine multiple item sets so summated scales match a target
  correlation matrix

- Helpers:
  [`alpha()`](https://winzarh.github.io/LikertMakeR/reference/alpha.md),
  [`eigenvalues()`](https://winzarh.github.io/LikertMakeR/reference/eigenvalues.md),
  [`reliability()`](https://winzarh.github.io/LikertMakeR/reference/reliability.md)

## Learn more

Package website (recommended): <https://winzarh.github.io/LikertMakeR/>

Vignettes cover:

- generating scales from summary statistics,

- correlation matrices from alpha or loadings,

- repeated-measures and paired designs,

- reliability estimation and diagnostics,

- validation studies demonstrating function accuracy.

------------------------------------------------------------------------

### To cite *LikertMakeR*

#### APA:

``` R
 Winzar, H. (2025). LikertMakeR (version 1.4.0) [R package]. 
 The Comprehensive R Archive Network (CRAN),
<https://CRAN.R-project.org/package=LikertMakeR>
    
```

#### BIB:

``` R
@software{winzar2025},
 title = {LikertMakeR},
 author = {Winzar, Hume},
 abstract = {LikertMakeR synthesises and correlates rating-scale data with predefined means and standard deviations.},
 publisher = {The Comprehensive R Archive Network (CRAN)},
 month = dec,
 year = {2025},
 version = {1.4.0},
 origdate = {2022},
 url = {https://CRAN.R-project.org/package=LikertMakeR},
 note = {R package}
}
```
