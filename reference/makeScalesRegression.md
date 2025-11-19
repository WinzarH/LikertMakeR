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
Generated data is verified by running a regression and comparing
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
#> $data
#>    Attitude Intention Behaviour
#> 1      1.50      1.75      1.50
#> 2      3.25      5.00      2.75
#> 3      2.50      2.75      1.50
#> 4      2.50      3.75      4.50
#> 5      3.25      4.00      5.00
#> 6      2.25      3.50      4.25
#> 7      2.25      3.25      3.00
#> 8      1.75      3.50      3.25
#> 9      4.00      3.50      4.75
#> 10     2.50      3.00      3.75
#> 11     4.25      2.25      2.25
#> 12     4.50      3.75      4.50
#> 13     2.00      4.75      2.50
#> 14     2.75      4.75      3.25
#> 15     4.50      3.00      4.75
#> 16     2.25      4.50      4.50
#> 17     1.75      2.75      4.25
#> 18     2.75      3.00      4.50
#> 19     3.00      4.75      5.00
#> 20     4.50      4.00      4.75
#> 21     2.50      2.50      3.00
#> 22     3.50      4.75      5.00
#> 23     1.50      2.00      2.25
#> 24     3.00      2.75      1.75
#> 25     3.50      1.75      3.50
#> 26     3.00      4.50      5.00
#> 27     4.25      3.00      5.00
#> 28     2.75      2.50      2.50
#> 29     1.50      2.25      2.00
#> 30     2.75      1.75      3.00
#> 31     3.25      4.50      5.00
#> 32     1.25      4.75      2.00
#> 33     1.50      3.50      4.00
#> 34     2.75      4.00      4.75
#> 35     3.25      3.25      3.25
#> 36     3.00      3.25      1.75
#> 37     4.50      4.75      4.00
#> 38     3.75      5.00      3.50
#> 39     3.25      4.75      4.75
#> 40     2.25      2.25      3.75
#> 41     4.50      4.00      4.50
#> 42     1.25      3.00      1.75
#> 43     3.25      3.25      4.50
#> 44     4.00      3.75      4.00
#> 45     4.00      4.75      4.50
#> 46     4.50      4.50      4.50
#> 47     2.75      3.25      4.75
#> 48     3.00      3.00      4.75
#> 49     1.50      3.00      4.50
#> 50     3.25      3.75      4.50
#> 51     2.00      2.50      2.50
#> 52     2.75      3.50      4.25
#> 53     2.25      2.75      3.25
#> 54     4.25      4.00      3.25
#> 55     4.00      2.50      3.75
#> 56     4.50      3.75      4.00
#> 57     2.50      5.00      5.00
#> 58     4.50      4.00      5.00
#> 59     3.75      4.00      5.00
#> 60     2.50      3.25      3.50
#> 61     3.25      2.75      5.00
#> 62     3.00      3.00      5.00
#> 63     1.00      3.25      2.25
#> 64     4.75      4.25      5.00
#> 
#> $target_stats
#> $target_stats$beta_std
#> [1] 0.4 0.3
#> 
#> $target_stats$r_squared
#> [1] 0.35
#> 
#> $target_stats$iv_dv_cors
#>  Attitude Intention 
#>      0.49      0.42 
#> 
#> $target_stats$iv_means
#> [1] 3.0 3.5
#> 
#> $target_stats$iv_sds
#> [1] 1.0 0.9
#> 
#> $target_stats$dv_mean
#> [1] 3.8
#> 
#> $target_stats$dv_sd
#> [1] 1.1
#> 
#> $target_stats$iv_cormatrix
#>      [,1] [,2]
#> [1,]  1.0  0.3
#> [2,]  0.3  1.0
#> 
#> 
#> $achieved_stats
#> $achieved_stats$beta_std
#>  Attitude Intention 
#> 0.4000454 0.2995363 
#> 
#> $achieved_stats$r_squared
#> [1] 0.3216508
#> 
#> $achieved_stats$iv_dv_cors
#>  Attitude Intention 
#> 0.4899008 0.4195427 
#> 
#> $achieved_stats$iv_means
#>  Attitude Intention 
#>       3.0       3.5 
#> 
#> $achieved_stats$iv_sds
#>  Attitude Intention 
#> 1.0009916 0.9019379 
#> 
#> $achieved_stats$dv_mean
#> [1] 3.800781
#> 
#> $achieved_stats$dv_sd
#> [1] 1.098502
#> 
#> $achieved_stats$full_cormatrix
#>            Attitude Intention Behaviour
#> Attitude  1.0000000 0.2999819 0.4899008
#> Intention 0.2999819 1.0000000 0.4195427
#> Behaviour 0.4899008 0.4195427 1.0000000
#> 
#> 
#> $diagnostics
#>         Statistic Target  Achieved    Difference   Pct_Error
#> 1   Beta_Attitude   0.40 0.4000454  4.537886e-05  0.01134472
#> 2  Beta_Intention   0.30 0.2995363 -4.636926e-04 -0.15456419
#> 3       R_squared   0.35 0.3216508 -2.834917e-02 -8.09976191
#> 4   r_Attitude_DV   0.49 0.4899008 -9.915414e-05 -0.02023554
#> 5  r_Intention_DV   0.42 0.4195427 -4.573246e-04 -0.10888680
#> 6   Mean_Attitude   3.00 3.0000000  0.000000e+00  0.00000000
#> 7  Mean_Intention   3.50 3.5000000  0.000000e+00  0.00000000
#> 8  Mean_Behaviour   3.80 3.8007812  7.812500e-04  0.02055921
#> 9     SD_Attitude   1.00 1.0009916  9.915719e-04  0.09915719
#> 10   SD_Intention   0.90 0.9019379  1.937949e-03  0.21532764
#> 11   SD_Behaviour   1.10 1.0985016 -1.498416e-03 -0.13621967
#> 
#> $iv_dv_cors
#>  Attitude Intention 
#>      0.49      0.42 
#> 
#> $full_cormatrix
#>           Attitude Intention Behaviour
#> Attitude      1.00      0.30      0.49
#> Intention     0.30      1.00      0.42
#> Behaviour     0.49      0.42      1.00
#> 
#> $optimisation_info
#> NULL
#> 
#> $call
#> makeScalesRegression(n = 64, beta_std = c(0.4, 0.3), r_squared = 0.35, 
#>     iv_cormatrix = iv_corr, iv_means = c(3, 3.5), iv_sds = c(1, 
#>         0.9), dv_mean = 3.8, dv_sd = 1.1, lowerbound_iv = 1, 
#>     upperbound_iv = 5, lowerbound_dv = 1, upperbound_dv = 5, 
#>     items_iv = 4, items_dv = 4, var_names = c("Attitude", "Intention", 
#>         "Behaviour"))
#> 
#> attr(,"class")
#> [1] "makeScalesRegression" "list"                
head(result1$data)
#>   Attitude Intention Behaviour
#> 1     1.50      1.75      1.50
#> 2     3.25      5.00      2.75
#> 3     2.50      2.75      1.50
#> 4     2.50      3.75      4.50
#> 5     3.25      4.00      5.00
#> 6     2.25      3.50      4.25


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
