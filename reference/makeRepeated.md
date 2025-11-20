# Reproduce Repeated-Measures Data from ANOVA Summary Statistics

Constructs a synthetic dataset and inter-timepoint correlation matrix
from a repeated-measures ANOVA result, based on reported means, standard
deviations, and an F-statistic. This is useful when only summary
statistics are available from published studies.

## Usage

``` r
makeRepeated(
  n,
  k,
  means,
  sds,
  f_stat,
  df_between = k - 1,
  df_within = (n - 1) * (k - 1),
  structure = c("cs", "ar1", "toeplitz"),
  names = paste0("time_", 1:k),
  items = 1,
  lowerbound = 1,
  upperbound = 5,
  return_corr_only = FALSE,
  diagnostics = FALSE,
  ...
)
```

## Arguments

- n:

  Integer. Sample size used in the original study.

- k:

  Integer. Number of repeated measures (timepoints).

- means:

  Numeric vector of length `k`. Mean values reported for each timepoint.

- sds:

  Numeric vector of length `k`. Standard deviations reported for each
  timepoint.

- f_stat:

  Numeric. The reported repeated-measures ANOVA F-statistic for the
  within-subjects factor.

- df_between:

  Degrees of freedom between conditions (default: `k - 1`.

- df_within:

  Degrees of freedom within-subjects (default: `(n - 1) * (k - 1)`).

- structure:

  Character. Correlation structure to assume: `"cs"`, `"ar1"`, or
  `"toeplitz"` (default = `"cs"`).

- names:

  Character vector of length `k`. Variable names for each timepoint
  (default: `"time_1"` to `"time_k"`).

- items:

  Integer. Number of items used to generate each scale score (passed to
  [lfast](https://winzarh.github.io/LikertMakeR/reference/lfast.md)).

- lowerbound, :

  Integer. Lower bounds for Likert-type response scales (default: 1).

- upperbound, :

  Integer. upper bounds for Likert-type response scales (default: 5).

- return_corr_only:

  Logical. If `TRUE`, return only the estimated correlation matrix.

- diagnostics:

  Logical. If `TRUE`, include diagnostic summaries such as feasible
  F-statistic range and effect sizes.

- ...:

  Reserved for future use.

## Value

A named list with components:

- `data`:

  A data frame of simulated repeated-measures responses (unless
  `return_corr_only = TRUE`).

- `correlation_matrix`:

  The estimated inter-timepoint correlation matrix.

- `structure`:

  The correlation structure assumed.

- `achieved_f`:

  The F-statistic produced by the estimated `rho` value (if
  `diagnostics = TRUE`).

- `feasible_f_range`:

  Minimum and maximum achievable F-values under the chosen structure
  (shown if diagnostics are requested).

- `recommended_f`:

  Conservative, moderate, and strong F-statistic suggestions for similar
  designs.

- `effect_size_raw`:

  Unstandardised effect size across timepoints.

- `effect_size_standardised`:

  Effect size standardised by average variance.

## Details

This function estimates the average correlation between repeated
measures by matching the reported F-statistic, under one of three
assumed correlation structures:

- `"cs"` (*Compound Symmetry*): The Default. Assumes all timepoints are
  equally correlated. Common in standard RM-ANOVA settings.

- `"ar1"` (*First-Order Autoregressive*): Assumes correlations decay
  exponentially with time lag.

- `"toeplitz"` (*Linearly Decreasing*): Assumes correlation declines
  linearly with time lag - a middle ground between `"cs"` and `"ar1"`.

The function then generates a data frame of synthetic item-scale ratings
using [lfast](https://winzarh.github.io/LikertMakeR/reference/lfast.md),
and adjusts them to match the estimated correlation structure using
[lcor](https://winzarh.github.io/LikertMakeR/reference/lcor.md).

Set `return_corr_only = TRUE` to extract only the estimated correlation
matrix.

## See also

[`lfast`](https://winzarh.github.io/LikertMakeR/reference/lfast.md),
[`lcor`](https://winzarh.github.io/LikertMakeR/reference/lcor.md)

## Examples

``` r
set.seed(42)

out1 <- makeRepeated(
  n = 64,
  k = 3,
  means = c(3.1, 3.5, 3.9),
  sds = c(1.0, 1.1, 1.0),
  items = 4,
  f_stat = 4.87,
  structure = "cs",
  diagnostics = FALSE
)
#> best solution in 1837 iterations
#> best solution in 492 iterations
#> best solution in 2136 iterations

head(out1$data)
#>   time_1 time_2 time_3
#> 1   4.00   4.75   3.25
#> 2   1.50   4.75   3.50
#> 3   2.75   4.25   3.75
#> 4   3.25   4.25   4.00
#> 5   3.00   3.50   5.00
#> 6   2.75   2.50   4.25
out1$correlation_matrix
#>            time_1     time_2     time_3
#> time_1  1.0000000 -0.3100743 -0.3100743
#> time_2 -0.3100743  1.0000000 -0.3100743
#> time_3 -0.3100743 -0.3100743  1.0000000

out2 <- makeRepeated(
  n = 32, k = 4,
  means = c(2.75, 3.5, 4.0, 4.4),
  sds = c(0.8, 1.0, 1.2, 1.0),
  f_stat = 16,
  structure = "ar1",
  items = 5,
  lowerbound = 1, upperbound = 7,
  return_corr_only = FALSE,
  diagnostics = TRUE
)
#> best solution in 299 iterations
#> reached maximum of 1024 iterations
#> reached maximum of 1024 iterations
#> reached maximum of 1024 iterations

print(out2)
#> $data
#>    time_1 time_2 time_3 time_4
#> 1     2.4    3.8    4.8    6.0
#> 2     4.8    4.6    4.0    4.6
#> 3     4.2    4.8    5.4    5.0
#> 4     3.4    3.2    5.0    5.4
#> 5     3.2    2.6    2.0    2.8
#> 6     2.2    3.2    3.6    4.0
#> 7     2.0    3.2    2.2    5.8
#> 8     2.2    2.8    4.2    5.2
#> 9     2.2    2.8    3.4    4.4
#> 10    1.8    2.2    3.6    4.6
#> 11    2.8    5.4    1.6    2.2
#> 12    2.4    3.2    2.6    5.6
#> 13    3.2    3.6    4.0    6.4
#> 14    4.0    4.0    3.8    4.0
#> 15    3.2    3.0    4.8    3.2
#> 16    3.4    5.0    5.8    4.0
#> 17    3.4    4.6    4.8    5.0
#> 18    2.0    3.0    4.6    3.4
#> 19    1.6    2.8    3.6    3.2
#> 20    2.2    3.6    3.0    4.2
#> 21    2.6    4.0    3.2    4.0
#> 22    3.4    4.2    6.0    5.4
#> 23    3.8    3.6    4.0    4.6
#> 24    2.4    2.4    1.8    3.6
#> 25    3.0    2.4    2.8    3.4
#> 26    2.0    2.4    4.4    3.2
#> 27    1.8    2.6    4.2    3.8
#> 28    2.0    2.4    4.6    4.8
#> 29    3.6    2.2    3.4    3.8
#> 30    2.4    5.8    5.6    4.4
#> 31    2.2    3.4    5.2    5.4
#> 32    2.2    5.0    6.0    5.2
#> 
#> $correlation_matrix
#>            time_1    time_2    time_3     time_4
#> time_1 1.00000000 0.3910032 0.1528835 0.05977794
#> time_2 0.39100319 1.0000000 0.3910032 0.15288350
#> time_3 0.15288350 0.3910032 1.0000000 0.39100319
#> time_4 0.05977794 0.1528835 0.3910032 1.00000000
#> 
#> $structure
#> [1] "ar1"
#> 
#> $feasible_f_range
#>       min       max 
#>  9.353034 39.481390 
#> 
#> $recommended_f
#> $recommended_f$conservative
#> [1] 10.21
#> 
#> $recommended_f$moderate
#> [1] 11.91
#> 
#> $recommended_f$strong
#> [1] 30.29
#> 
#> 
#> $achieved_f
#> [1] 15.99983
#> 
#> $effect_size_raw
#> [1] 0.3792188
#> 
#> $effect_size_standardised
#> [1] 0.3717831
#> 


out3 <- makeRepeated(
  n = 64, k = 4,
  means = c(2.0, 2.25, 2.75, 3.0),
  sds = c(0.8, 0.9, 1.0, 0.9),
  items = 4,
  f_stat = 24,
  # structure = "toeplitz",
  diagnostics = TRUE
)
#> best solution in 3541 iterations
#> best solution in 2048 iterations
#> reached maximum of 4096 iterations
#> best solution in 676 iterations

str(out3)
#> List of 8
#>  $ data                    :'data.frame':    64 obs. of  4 variables:
#>   ..$ time_1: num [1:64] 1.25 1 1.5 2 1.5 2.5 3 1.5 2.25 2.75 ...
#>   ..$ time_2: num [1:64] 2.5 1.25 2 1.5 1.75 3.5 3 2 3 3.5 ...
#>   ..$ time_3: num [1:64] 3 2.5 2 3.25 2.75 3 4 3 3.25 4 ...
#>   ..$ time_4: num [1:64] 3.25 1.25 3.5 3.75 3.75 4 3 3.25 3.75 3 ...
#>  $ correlation_matrix      : num [1:4, 1:4] 1 0.489 0.489 0.489 0.489 ...
#>   ..- attr(*, "dimnames")=List of 2
#>   .. ..$ : chr [1:4] "time_1" "time_2" "time_3" "time_4"
#>   .. ..$ : chr [1:4] "time_1" "time_2" "time_3" "time_4"
#>  $ structure               : chr "cs"
#>  $ feasible_f_range        : Named num [1:2] 9.27 61.35
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
#>  $ recommended_f           :List of 3
#>   ..$ conservative: num 11.6
#>   ..$ moderate    : num 16.1
#>   ..$ strong      : num 46.3
#>  $ achieved_f              : num 24
#>  $ effect_size_raw         : num 0.156
#>  $ effect_size_standardised: num 0.192
```
