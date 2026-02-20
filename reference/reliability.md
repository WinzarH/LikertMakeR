# Estimate scale reliability for Likert and rating-scale data

Computes internal consistency reliability estimates for a single-factor
scale, including Cronbach’s alpha, McDonald’s omega (total), and
optional ordinal (polychoric-based) variants. Confidence intervals may
be obtained via nonparametric bootstrap.

## Usage

``` r
reliability(
  data,
  include = "none",
  ci = FALSE,
  ci_level = 0.95,
  n_boot = 1000,
  na_method = c("pairwise", "listwise"),
  min_count = 2,
  digits = 3,
  verbose = TRUE
)
```

## Arguments

- data:

  A data frame or matrix containing item responses. Each column
  represents one item; rows represent respondents.

- include:

  Character vector specifying which additional estimates to compute.
  Possible values are:

  - `"none"` (default): Pearson-based alpha and omega only.

  - `"lambda6"`: Include Guttman’s lambda-6 (requires package psych).

  - `"polychoric"`: Include ordinal (polychoric-based) alpha and omega.

  Multiple options may be supplied.

- ci:

  Logical; if `TRUE`, confidence intervals are computed using
  nonparametric bootstrap. Default is `FALSE`.

- ci_level:

  Confidence level for bootstrap intervals. Default is `0.95`.

- n_boot:

  Number of bootstrap resamples used when `ci = TRUE`. Default is
  `1000`.

- na_method:

  Method for handling missing values. Either `"pairwise"` (default) or
  `"listwise"`.

- min_count:

  Minimum observed frequency per response category required to attempt
  polychoric correlations. Ordinal reliability estimates are skipped if
  this condition is violated. Default is `2`.

- digits:

  Number of decimal places used when printing estimates. Default is `3`.

- verbose:

  Logical; if `TRUE`, warnings and progress indicators are displayed.
  Default is `TRUE`.

## Value

A tibble with one row per reliability coefficient and columns:

- `coef_name`: Name of the reliability coefficient.

- `estimate`: Point estimate.

- `ci_lower`, `ci_upper`: Confidence interval bounds (only present when
  `ci = TRUE`).

- `notes`: Methodological notes describing how the estimate was
  obtained.

The returned object has class `"likert_reliability"` and includes
additional attributes containing diagnostics and bootstrap information.

## Details

The function is designed for Likert-type and rating-scale data and
prioritises transparent diagnostics when ordinal reliability estimates
are not feasible due to sparse response categories.

Cronbach’s alpha and McDonald’s omega are computed from Pearson
correlations. When `include = "polychoric"`, ordinal reliability
estimates are computed using polychoric correlations and correspond to
Zumbo’s alpha and ordinal omega.

Ordinal reliability estimates are skipped if response categories are
sparse or if polychoric estimation fails. Diagnostics explaining these
decisions are stored in the returned object and may be inspected using
[`ordinal_diagnostics`](https://winzarh.github.io/LikertMakeR/reference/ordinal_diagnostics.md).

This function assumes a single common factor and is not intended for
multidimensional or structural equation modelling contexts.

## See also

[`ordinal_diagnostics`](https://winzarh.github.io/LikertMakeR/reference/ordinal_diagnostics.md)

## Examples

``` r
## create dataset
my_cor <- LikertMakeR::makeCorrAlpha(
  items = 4,
  alpha = 0.80
)
#> reached max iterations (1600) - best mean difference: 1.1e-05

my_data <- LikertMakeR::makeScales(
  n = 64,
  means = c(2.75, 3.00, 3.25, 3.50),
  sds = c(1.25, 1.50, 1.30, 1.25),
  lowerbound = rep(1, 4),
  upperbound = rep(5, 4),
  cormatrix = my_cor
)
#> Variable  1 :  item01  - 
#> reached maximum of 4096 iterations
#> Variable  2 :  item02  - 
#> best solution in 2657 iterations
#> Variable  3 :  item03  - 
#> reached maximum of 4096 iterations
#> Variable  4 :  item04  - 
#> reached maximum of 4096 iterations
#> 
#> Arranging data to match correlations
#> 
#> Successfully generated correlated variables
#> 

## run function
reliability(my_data)
#>    coef_name estimate n_items n_obs                notes
#>        alpha    0.801       4    64 Pearson correlations
#>  omega_total    0.872       4    64 1-factor eigen omega

reliability(
  my_data,
  include = c("lambda6", "polychoric")
)
#>            coef_name estimate n_items n_obs
#>                alpha    0.801       4    64
#>          omega_total    0.872       4    64
#>              lambda6    0.797       4    64
#>        ordinal_alpha    0.756       4    64
#>  ordinal_omega_total    0.846       4    64
#>                                                notes
#>                                 Pearson correlations
#>                                 1-factor eigen omega
#>                                       psych::alpha()
#>                              Polychoric correlations
#>  Polychoric correlations | Ordinal CIs not requested

# \donttest{
## slower (not run on CRAN checks)
reliability(
  my_data,
  include = "polychoric",
  ci = TRUE,
  n_boot = 200
)
#>   |                                                                              |                                                                      |   0%  |                                                                              |==                                                                    |   2%  |                                                                              |====                                                                  |   5%  |                                                                              |=====                                                                 |   8%  |                                                                              |=======                                                               |  10%  |                                                                              |=========                                                             |  12%  |                                                                              |==========                                                            |  15%  |                                                                              |============                                                          |  18%  |                                                                              |==============                                                        |  20%  |                                                                              |================                                                      |  22%  |                                                                              |==================                                                    |  25%  |                                                                              |===================                                                   |  28%  |                                                                              |=====================                                                 |  30%  |                                                                              |=======================                                               |  32%  |                                                                              |========================                                              |  35%  |                                                                              |==========================                                            |  38%  |                                                                              |============================                                          |  40%  |                                                                              |==============================                                        |  42%  |                                                                              |================================                                      |  45%  |                                                                              |=================================                                     |  48%  |                                                                              |===================================                                   |  50%  |                                                                              |=====================================                                 |  52%  |                                                                              |======================================                                |  55%  |                                                                              |========================================                              |  58%  |                                                                              |==========================================                            |  60%  |                                                                              |============================================                          |  62%  |                                                                              |==============================================                        |  65%  |                                                                              |===============================================                       |  68%  |                                                                              |=================================================                     |  70%  |                                                                              |===================================================                   |  72%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================                |  78%  |                                                                              |========================================================              |  80%  |                                                                              |==========================================================            |  82%  |                                                                              |============================================================          |  85%  |                                                                              |=============================================================         |  88%  |                                                                              |===============================================================       |  90%  |                                                                              |=================================================================     |  92%  |                                                                              |==================================================================    |  95%  |                                                                              |====================================================================  |  98%  |                                                                              |======================================================================| 100%
#>            coef_name estimate ci_lower ci_upper n_items n_obs
#>                alpha    0.801    0.693    0.861       4    64
#>          omega_total    0.872    0.817    0.906       4    64
#>        ordinal_alpha    0.756    0.571    0.822       4    64
#>  ordinal_omega_total    0.846    0.758    0.883       4    64
#>                                                notes
#>                                 Pearson correlations
#>                                 1-factor eigen omega
#>                              Polychoric correlations
#>  Polychoric correlations | Ordinal CIs via bootstrap
# }
```
