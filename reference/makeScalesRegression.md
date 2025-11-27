# Generate Data from Multiple-Regression Summary Statistics

Generates synthetic rating-scale data that replicates reported
regression results. This function is useful for reproducing analyses
from published research where only summary statistics (standardised
regression coefficients and R-squared) are reported.

## Usage

``` r
makeScalesRegression(
  n,
  beta_std,
  r_squared,
  iv_cormatrix = NULL,
  iv_cor_mean = 0.3,
  iv_cor_variance = 0.01,
  iv_cor_range = c(-0.7, 0.7),
  iv_means,
  iv_sds,
  dv_mean,
  dv_sd,
  lowerbound_iv,
  upperbound_iv,
  lowerbound_dv,
  upperbound_dv,
  items_iv = 1,
  items_dv = 1,
  var_names = NULL,
  tolerance = 0.005
)
```

## Arguments

- n:

  Integer. Sample size

- beta_std:

  Numeric vector of standardised regression coefficients (length k)

- r_squared:

  Numeric. R-squared from regression (-1 to 1)

- iv_cormatrix:

  k x k correlation matrix of independent variables. If missing (NULL),
  will be optimised.

- iv_cor_mean:

  Numeric. Mean correlation among IVs when optimising (ignored if
  iv_cormatrix provided). Default = 0.3

- iv_cor_variance:

  Numeric. Variance of correlations when optimising (ignored if
  iv_cormatrix provided). Default = 0.01

- iv_cor_range:

  Numeric vector of length 2. Min and max constraints on correlations
  when optimising. Default = c(-0.7, 0.7)

- iv_means:

  Numeric vector of means for IVs (length k)

- iv_sds:

  Numeric vector of standard deviations for IVs (length k)

- dv_mean:

  Numeric. Mean of dependent variable

- dv_sd:

  Numeric. Standard deviation of dependent variable

- lowerbound_iv:

  Numeric vector of lower bounds for each IV scale (or single value for
  all)

- upperbound_iv:

  Numeric vector of upper bounds for each IV scale (or single value for
  all)

- lowerbound_dv:

  Numeric. Lower bound for DV scale

- upperbound_dv:

  Numeric. Upper bound for DV scale

- items_iv:

  Integer vector of number of items per IV scale (or single value for
  all). Default = 1

- items_dv:

  Integer. Number of items in DV scale. Default = 1

- var_names:

  Character vector of variable names (length k+1: IVs then DV)

- tolerance:

  Numeric. Acceptable deviation from target R-squared (default 0.005)

## Value

A list containing:

- data:

  Generated dataframe with k IVs and 1 DV

- target_stats:

  List of target statistics provided

- achieved_stats:

  List of achieved statistics from generated data

- diagnostics:

  Comparison of target vs achieved

- iv_dv_cors:

  Calculated correlations between IVs and DV

- full_cormatrix:

  The complete (k+1) x (k+1) correlation matrix used

- optimisation_info:

  If IV correlations were optimised, details about the optimisation

## Details

Generate regression data from summary statistics

The function can operate in two modes:

**Mode 1: With IV correlation matrix provided**

When `iv_cormatrix` is provided, the function uses the given correlation
structure among independent variables and calculates the implied IV-DV
correlations from the regression coefficients.

**Mode 2: With optimisation (IV correlation matrix not provided)**

When `iv_cormatrix = NULL`, the function optimises to find a plausible
correlation structure among independent variables that matches the
reported regression statistics. Initial correlations are sampled using
Fisher's z-transformation to ensure proper distribution, then
iteratively adjusted to match the target R-squared.

The function generates Likert-scale data (not individual items) using
[`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md)
for each variable with specified moments, then correlates them using
[`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md).
Generated data are verified by running a regression and comparing
achieved statistics with targets.

## See also

