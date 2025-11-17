# Generate scale items from a summated scale, with desired Cronbach's Alpha

`makeItemsScale()` generates a random dataframe of scale items based on
a predefined summated scale (such as created by the
[`lfast()`](https://winzarh.github.io/LikertMakeR/reference/lfast.md)
function), and a desired *Cronbach's Alpha*.

scale, lowerbound, upperbound, items, alpha, variance

## Usage

``` r
makeItemsScale(
  scale,
  lowerbound,
  upperbound,
  items,
  alpha = 0.8,
  variance = 0.5
)
```

## Arguments

- scale:

  (int) a vector or dataframe of the summated rating scale. Should range
  from \\lowerbound \times items\\ to \\upperbound \times items\\

- lowerbound:

  (int) lower bound of the scale item (example: '1' in a '1' to '5'
  rating)

- upperbound:

  (int) upper bound of the scale item (example: '5' in a '1' to '5'
  rating)

- items:

  (positive, int) k, or number of columns to generate

- alpha:

  (posiitve, real) desired *Cronbach's Alpha* for the new dataframe of
  items. Default = '0.8'.

  See `@details` for further information on the `alpha` parameter

- variance:

  (positive, real) the quantile from which to select items that give
  given summated scores. Must lie between '0' and '1'. Default = '0.5'.

  See `@details` for further information on the `variance` parameter

## Value

a dataframe with 'items' columns and 'length(scale)' rows

## Details

### alpha

`makeItemsScale()` takes each value of a vector of Likert scales and
produces a row of 'k' values that average the given scale value, and
then rearranges the item values within each row, attempting to give a
dataframe of Likert-scale items that produce a predefined *Cronbach's
Alpha*.

Default value for target alpha is '0.8'.

More extreme values for the 'variance' parameter may reduce the chances
of achieving the desired Alpha. So you may need to experiment a little.

### variance

There may be many ways to find a combination of integers that sum to a
specific value, and these combinations have different levels of
variance:

- low-variance: '3 + 4 = 7'

- high-variance: '1 + 6 = 7'

The 'variance' parameter defines guidelines for the amount of variance
among item values that your new dataframe should have.

For example, consider a summated value of '9' on which we apply the
`makeItemsScale()` function to generate three items. With zero variance
(variance parameter = '0'), then we see all items with the same value,
the mean of '3'. With variance = '1', then we see all items with values
that give the maximum variance among those items.

|          |     |     |     |     |
|----------|-----|-----|-----|-----|
| variance | v1  | v2  | v3  | sum |
| 0.0      | 3   | 3   | 3   | 9   |
| 0.2      | 3   | 3   | 3   | 9   |
| 0.4      | 2   | 3   | 4   | 9   |
| 0.6      | 1   | 4   | 4   | 9   |
| 0.8      | 2   | 2   | 5   | 9   |
| 1.0      | 1   | 3   | 5   | 9   |

Similarly, the same mean value applied to six items with
`makeItemsScale()` gives the following combinations at different values
of the 'variance' parameter.

|          |     |     |     |     |     |     |     |
|----------|-----|-----|-----|-----|-----|-----|-----|
| variance | v1  | v2  | v3  | v4  | v5  | v6  | sum |
| 0.0      | 3   | 3   | 3   | 3   | 3   | 3   | 18  |
| 0.2      | 1   | 3   | 3   | 3   | 4   | 4   | 18  |
| 0.4      | 1   | 2   | 3   | 4   | 4   | 4   | 18  |
| 0.6      | 1   | 1   | 4   | 4   | 4   | 4   | 18  |
| 0.8      | 1   | 1   | 3   | 4   | 4   | 5   | 18  |
| 1.0      | 1   | 1   | 1   | 5   | 5   | 5   | 18  |

And a mean value of '3.5' gives the following combinations.

|          |     |     |     |     |     |     |     |
|----------|-----|-----|-----|-----|-----|-----|-----|
| variance | v1  | v2  | v3  | v4  | v5  | v6  | sum |
| 0.0      | 3   | 3   | 3   | 4   | 4   | 4   | 21  |
| 0.2      | 3   | 3   | 3   | 3   | 4   | 5   | 21  |
| 0.4      | 2   | 2   | 4   | 4   | 4   | 5   | 21  |
| 0.6      | 1   | 3   | 4   | 4   | 4   | 5   | 21  |
| 0.8      | 1   | 2   | 4   | 4   | 5   | 5   | 21  |
| 1.0      | 1   | 1   | 4   | 5   | 5   | 5   | 21  |

The default value for 'variance' is '0.5' which gives a reasonable range
of item values. But if you want 'responses' that are more consistent
then choose a lower variance value.

## Examples

``` r
## define parameters
k <- 4
lower <- 1
upper <- 5

## scale properties
n <- 64
mean <- 3.0
sd <- 0.85

## create scale
set.seed(42)
meanScale <- lfast(
  n = n, mean = mean, sd = sd,
  lowerbound = lower, upperbound = upper,
  items = k
)
#> best solution in 2841 iterations
summatedScale <- meanScale * k

## create new items
newItems <- makeItemsScale(
  scale = summatedScale,
  lowerbound = lower, upperbound = upper,
  items = k
)
#> generate 64 rows
#> rearrange 4 values within each of 64 rows
#> Complete!
#> desired Cronbach's alpha = 0.8 (achieved alpha = 0.8002)

### test new items
# str(newItems)
# alpha(data = newItems) |> round(2)


## very low variance usually gives higher Cronbach's Alpha
mydat_20 <- makeItemsScale(
  scale = summatedScale,
  lowerbound = lower, upperbound = upper,
  items = k, alpha = 0.8, variance = 0.20
)
#> generate 64 rows
#> rearrange 4 values within each of 64 rows
#> Complete!
#> desired Cronbach's alpha = 0.8 (achieved alpha = 0.8011)

### test new data frame
# str(mydat_20)

# moments <- data.frame(
#   means = apply(mydat_20, MARGIN = 2, FUN = mean) |> round(3),
#   sds = apply(mydat_20, MARGIN = 2, FUN = sd) |> round(3)
# ) |> t()

# moments

# cor(mydat_20) |> round(2)
# alpha(data = mydat_20) |> round(2)


## default alpha (0.8) and higher variance (0.8)
mydat_80 <- makeItemsScale(
  scale = summatedScale,
  lowerbound = lower, upperbound = upper,
  items = k, variance = 0.80
)
#> generate 64 rows
#> rearrange 4 values within each of 64 rows
#> Complete!
#> desired Cronbach's alpha = 0.8 (achieved alpha = 0.8003)

### test new dataframe
# str(mydat_80)

# moments <- data.frame(
#   means = apply(mydat_80, MARGIN = 2, FUN = mean) |> round(3),
#   sds = apply(mydat_80, MARGIN = 2, FUN = sd) |> round(3)
# ) |> t()

# moments

# cor(mydat_80) |> round(2)
# alpha(data = mydat_80) |> round(2)
```
