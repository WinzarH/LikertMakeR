# makeItemsScale() explainer

## Reconstructing Likert Items from Scale Scores with a Target Reliability

Many simulation studies require item-level Likert responses that satisfy
two constraints:

1.  The item values must sum to a given scale score.
2.  The items should exhibit a desired reliability (Cronbach’s
    $`\alpha`$).

The
[`makeItemsScale()`](https://winzarh.github.io/LikertMakeR/reference/makeItemsScale.md)
function generates such data by selecting candidate item combinations
whose dispersion matches the correlation structure implied by the target
reliability.

The key idea is that rows with similar item values produce stronger
correlations between items, while rows with widely varying values
produce weaker correlations.

### Relationship between reliability and correlation

Cronbach’s alpha depends on the **average inter-item correlation**:

``` math

\alpha = \frac{k \bar r}{1 + (k - 1) \bar r}
```

where

- $`k`$ = number of items
- $`\bar r`$ = mean inter-item correlation.

Rearranging gives the correlation implied by a desired reliability:

``` math

\bar r = \frac{\alpha}{k - \alpha (k - 1)}
```

#### Example

Suppose we want

- 4 items
- target $`\alpha`$ = 0.80

Then

``` math

\bar r = \frac{0.80}{4 - 0.80 (3)} = 0.5
```

Typically, we would formalise this calculation with a function.

Show the code

``` r
alpha_2_r <- function(target_alpha, k) {
  mean_r <- target_alpha / (k - target_alpha * (k - 1))
  
  return(mean_r)
}
```

So the reconstructed items should exhibit an average correlation of
approximately $`0.50`$.

Show the code

``` r
library(dplyr)
library(gtools)
library(LikertMakeR)
```

### Candidate rows

The algorithm first generates all possible item combinations within the
response bounds.

For a 4-item 1–5 scale, possible rows include:

Show the code

``` r
lower <- 1
upper <- 5
k <- 4


candidates <- combinations(
  v = c(lower:upper),
  r = k,
  n = length(c(lower:upper)),
  repeats.allowed = TRUE
) |>
  data.frame()
```

      X1 X2 X3 X4
    1  1  1  1  1
    2  1  1  1  2
    3  1  1  1  3
    4  1  1  1  4
    5  1  1  1  5
    6  1  1  2  2

    ...

       X1 X2 X3 X4
    65  3  5  5  5
    66  4  4  4  4
    67  4  4  4  5
    68  4  4  5  5
    69  4  5  5  5
    70  5  5  5  5

Each candidate row represents a possible pattern of item responses.

And each row sums to a value that could be appear in a summated scale.
Similarly, each row shows variation in its values, as measured by the
row standard deviation

``` math

s = \sqrt{\frac{1}{k - 1}\sum^k_{i=1}  (x_i - \bar x)^2}
```

Rows with small $`s`$ contain similar item values, implying stronger
correlations.

Rows with large $`s`$ contain more varied values, implying weaker
correlations.

Show the code

``` r
candidates$sum <- rowSums(candidates[, 1:k])
candidates$sd <- apply(X = candidates[, 1:k], MARGIN = 1, FUN = sd)
```

      X1 X2 X3 X4 sum        sd
    1  1  1  1  1   4 0.0000000
    2  1  1  1  2   5 0.5000000
    3  1  1  1  3   6 1.0000000
    4  1  1  1  4   7 1.5000000
    5  1  1  1  5   8 2.0000000
    6  1  1  2  2   6 0.5773503

    ...

       X1 X2 X3 X4 sum        sd
    65  3  5  5  5  18 1.0000000
    66  4  4  4  4  16 0.0000000
    67  4  4  4  5  17 0.5000000
    68  4  4  5  5  18 0.5773503
    69  4  5  5  5  19 0.5000000
    70  5  5  5  5  20 0.0000000

#### Similarity index

To relate row dispersion to correlation, the algorithm converts the
standard deviation into a **similarity index**

``` math

r^* = 1 - \frac{s}{s_{max}}
```

where

- $`s`$ = row standard deviation
- $`s_{max}`$ = maximum dispersion observed among candidate rows.

This transformation maps dispersion onto a scale between roughly 0 (low
similarity) and 1 (high similarity).

The similarity index is calculated using the maximum dispersion observed
across all possible item combinations within the response range. Using a
global maximum ensures that the similarity scale is consistent across
all scale scores and allows candidate rows from different sums to be
compared using the same similarity metric.

Rows with similar values therefore have large $`r^*`$

Show the code

``` r
s_max <- max(candidates$sd)

candidates$similar <-  1 - candidates$sd / s_max

head(candidates)
```

      X1 X2 X3 X4 sum        sd   similar
    1  1  1  1  1   4 0.0000000 1.0000000
    2  1  1  1  2   5 0.5000000 0.7834936
    3  1  1  1  3   6 1.0000000 0.5669873
    4  1  1  1  4   7 1.5000000 0.3504809
    5  1  1  1  5   8 2.0000000 0.1339746
    6  1  1  2  2   6 0.5773503 0.7500000

Show the code

``` r
message(paste0("..."))
```

    ...

Show the code

``` r
tail(candidates)
```

       X1 X2 X3 X4 sum        sd   similar
    65  3  5  5  5  18 1.0000000 0.5669873
    66  4  4  4  4  16 0.0000000 1.0000000
    67  4  4  4  5  17 0.5000000 0.7834936
    68  4  4  5  5  18 0.5773503 0.7500000
    69  4  5  5  5  19 0.5000000 0.7834936
    70  5  5  5  5  20 0.0000000 1.0000000

#### Selecting candidate rows

For each candidate row we compute

``` math

| {r^* - \bar r} |
```

where

- $`r^*`$ = row similarity
- $`\bar r`$ = target mean correlation.

Rows whose similarity index is **closest to the target correlation** are
preferred.

#### Worked example 1

**Four 5-point items with summed score = 12**

Suppose a respondent’s scale score is **12**.

We must find item values such that

``` math

x_1 + x_2 + x_3 +x_4 = 12
```

Possible combinations include:

Show the code

``` r
sums_12 <- filter(candidates, sum == 12)

print(sums_12)
```

      X1 X2 X3 X4 sum        sd   similar
    1  1  1  5  5  12 2.3094011 0.0000000
    2  1  2  4  5  12 1.8257419 0.2094306
    3  1  3  3  5  12 1.6329932 0.2928932
    4  1  3  4  4  12 1.4142136 0.3876276
    5  2  2  3  5  12 1.4142136 0.3876276
    6  2  2  4  4  12 1.1547005 0.5000000
    7  2  3  3  4  12 0.8164966 0.6464466
    8  3  3  3  3  12 0.0000000 1.0000000

Recall the target correlation is **0.50**.

The row

`2 2 4 4`

has similarity **0.50**, which is closest to the target. So this row is
selected (and later permuted across item positions).

> **Geometric intuition**
>
> Each row of item responses can be viewed as a point in a
> $`k`$-dimensional space whose coordinates are the item values. Rows in
> which all items have the same value lie on the diagonal line \$x_1 =
> x_2 = ⋯ = x_k \$ These rows have zero dispersion because the item
> values are identical.
>
> Rows in which the item values differ lie away from this diagonal. The
> further a row lies from the diagonal, the more uneven the item values
> are and the larger the row variance becomes. The most dispersed rows
> occur at the edges of the response space, where some items take the
> minimum response value and others take the maximum.
>
> The reconstruction algorithm uses this geometry to control
> reliability. Rows close to the diagonal produce highly correlated
> items, while rows further away produce weaker correlations. By
> selecting candidate rows whose distance from the diagonal matches the
> correlation implied by the target Cronbach’s alpha, the algorithm
> generates item responses whose overall reliability approximates the
> requested value.

#### Worked example 2

**Four 5-point items with summed score = 7**

Now consider a scale score of **7**.

Possible rows include:

Show the code

``` r
sums_7 <- filter(candidates, sum == 7)

print(sums_7)
```

      X1 X2 X3 X4 sum        sd   similar
    1  1  1  1  4   7 1.5000000 0.3504809
    2  1  1  2  3   7 0.9574271 0.5854219
    3  1  2  2  2   7 0.5000000 0.7834936

The row

`1 1 2 3`

has similarity closest to the target correlation (0.50), so it is
selected.

### Constructing the dataset

The algorithm repeats this process for every scale score.

1.  Identify candidate rows that sum to the required score
2.  Compute dispersion for each candidate
3.  Convert dispersion to similarity index
4.  Select the row whose similarity best matches the target correlation
5.  Randomly permute item positions

Finally, a short optimisation step rearranges item values within rows to
improve the overall correlation structure while preserving each row sum.

### Why this works

Cronbach’s alpha depends on the average correlation between items across
respondents. By selecting candidate rows whose within-row dispersion
corresponds to the desired correlation level, the algorithm indirectly
controls the covariance structure of the generated dataset.

Rows with similar item values generate stronger correlations, while rows
with more varied values generate weaker correlations. By selecting rows
with the appropriate similarity level for each scale score, the
algorithm produces datasets whose observed reliability closely matches
the requested value.

Because row variance depends only on the distribution of item values,
many different candidate rows share identical dispersion values.
Randomly selecting among tied candidates avoids systematic preference
for particular partitions while preserving the desired correlation
structure.

Because candidate item partitions produce a discrete set of dispersion
values, the achieved reliability can only approximate the requested
value. In simulation tests the deviation from the target Cronbach’s α is
typically less than 0.001.
