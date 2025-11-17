# Deprecated. Use lfast() instead

`lexact` is DEPRECATED. Replaced in LikertMakeR Version 0.4.0 by new
version of `lfast`.

`lexact` remains as a legacy for earlier package users. It is now just a
wrapper for `lfast`

Previously, `lexact` used a Differential Evolution (DE) algorithm to
find an optimum solution with desired mean and standard deviation, but
we found that the updated `lfast` function is much faster and just as
accurate.

Also the package is much less bulky.

## Usage

``` r
lexact(n, mean, sd, lowerbound, upperbound, items = 1)
```

## Arguments

- n:

  (positive, int) number of observations to generate

- mean:

  (real) target mean

- sd:

  (real) target standard deviation

- lowerbound:

  (positive, int) lower bound

- upperbound:

  (positive, int) upper bound

- items:

  (positive, int) number of items in the rating scale.

## Value

a vector of simulated data approximating user-specified conditions.

## Examples

``` r
x <- lexact(
  n = 256,
  mean = 4.0,
  sd = 1.0,
  lowerbound = 1,
  upperbound = 7,
  items = 6
)
#> lexact() function is deprecated.
#>           
#> Using the more efficient lfast() function instead
#> best solution in 2331 iterations

x <- lexact(256, 2, 1.8, 0, 10)
#> lexact() function is deprecated.
#>           
#> Using the more efficient lfast() function instead
#> best solution in 1687 iterations
```