[`lfast`](https://winzarh.github.io/LikertMakeR/reference/lfast.md) for
generating individual rating-scale vectors with exact moments.

[`lcor`](https://winzarh.github.io/LikertMakeR/reference/lcor.md) for
rearranging values to achieve target correlations.

[`makeCorrAlpha`](https://winzarh.github.io/LikertMakeR/reference/makeCorrAlpha.md)
for generating correlation matrices from Cronbach's Alpha.

## Examples

``` r
# Example 1: With provided IV correlation matrix
set.seed(123)
iv_corr <- matrix(c(1.0, 0.3, 0.3, 1.0), nrow = 2)

result1 <- makeScalesRegression(
  n = 64,
  beta_std = c(0.4, 0.3),
  r_squared = 0.35,
  iv_cormatrix = iv_corr,
  iv_means = c(3.0, 3.5),
  iv_sds = c(1.0, 0.9),
  dv_mean = 3.8,
  dv_sd = 1.1,
  lowerbound_iv = 1,
  upperbound_iv = 5,
  lowerbound_dv = 1,
  upperbound_dv = 5,
  items_iv = 4,
  items_dv = 4,
  var_names = c("Attitude", "Intention", "Behaviour")
)
#> Warning: Predicted R-squared (0.3220) differs from target (0.3500) by 0.0280,
#>         which exceeds tolerance (0.0050).
#>         
#> Input statistics may be inconsistent.
#> best solution in 397 iterations
#> best solution in 1507 iterations
#> best solution in 162 iterations

print(result1)
#> Regression Data Generation Results
#> ===================================
#> 
#> Sample size: 64 
#> Number of IVs: 2 
#> 
#> IV Correlation Matrix: PROVIDED
#> 
#> Key Statistics:
#> ---------------
#> Target R-squared:   0.3500
#> Achieved R-squared: 0.3217
#> Difference:         -0.0283
#> 
#> Regression Coefficients (Standardised):
#>   Variable Target Achieved   Diff
#>   Attitude    0.4   0.4000  0e+00
#>  Intention    0.3   0.2995 -5e-04
#> 
#> For full diagnostics, see $diagnostics
#> For generated data, see $data
head(result1$data)
#>   Attitude Intention Behaviour
#> 1     2.75      1.75      1.50
#> 2     3.25      4.00      2.75
#> 3     1.75      2.50      2.50
#> 4     2.75      2.25      4.50
#> 5     1.25      3.75      4.50
#> 6     2.50      3.50      3.25


# Example 2: With optimisation (no IV correlation matrix)
set.seed(456)
result2 <- makeScalesRegression(
  n = 128,
  beta_std = c(0.3, 0.25, 0.2),
  r_squared = 0.40,
  iv_cormatrix = NULL, # Will be optimised
  iv_cor_mean = 0.3,
  iv_cor_variance = 0.02,
  iv_means = c(3.0, 3.2, 2.8),
  iv_sds = c(1.0, 0.9, 1.1),
  dv_mean = 3.5,
  dv_sd = 1.0,
  lowerbound_iv = 1,
  upperbound_iv = 5,
  lowerbound_dv = 1,
  upperbound_dv = 5,
  items_iv = 4,
  items_dv = 5
)
#> IV correlation matrix not provided.
#>             
#> Optimising to find plausible structure...
#> Optimisation converged after 7 iterations
#>       
#> (R-sq target: 0.4000, achieved in optimisation: 0.4020)
#> best solution in 5083 iterations
#> best solution in 669 iterations
#> best solution in 1675 iterations
#> best solution in 423 iterations

# View optimised correlation matrix
print(result2$target_stats$iv_cormatrix)
#>           [,1]      [,2]      [,3]
#> [1,] 1.0000000 0.4117389 0.6615179
#> [2,] 0.4117389 1.0000000 0.6832584
#> [3,] 0.6615179 0.6832584 1.0000000
print(result2$optimisation_info)
#> $converged
#> [1] TRUE
#> 
#> $iterations
#> [1] 7
#> 
#> $achieved_r_squared_in_optimisation
#> [1] 0.4019688
#> 
#> $iv_cor_mean_used
#> [1] 0.3
#> 
#> $iv_cor_variance_used
#> [1] 0.02
#> 
#> $iv_cor_range_used
#> [1] -0.7  0.7
#> 
```
