# Sensitivity of Cronbach's alpha to scale design parameters

Computes how Cronbach's alpha changes as a function of either the
average inter-item correlation (\\\bar{r}\\) or the number of items
(\\k\\), holding the other parameter constant.

## Usage

``` r
alpha_sensitivity(
  data = NULL,
  k = NULL,
  r_bar = NULL,
  vary = c("r_bar", "k"),
  k_range = NULL,
  r_bar_range = NULL,
  plot = TRUE,
  digits = 3
)
```

## Arguments

- data:

  A data frame or matrix of item responses. If provided, \\k\\ and
  \\\bar{r}\\ are computed from the data.

- k:

  Number of items. Required if `data` is not supplied.

- r_bar:

  Average inter-item correlation. Required if `data` is not supplied.

- vary:

  Character string indicating which parameter to vary: `"r_bar"`
  (default) or `"k"`.

- k_range:

  Numeric vector of item counts to evaluate when `vary = "k"`. Default
  is `2:20`.

- r_bar_range:

  Numeric vector of average inter-item correlations to evaluate when
  `vary = "r_bar"`. Default is `seq(0.05, 0.9, by = 0.05)`.

- plot:

  Logical; if `TRUE`, a base R plot is produced. Default is `TRUE`.

- digits:

  Number of decimal places for rounding output. Default is `3`.

## Value

A data frame with columns:

- `k`: number of items

- `r_bar`: average inter-item correlation

- `alpha`: Cronbach's alpha

The returned object includes an attribute `"baseline"` containing the
reference \\k\\ and \\\bar{r}\\ values.

## Details

The function supports two modes:

- Empirical: derive \\k\\ and \\\bar{r}\\ from a dataset

- Theoretical: specify \\k\\ and \\\bar{r}\\ directly

## See also

[`alpha`](https://winzarh.github.io/LikertMakeR/reference/alpha.md),
[`reliability`](https://winzarh.github.io/LikertMakeR/reference/reliability.md)

## Examples

``` r
# Theoretical example

if (FALSE) { # \dontrun{
alpha_sensitivity(k = 6) # produces plot
} # }

alpha_sensitivity(k = 6, r_bar = 0.4, plot = FALSE)
#>    k r_bar alpha
#> 1  6  0.05 0.240
#> 2  6  0.10 0.400
#> 3  6  0.15 0.514
#> 4  6  0.20 0.600
#> 5  6  0.25 0.667
#> 6  6  0.30 0.720
#> 7  6  0.35 0.764
#> 8  6  0.40 0.800
#> 9  6  0.45 0.831
#> 10 6  0.50 0.857
#> 11 6  0.55 0.880
#> 12 6  0.60 0.900
#> 13 6  0.65 0.918
#> 14 6  0.70 0.933
#> 15 6  0.75 0.947
#> 16 6  0.80 0.960
#> 17 6  0.85 0.971
#> 18 6  0.90 0.982

# Vary number of items
alpha_sensitivity(k = 6, r_bar = 0.4, vary = "k", plot = FALSE)
#>     k r_bar alpha
#> 1   2   0.4 0.571
#> 2   3   0.4 0.667
#> 3   4   0.4 0.727
#> 4   5   0.4 0.769
#> 5   6   0.4 0.800
#> 6   7   0.4 0.824
#> 7   8   0.4 0.842
#> 8   9   0.4 0.857
#> 9  10   0.4 0.870
#> 10 11   0.4 0.880
#> 11 12   0.4 0.889
#> 12 13   0.4 0.897
#> 13 14   0.4 0.903
#> 14 15   0.4 0.909
#> 15 16   0.4 0.914
#> 16 17   0.4 0.919
#> 17 18   0.4 0.923
#> 18 19   0.4 0.927
#> 19 20   0.4 0.930

# Empirical example
df <- data.frame(
  V1 = c(1, 2, 3, 4, 5),
  V2 = c(3, 2, 4, 2, 5),
  V3 = c(2, 1, 5, 4, 3)
)

if (FALSE) { # \dontrun{
alpha_sensitivity(data = df) # produces plot
} # }

alpha_sensitivity(df, vary = "r_bar", plot = FALSE)
#>    k r_bar alpha
#> 1  3  0.05 0.136
#> 2  3  0.10 0.250
#> 3  3  0.15 0.346
#> 4  3  0.20 0.429
#> 5  3  0.25 0.500
#> 6  3  0.30 0.562
#> 7  3  0.35 0.618
#> 8  3  0.40 0.667
#> 9  3  0.45 0.711
#> 10 3  0.50 0.750
#> 11 3  0.55 0.786
#> 12 3  0.60 0.818
#> 13 3  0.65 0.848
#> 14 3  0.70 0.875
#> 15 3  0.75 0.900
#> 16 3  0.80 0.923
#> 17 3  0.85 0.944
#> 18 3  0.90 0.964

alpha_sensitivity(df, vary = "k", plot = FALSE)
#>     k r_bar alpha
#> 1   2  0.45 0.620
#> 2   3  0.45 0.710
#> 3   4  0.45 0.766
#> 4   5  0.45 0.803
#> 5   6  0.45 0.831
#> 6   7  0.45 0.851
#> 7   8  0.45 0.867
#> 8   9  0.45 0.880
#> 9  10  0.45 0.891
#> 10 11  0.45 0.900
#> 11 12  0.45 0.907
#> 12 13  0.45 0.914
#> 13 14  0.45 0.920
#> 14 15  0.45 0.925
#> 15 16  0.45 0.929
#> 16 17  0.45 0.933
#> 17 18  0.45 0.936
#> 18 19  0.45 0.939
#> 19 20  0.45 0.942
```
