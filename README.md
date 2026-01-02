
<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![metacran downloads total](https://cranlogs.r-pkg.org/badges/grand-total/LikertMakeR)](https://cran.r-project.org/package=LikertMakeR)
[![metacran downloads last month](https://cranlogs.r-pkg.org/badges/last-month/LikertMakeR)](https://cran.r-project.org/package=LikertMakeR)
[![R-CMD-check](https://github.com/WinzarH/LikertMakeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/WinzarH/LikertMakeR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/WinzarH/LikertMakeR/actions/workflows/pkgdown.yml/badge.svg?branch=main)](https://winzarh.github.io/LikertMakeR/)
[![GitHub stars](https://img.shields.io/github/stars/WinzarH/LikertMakeR.svg?style=social&label=Star)](https://github.com/WinzarH/LikertMakeR)
<!-- badges: end -->

# LikertMakeR <img src="man/figures/logo.png" align="right" height="134" alt="LikertMakeR" />

**LikertMakeR** synthesises Likert-scale and related bounded rating-scale data with
predefined *means*, *standard deviations*, and (optionally) *correlations*, *Cronbach’s alpha*, and *factor-loading-based structure*.

## Purpose

1. *Reverse-engineer* published results when only summary statistics are reported (for re-analysis, visualisation, or teaching).
2. *Teaching & demos*: generate data with known properties without collecting real data.
3. *Methods work / simulation*: explore how reliability, items, bounds, and sample size interact.

For a full introduction and worked examples, see the package website:
<https://winzarh.github.io/LikertMakeR/>

---

## Installation

From **_CRAN_**:

```r

  install.packages("LikertMakeR")
```

The latest development version is available from the 
author's **_GitHub_** repository.
     
```r  

 library(devtools)
 
 install_github("WinzarH/LikertMakeR")
```     
     
## Quick Start

1. Make a target correlation matrix

```r
library(LikertMakeR)

R <- matrix(
  c(
    1.00, 0.60, 0.45, 0.40,
    0.60, 1.00, 0.75, 0.35,
    0.45, 0.75, 1.00, 0.50,
    0.40, 0.35, 0.50, 1.00
  ),
  nrow = 4, ncol = 4, byrow = TRUE
)
```    

2. Generate synthetic rating-scale data with predefined moments

```r
dat <- makeScales(
  n = 64,
  means = c(2.75, 3.00, 3.25, 3.50),
  sds = c(1.25, 1.50, 1.30, 1.25),
  lowerbound = rep(1, 4),
  upperbound = rep(5, 4),
  items = c(5, 5, 4, 4),
  cormatrix = R
)

head(dat)
cor(dat) |> round(2)
```    

## Key functions

  - `lfast()`: generate bounded/discrete data with target mean & SD

  - `lcor()`: rearrange columns to approximate a target correlation matrix

  - `makeCorrAlpha()`: generate an item correlation matrix with target Cronbach’s alpha

  - `makeScales()`: wrapper for lfast() + lcor() to generate a dataframe of correlated columns

  - `makeCorrLoadings()`: build an item correlation matrix from factor loadings and factor correlations

  - `makeItemsScale()`: generate items from a summated scale with target alpha

  - `makePaired()` / `makeRepeated()`: reconstruct data from paired t-test / repeated-measures summaries

  - `makeScalesRegression()`: generate data from summary of multiple-regression analysis

  - `correlateScales()`: combine multiple item sets so summated scales match a target correlation matrix

  - Helpers: `alpha()`, `eigenvalues()`, `reliability()`

  
## Rating scale properties

A Likert scale is the mean, or sum, of several ordinal rating scales. 
They are bipolar (usually “agree-disagree”) responses to propositions 
that are determined to be moderately-to-highly correlated among each other, 
and capturing various facets of a theoretical construct.

> ### NOTE   
> A single 1-5 rating scale is **_NOT_** a Likert scale - it may be a Likert-scale item.
    
Summated rating scales are not continuous or unbounded.
For example, a 5-point Likert scale that is constructed with, say, 
five items (questions) will have a summed range of between 5 
(all rated ‘1’) and 25 (all rated ‘5’) with all integers in between, 
and the mean range will be ‘1’ to ‘5’ with intervals of 1/5=0.20.
A 7-point Likert scale constructed from eight items will have a 
summed range between 8 (all rated ‘1’) and 56 (all rated ‘7’) with 
all integers in between, and the mean range will be ‘1’ to ‘7’ with 
intervals of 1/8=0.125.


## Learn more

Package website (recommended): https://winzarh.github.io/LikertMakeR/

Vignettes cover:

  - generating scales from summary statistics,

  - correlation matrices from alpha or loadings,

  - repeated-measures and paired designs,

  - reliability estimation and diagnostics,
  
  - validation studies demonstrating function accuracy. 
  
____


### To cite _LikertMakeR_

#### APA:

     Winzar, H. (2025). LikertMakeR (version 1.4.0) [R package]. 
     The Comprehensive R Archive Network (CRAN),
    <https://CRAN.R-project.org/package=LikertMakeR>
        
#### BIB:    

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
