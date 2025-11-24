# Synthesise rating-scale data with predefined mean and standard deviation

`lfast()` applies a simple Evolutionary Algorithm to find a vector that
best fits the desired moments.

`lfast()` generates random discrete values from a scaled Beta
distribution so the data replicate an ordinal rating scale - for
example, a Likert scale made from multiple items (questions) or 0-10
likelihood-of-purchase scale. Data generated are generally consistent
with real data, as shown in the *lfast() validation article*.

## Usage

``` r
lfast(n, mean, sd, lowerbound, upperbound, items = 1, precision = 0)
```

## Arguments

- n:

  (positive, int) number of observations to generate

- mean:

  (real) target mean, between upper and lower bounds

- sd:

  (positive, real) target standard deviation

- lowerbound:

  (int) lower bound (e.g. '1' for a 1-5 rating scale)

- upperbound:

  (int) upper bound (e.g. '5' for a 1-5 rating scale)

- items:

  (positive, int) number of items in the rating scale. Default = 1

- precision:

  (positive, real) can relax the level of accuracy required. (e.g. '1'
  generally generates a vector with moments correct within '0.025', '2'
  generally within '0.05') Default = 0

## Value

a vector approximating user-specified conditions.

## See also

- lfast validation article:
  <https://winzarh.github.io/LikertMakeR/articles/lfast_validation.html>

- Package website: <https://winzarh.github.io/LikertMakeR/>

## Examples

``` r
## six-item 1-7 rating scale
x <- lfast(
  n = 256,
  mean = 4.0,
  sd = 1.25,
  lowerbound = 1,
  upperbound = 7,
  items = 6
)
#> best solution in 188 iterations

## five-item -3 to +3 rating scale
x <- lfast(
  n = 64,
  mean = 0.025,
  sd = 1.25,
  lowerbound = -3,
  upperbound = 3,
  items = 5
)
#> best solution in 3291 iterations

## four-item 1-5 rating scale with medium variation
x <- lfast(
  n = 128,
  mean = 3.0,
  sd = 1.00,
  lowerbound = 1,
  upperbound = 5,
  items = 4,
  precision = 5
)
#> best solution in 5 iterations

## eleven-point 'likelihood of purchase' scale
x <- lfast(256, 3, 3.0, 0, 10)
#> best solution in 7008 iterations

```
