# Synthesise a dataset from paired-sample t-test summary statistics

The function `makePaired()` generates a dataset from paired-sample
*t*-test summary statistics.

`makePaired()` generates correlated values so the data replicate rating
scales taken, for example, in a before and after experimental design.

The function is effectively a wrapper function for
[`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md)
and [`lcor()`](https://winzarh.github.io/LikertMakeR/reference/lcor.md)
with the addition of a t-statistic from which the between-column
correlation is inferred.

Paired *t*-tests apply to observations that are associated with each
other. For example: the same people before and after a treatment; the
same people rating two different objects; ratings by husband & wife;
*etc.*

The paired-samples *t*-test is defined as:

\$\$ t = \frac{\mathrm{mean}(D)}{\mathrm{sd}(D) / \sqrt{n}} \$\$

where:

- \\D\\ = differences in values

- \\\mathrm{mean}(D)\\ = mean of the differences

- \\\mathrm{sd}(D)\\ = standard deviation of the differences, where

\$\$ \mathrm{sd}(D)^2 = \mathrm{sd}(X\_{\text{before}})^2 +
\mathrm{sd}(X\_{\text{after}})^2 - 2\\\mathrm{cov}(X\_{\text{before}},
X\_{\text{after}}) \$\$

A paired-sample *t*-test thus requires an estimate of the covariance
between the two sets of observations. `makePaired()` rearranges these
formulae so that the covariance is inferred from the t-statistic.

## Usage

``` r
makePaired(
  n,
  means,
  sds,
  t_value,
  lowerbound,
  upperbound,
  items = 1,
  precision = 0
)
```

## Arguments

- n:

  (positive, integer) sample size

- means:

  (real) 1:2 vector of target means for two before/after measures

- sds:

  (real) 1:2 vector of target standard deviations

- t_value:

  (real) desired paired *t*-statistic

- lowerbound:

  (integer) lower bound (e.g. '1' for a 1-5 rating scale)

- upperbound:

  (integer) upper bound (e.g. '5' for a 1-5 rating scale)

- items:

  (positive, integer) number of items in the rating scale. Default = 1

- precision:

  (positive, real) relaxes the level of accuracy required. Default = 0

## Value

a dataframe approximating user-specified conditions.

## Note

Larger sample sizes usually result in higher t-statistics, and
correspondingly small p-values.

Small sample sizes with relatively large standard deviations and
relatively high t-statistics can result in impossible correlation
values.

Similarly, large sample sizes with low *t*-statistics can result in
impossible correlations. That is, a correlation outside of the -1:+1
range.

If this happens, the function will fail with an *ERROR* message. The
user should review the input parameters and insert more realistic
values.

## Examples

``` r
n <- 20
pair_m <- c(2.5, 3.0)
pair_s <- c(1.0, 1.5)
lower <- 1
upper <- 5
k <- 6
t <- -2.5

pairedDat <- makePaired(
  n = n, means = pair_m, sds = pair_s,
  t_value = t,
  lowerbound = lower, upperbound = upper, items = k
)
#> Initial data vectors
#> reached maximum of 1024 iterations
#> reached maximum of 1024 iterations
#> Arranging values to conform with desired t-value
#> Complete!

str(pairedDat)
#> 'data.frame':    20 obs. of  2 variables:
#>  $ X1: num  3.67 3.83 1.33 2.33 2.17 ...
#>  $ X2: num  3.67 4.83 1 1.17 2.33 ...
cor(pairedDat) |> round(2)
#>      X1   X2
#> X1 1.00 0.82
#> X2 0.82 1.00

t.test(pairedDat$X1, pairedDat$X2, paired = TRUE)
#> 
#>  Paired t-test
#> 
#> data:  pairedDat$X1 and pairedDat$X2
#> t = -2.4863, df = 19, p-value = 0.02238
#> alternative hypothesis: true mean difference is not equal to 0
#> 95 percent confidence interval:
#>  -0.90555937 -0.07777397
#> sample estimates:
#> mean difference 
#>      -0.4916667 
#> 
```
