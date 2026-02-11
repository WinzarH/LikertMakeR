# Synthesise rating-scale data with given first and second moments and a predefined correlation matrix

`makeScales()` generates a dataframe of random discrete values so the
data replicate a rating scale, and are correlated close to a predefined
correlation matrix.

`makeScales()` is wrapper function for:

- [`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md),
  generates a dataframe that best fits the desired moments, and

- [`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md),
  which rearranges values in each column of the dataframe so they
  closely match the desired correlation matrix.

## Usage

``` r
makeScales(n, means, sds, lowerbound = 1, upperbound = 5, items = 1, cormatrix)
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
  '1' for a 1-5 rating scale). Default = 1.

- upperbound:

  (positive, int) a vector of length k (same as rows & columns of
  correlation matrix) of values for upper bound of each scale item (e.g.
  '5' for a 1-5 rating scale). Default = 5.

- items:

  (positive, int) a vector of length k of number of items in each scale.
  Default = 1.

- cormatrix:

  (real, matrix) the target correlation matrix: a square symmetric
  positive-semi-definite matrix of values ranging between -1 and +1, and
  '1' in the diagonal.

## Value

a dataframe of rating-scale values

## Examples

``` r
## Example 1: four correlated items (questions)

### define parameters

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

scale_names <- c("Q1", "Q2", "Q3", "Q4")
rownames(corMat) <- scale_names
colnames(corMat) <- scale_names

### apply function

df1 <- makeScales(
  n = n, means = dfMeans, sds = dfSds,
  lowerbound = lowerbound, upperbound = upperbound, cormatrix = corMat
)
#> Variable  1 :  Q1  - 
#> reached maximum of 1024 iterations
#> Variable  2 :  Q2  - 
#> reached maximum of 1024 iterations
#> Variable  3 :  Q3  - 
#> reached maximum of 1024 iterations
#> Variable  4 :  Q4  - 
#> reached maximum of 1024 iterations
#> 
#> Arranging data to match correlations
#> 
#> Successfully generated correlated variables
#> 

### test function

str(df1)
#> 'data.frame':    16 obs. of  4 variables:
#>  $ Q1: num  3 3 4 4 2 1 3 1 3 2 ...
#>  $ Q2: num  4 4 4 2 2 3 3 1 4 2 ...
#>  $ Q3: num  3 5 2 3 2 2 1 1 5 4 ...
#>  $ Q4: num  4 5 4 3 3 3 3 3 4 3 ...

#### means
apply(df1, 2, mean) |> round(3)
#>  Q1  Q2  Q3  Q4 
#> 2.5 3.0 3.0 3.5 

#### standard deviations
apply(df1, 2, sd) |> round(3)
#>    Q1    Q2    Q3    Q4 
#> 1.033 1.033 1.506 0.730 

#### correlations
cor(df1) |> round(3)
#>       Q1    Q2    Q3    Q4
#> Q1 1.000 0.313 0.386 0.530
#> Q2 0.313 1.000 0.514 0.707
#> Q3 0.386 0.514 1.000 0.728
#> Q4 0.530 0.707 0.728 1.000



## Example 2: five correlated Likert scales

### a study on employee engagement and organizational climate:
# Job Satisfaction (JS)
# Organizational Commitment (OC)
# Perceived Supervisor Support (PSS)
# Work Engagement (WE)
# Turnover Intention (TI) (reverse-related to others).

### define parameters

n <- 128
dfMeans <- c(3.8, 3.6, 3.7, 3.9, 2.2)
dfSds <- c(0.7, 0.8, 0.7, 0.6, 0.9)
lowerbound <- rep(1, 5)
upperbound <- rep(5, 5)
items <- c(4, 4, 3, 3, 3)

corMat <- matrix(
  c(
    1.00, 0.72, 0.58, 0.65, -0.55,
    0.72, 1.00, 0.54, 0.60, -0.60,
    0.58, 0.54, 1.00, 0.57, -0.45,
    0.65, 0.60, 0.57, 1.00, -0.50,
    -0.55, -0.60, -0.45, -0.50, 1.00
  ),
  nrow = 5, ncol = 5
)

scale_names <- c("JS", "OC", "PSS", "WE", "TI")
rownames(corMat) <- scale_names
colnames(corMat) <- scale_names

### apply function

df2 <- makeScales(
  n = n, means = dfMeans, sds = dfSds,
  lowerbound = lowerbound, upperbound = upperbound,
  items = items, cormatrix = corMat
)
#> Variable  1 :  JS  - 
#> best solution in 88 iterations
#> Variable  2 :  OC  - 
#> best solution in 1334 iterations
#> Variable  3 :  PSS  - 
#> best solution in 1443 iterations
#> Variable  4 :  WE  - 
#> best solution in 623 iterations
#> Variable  5 :  TI  - 
#> best solution in 703 iterations
#> 
#> Arranging data to match correlations
#> 
#> Successfully generated correlated variables
#> 

### test function

str(df2)
#> 'data.frame':    128 obs. of  5 variables:
#>  $ JS : num  2.5 4.25 3 3.5 3.25 4.5 3.75 4.5 4.5 4.25 ...
#>  $ OC : num  2.25 3.75 2 4 3.25 3.25 4.75 4.25 4.25 4 ...
#>  $ PSS: num  2.67 4.33 3.67 3.33 2.67 ...
#>  $ WE : num  3.33 3.67 3.67 3.33 3.67 ...
#>  $ TI : num  3 1.33 3.33 3.33 2 ...

#### means
apply(df2, 2, mean) |> round(3)
#>    JS    OC   PSS    WE    TI 
#> 3.799 3.602 3.701 3.901 2.201 

#### standard deviations
apply(df2, 2, sd) |> round(3)
#>    JS    OC   PSS    WE    TI 
#> 0.699 0.800 0.701 0.599 0.898 

#### correlations
cor(df2) |> round(3)
#>         JS     OC    PSS     WE     TI
#> JS   1.000  0.721  0.580  0.650 -0.550
#> OC   0.721  1.000  0.540  0.600 -0.600
#> PSS  0.580  0.540  1.000  0.568 -0.448
#> WE   0.650  0.600  0.568  1.000 -0.501
#> TI  -0.550 -0.600 -0.448 -0.501  1.000
```
