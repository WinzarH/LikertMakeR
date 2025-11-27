# Dataframe of correlated scales from different dataframes of scale items

`correlateScales()` creates a dataframe of scale items representing
correlated constructs, as one might find in a completed questionnaire.

## Usage

``` r
correlateScales(dataframes, scalecors)
```

## Arguments

- dataframes:

  a list of 'k' dataframes to be rearranged and combined

- scalecors:

  target correlation matrix - should be a symmetric \\k \times k\\
  positive-semi-definite matrix, where 'k' is the number of dataframes

## Value

Returns a dataframe whose columns are taken from the starter dataframes
and whose summated values are correlated according to a user-specified
correlation matrix

## Details

Correlated rating-scale items generally are summed or averaged to create
a measure of an "unobservable", or "latent", construct.
`correlateScales()` takes several such dataframes of rating-scale items
and rearranges their rows so that the scales are correlated according to
a predefined correlation matrix. Univariate statistics for each
dataframe of rating-scale items do not change, but their correlations
with rating-scale items in other dataframes do.

## Examples

``` r
## three attitudes and a behavioural intention
n <- 32
lower <- 1
upper <- 5

### attitude #1
cor_1 <- makeCorrAlpha(items = 4, alpha = 0.90)
#> reached max iterations (1600) - best mean difference: 2.2e-05
means_1 <- c(2.5, 2.5, 3.0, 3.5)
sds_1 <- c(0.9, 1.0, 0.9, 1.0)

Att_1 <- makeItems(
  n = n, means = means_1, sds = sds_1,
  lowerbound = rep(lower, 4), upperbound = rep(upper, 4),
  cormatrix = cor_1
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


### attitude #2
cor_2 <- makeCorrAlpha(items = 5, alpha = 0.85)
#> reached max iterations (2500) - best mean difference: 8.1e-05
#> Correlation matrix is not yet positive definite
#> Working on it
#> 
#> improved at swap - 3 (min eigenvalue: -0.076042)
#> improved at swap - 6 (min eigenvalue: 0.011761)
#> positive definite at swap - 6
means_2 <- c(2.5, 2.5, 3.0, 3.0, 3.5)
sds_2 <- c(1.0, 1.0, 0.9, 1.0, 1.5)

Att_2 <- makeItems(
  n = n, means = means_2, sds = sds_2,
  lowerbound = rep(lower, 5), upperbound = rep(upper, 5),
  cormatrix = cor_2
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
#> Variable  5
#> reached maximum of 1024 iterations
#> 
#> Arranging data to match correlations
#> 
#> Successfully generated correlated variables
#> 


### attitude #3
cor_3 <- makeCorrAlpha(items = 6, alpha = 0.75)
#> reached max iterations (3600) - best mean difference: 6.6e-05
means_3 <- c(2.5, 2.5, 3.0, 3.0, 3.5, 3.5)
sds_3 <- c(1.0, 1.5, 1.0, 1.5, 1.0, 1.5)

Att_3 <- makeItems(
  n = n, means = means_3, sds = sds_3,
  lowerbound = rep(lower, 6), upperbound = rep(upper, 6),
  cormatrix = cor_3
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
#> Variable  5
#> reached maximum of 1024 iterations
#> Variable  6
#> reached maximum of 1024 iterations
#> 
#> Arranging data to match correlations
#> 
#> Successfully generated correlated variables
#> 


### behavioural intention
intent <- lfast(n, mean = 3.0, sd = 3, lowerbound = 0, upperbound = 10) |>
  data.frame()
#> reached maximum of 1024 iterations
names(intent) <- "int"


### target scale correlation matrix
scale_cors <- matrix(
  c(
    1.0, 0.6, 0.5, 0.3,
    0.6, 1.0, 0.4, 0.2,
    0.5, 0.4, 1.0, 0.1,
    0.3, 0.2, 0.1, 1.0
  ),
  nrow = 4
)

data_frames <- list("A1" = Att_1, "A2" = Att_2, "A3" = Att_3, "Int" = intent)


### apply the function
my_correlated_scales <- correlateScales(
  dataframes = data_frames,
  scalecors = scale_cors
)
#> scalecors  is positive-definite
#> 
#> New dataframe successfully created
head(my_correlated_scales)
#>   A1_1 A1_2 A1_3 A1_4 A2_1 A2_2 A2_3 A2_4 A2_5 A3_1 A3_2 A3_3 A3_4 A3_5 A3_6
#> 1    2    1    2    2    1    1    2    3    2    2    1    4    2    2    1
#> 2    3    2    3    3    2    1    3    4    1    3    5    4    1    5    4
#> 3    3    3    3    4    4    4    5    4    5    3    3    4    2    4    3
#> 4    4    4    4    3    1    3    3    3    5    3    5    4    2    5    2
#> 5    1    1    2    2    1    1    1    1    1    3    1    1    1    3    1
#> 6    3    3    4    5    2    2    3    3    5    3    3    4    3    4    5
#>   Int_1
#> 1     1
#> 2     0
#> 3     3
#> 4     5
#> 5     0
#> 6     6
```
