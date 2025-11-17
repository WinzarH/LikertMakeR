# Calculate Cronbach's Alpha from a correlation matrix or dataframe

`alpha()` calculates Cronbach's Alpha from a given correlation matrix or
a given dataframe.

## Usage

``` r
alpha(cormatrix = NULL, data = NULL)
```

## Arguments

- cormatrix:

  (real) a square symmetrical matrix with values ranging from -1 to +1
  and '1' in the diagonal

- data:

  (real) a dataframe or matrix

## Value

a single value

## Examples

``` r
## Sample data frame
df <- data.frame(
  V1  =  c(4, 2, 4, 3, 2, 2, 2, 1),
  V2  =  c(4, 1, 3, 4, 4, 3, 2, 3),
  V3  =  c(4, 1, 3, 5, 4, 1, 4, 2),
  V4  =  c(4, 3, 4, 5, 3, 3, 3, 3)
)

## example correlation matrix
corMat <- matrix(
  c(
    1.00, 0.35, 0.45, 0.70,
    0.35, 1.00, 0.60, 0.55,
    0.45, 0.60, 1.00, 0.65,
    0.70, 0.55, 0.65, 1.00
  ),
  nrow = 4, ncol = 4
)

## apply function examples

alpha(cormatrix = corMat)
#> [1] 0.8301887

alpha(, df)
#> [1] 0.830008

alpha(corMat, df)
#> Alert: 
#> Both cormatrix and data present.
#>                 
#> Using cormatrix by default.
#> [1] 0.8301887
```
