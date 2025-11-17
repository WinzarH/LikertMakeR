# calculate eigenvalues of a correlation matrix with optional scree plot

`eigenvalues()` calculates eigenvalues of a correlation matrix and
optionally produces a scree plot.

## Usage

``` r
eigenvalues(cormatrix, scree = FALSE)
```

## Arguments

- cormatrix:

  (real, matrix) a correlation matrix

- scree:

  (logical) default = `FALSE`. If `TRUE` (or `1`), then `eigenvalues()`
  produces a scree plot to illustrate the eigenvalues

## Value

a vector of eigenvalues

report on positive-definite status of cormatrix

## Examples

``` r
## define parameters

correlationMatrix <- matrix(
  c(
    1.00, 0.25, 0.35, 0.40,
    0.25, 1.00, 0.70, 0.75,
    0.35, 0.70, 1.00, 0.80,
    0.40, 0.75, 0.80, 1.00
  ),
  nrow = 4, ncol = 4
)

## apply function

evals <- eigenvalues(cormatrix = correlationMatrix)
#> correlationMatrix  is positive-definite
#> 
evals <- eigenvalues(correlationMatrix, 1)

#> correlationMatrix  is positive-definite
#> 
```
