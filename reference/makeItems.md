# Synthesise rating-scale item data with given first and second moments and a predefined correlation matrix

`makeItems()` generates a dataframe of random discrete values so the
data replicate a rating scale, and are correlated close to a predefined
correlation matrix.

`makeItems()` is being deprecated. Use the
[`makeScales()`](https://winzarh.github.io/LikertMakeR/reference/makeScales.md)
function instead.

`makeItems()` is wrapper function for:

- [`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md),
  generates a dataframe that best fits the desired moments, and

- [`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md),
  which rearranges values in each column of the dataframe so they
  closely match the desired correlation matrix.

## Usage

``` r
makeItems(n, means, sds, lowerbound, upperbound, cormatrix)
```

## Arguments

- n:

  (positive, int) sample-size - number of observations

- means:

  (real) target means: a vector of length k of mean values for each
  scale item

- sds:

  (positive, real) target standard deviations: a vector of length k of
  standard deviation values for each scale item

- lowerbound:

  (positive, int) a vector of length k (same as rows & columns of
  correlation matrix) of values for lower bound of each scale item (e.g.
  '1' for a 1-5 rating scale)

- upperbound:

  (positive, int) a vector of length k (same as rows & columns of
  correlation matrix) of values for upper bound of each scale item (e.g.
  '5' for a 1-5 rating scale)

- cormatrix:

  (real, matrix) the target correlation matrix: a square symmetric
  positive-semi-definite matrix of values ranging between -1 and +1, and
  '1' in the diagonal.

## Value

a dataframe of rating-scale values

## Examples

``` r
## define parameters

n <- 16
dfMeans <- c(2.5, 3.0, 3.0, 3.5)
dfSds <- c(1.0, 1.0, 1.5, 0.75)
lowerbound <- rep(1, 4)
upperbound <- rep(5, 4)

corMat <- matrix(
  c(
    1.00, 0.30, 0.40, 0.60,
    0.30, 1.00, 0.50, 0.70,
    0.40, 0.50, 1.00, 0.80,
    0.60, 0.70, 0.80, 1.00
  ),
  nrow = 4, ncol = 4
)

item_names <- c("Q1", "Q2", "Q3", "Q4")
rownames(corMat) <- item_names
colnames(corMat) <- item_names

## apply function

df <- makeItems(
  n = n, means = dfMeans, sds = dfSds,
  lowerbound = lowerbound, upperbound = upperbound, cormatrix = corMat
)
#> NOTE:
#> makeItems() function is being deprecated
#>               
#> Use the makeScales() function in future.
#> Variable  1
#> reached maximum of 1024 iterations
#> Variable  2
#> reached maximum of 1024 iterations
#> Variable  3
#> reached maximum of 1024 iterations
#> Variable  4
#> reached maximum of 1024 iterations
#> 
#> Arranging data to match correlations
#> 
#> Successfully generated correlated variables
#> 

## test function

str(df)
#> 'data.frame':    16 obs. of  4 variables:
#>  $ Q1: num  4 2 2 1 2 4 1 2 3 3 ...
#>  $ Q2: num  3 3 5 3 2 2 1 2 4 4 ...
#>  $ Q3: num  3 2 5 4 3 5 1 1 2 5 ...
#>  $ Q4: num  4 3 4 4 3 4 2 3 4 4 ...

# means
apply(df, 2, mean) |> round(3)
#>  Q1  Q2  Q3  Q4 
#> 2.5 3.0 3.0 3.5 

# standard deviations
apply(df, 2, sd) |> round(3)
#>    Q1    Q2    Q3    Q4 
#> 1.033 1.033 1.506 0.730 

# correlations
cor(df) |> round(3)
#>       Q1    Q2    Q3    Q4
#> Q1 1.000 0.313 0.386 0.619
#> Q2 0.313 1.000 0.514 0.707
#> Q3 0.386 0.514 1.000 0.788
#> Q4 0.619 0.707 0.788 1.000
```
