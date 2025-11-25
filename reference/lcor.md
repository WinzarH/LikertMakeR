# Rearrange elements in each column of a data-frame to fit a predefined correlation matrix

`lcor()` rearranges values in each column of a data-frame so that
columns are correlated to match a predefined correlation matrix.

## Usage

``` r
lcor(data, target, passes = 10)
```

## Arguments

- data:

  dataframe that is to be rearranged

- target:

  target correlation matrix. Must have same dimensions as number of
  columns in data-frame.

- passes:

  Number of optimization passes (default = 10). Increasing this value
  *MAY* improve results if n-columns (target correlation matrix
  dimensions) are many. Decreasing the value for 'passes' is faster but
  may decrease accuracy.

## Value

Returns a dataframe whose column-wise correlations approximate a
user-specified correlation matrix

## Details

Values in a column do not change, so univariate statistics remain the
same.

## Examples

``` r
## parameters
n <- 32
lowerbound <- 1
upperbound <- 5
items <- 5

mydat3 <- data.frame(
  x1 = lfast(n, 2.5, 0.75, lowerbound, upperbound, items),
  x2 = lfast(n, 3.0, 1.50, lowerbound, upperbound, items),
  x3 = lfast(n, 3.5, 1.00, lowerbound, upperbound, items)
)
#> reached maximum of 1024 iterations
#> reached maximum of 1024 iterations
#> reached maximum of 1024 iterations

cor(mydat3) |> round(3)
#>        x1     x2     x3
#> x1  1.000 -0.167 -0.307
#> x2 -0.167  1.000  0.050
#> x3 -0.307  0.050  1.000

tgt3 <- matrix(
  c(
    1.00, 0.50, 0.75,
    0.50, 1.00, 0.25,
    0.75, 0.25, 1.00
  ),
  nrow = 3, ncol = 3
)

## apply function
new3 <- lcor(mydat3, tgt3)

## test output
cor(new3) |> round(3)
#>       X1    X2    X3
#> X1 1.000 0.501 0.749
#> X2 0.501 1.000 0.249
#> X3 0.749 0.249 1.000
```
