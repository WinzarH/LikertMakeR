# makeCorrLoadings() validation

### Abstract

The
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function accurately reconstructs an item correlation matrix from
item-factor loadings and factor correlations, similar to those produced
in *EFA* or *SEM*.

The function is robust even without explicit uniqueness or factor
correlation inputs, although loadings greater than 0.05 are needed for
best results.

### The makeCorrLoadings() function

The
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function generates a correlation matrix from factor loadings and factor
correlations as might be published in the results of *Exploratory Factor
Analysis* (**EFA**) or a *Structural Equation Model* (**SEM**). The
resulting correlation matrix then can be applied to the `makeItems()`
function to generate a synthetic data set of rating-scale items that
closely resemble the original data that created the factor loadings
summary table.

This paper tests how well the
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function achieves that goal.

### Study design

A valid
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function should be able to produce a correlation matrix that is
identical to the original correlation matrix. Further, subsequent
treatment with `makeItems()` should produce a dataframe that appears to
come from the same population as the original sample.

So we need an original, *True*, dataframe to test the function.
Preferably, we should have several different original dataframes to
ensure that results are generalisable.

### Study \#1: Party Panel 2015

#### Original data

We use the pp15 dataset - a subset of the ***Party Panel 2015***
dataset. The dataset was available in the `rosetta` package ([Peters and
Verboon 2023](#ref-rosetta)) which is no longer available on CRAN, at
time of writing, but still accessible at the [Rosetta Stats book
site](https://rosettastats.com/)

Party Panel is an annual semi-panel study among Dutch nightlife patrons,
where every year, the determinants of another nightlife-related risk
behaviour is mapped. In 2015, determinants were measured of behaviours
related to using highly dosed ecstasy pills.

Nine items are relevant to this study. Each is a 7-point likert-style
question scored in the range *-3* to *+3*.

The questions and the item labels are presented as follows:

| Questions | Labels |
|:---|:---|
| Expectation that a high dose results in a longer trip | long |
| Expectation that a high dose results in a more intense trip | intensity |
| Expectation that a high dose makes you more intoxicated | intoxicated |
| Expectation that a high dose provides more energy | energy |
| Expectation that a high dose produces more euphoria | euphoria |
| Expectation that a high dose yields more insight | insight |
| Expectation that a high dose strengthens your connection with others | connection |
| Expectation that a high dose facilitates making contact with others | contact |
| Expectation that a high dose improves sex | sex |

##### Extract and clean the original data file

``` r
## variable names
item_list <- c(
  "highDose_AttBeliefs_long",
  "highDose_AttBeliefs_intensity",
  "highDose_AttBeliefs_intoxicated",
  "highDose_AttBeliefs_energy",
  "highDose_AttBeliefs_euphoria",
  "highDose_AttBeliefs_insight",
  "highDose_AttBeliefs_connection",
  "highDose_AttBeliefs_contact",
  "highDose_AttBeliefs_sex"
)

## read the data/ select desired variables/ remove obs with missing values
dat <- read.csv2(file = "data/pp15.csv") |>
  select(all_of(item_list)) |>
  na.omit()

## give variables shorter names
names(dat) <- itemLabels

sampleSize <- nrow(dat)
```

#### Target correlation matrix

The correlations among these nine items should be reproducible by the
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function.

``` r
## correlation matrix
pp15_cor <- cor(dat)
```

|  | long | intensity | intoxicated | energy | euphoria | insight | connection | contact | sex |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| long | 1.00 | 0.33 | 0.34 | 0.19 | 0.24 | 0.17 | 0.17 | 0.10 | 0.01 |
| intensity | 0.33 | 1.00 | 0.69 | 0.12 | 0.26 | -0.01 | 0.14 | 0.12 | 0.00 |
| intoxicated | 0.34 | 0.69 | 1.00 | 0.15 | 0.13 | -0.03 | -0.01 | -0.02 | -0.11 |
| energy | 0.19 | 0.12 | 0.15 | 1.00 | 0.32 | 0.29 | 0.28 | 0.31 | 0.10 |
| euphoria | 0.24 | 0.26 | 0.13 | 0.32 | 1.00 | 0.50 | 0.61 | 0.56 | 0.29 |
| insight | 0.17 | -0.01 | -0.03 | 0.29 | 0.50 | 1.00 | 0.57 | 0.54 | 0.30 |
| connection | 0.17 | 0.14 | -0.01 | 0.28 | 0.61 | 0.57 | 1.00 | 0.78 | 0.30 |
| contact | 0.10 | 0.12 | -0.02 | 0.31 | 0.56 | 0.54 | 0.78 | 1.00 | 0.35 |
| sex | 0.01 | 0.00 | -0.11 | 0.10 | 0.29 | 0.30 | 0.30 | 0.35 | 1.00 |

##### Test cases

We shall produce the following options for factor correlation reporting:

1.  ***Full information***: factor loadings and factor correlations to
    five decimal places, plus uniquenesses.

2.  ***Full information - No uniquenesses***: factor loadings and factor
    correlations to 5 decimal places but without uniquenesses.

3.  ***Rounded loadings***: factor loadings and factor correlations to
    two decimal places, plus uniquenesses.

4.  ***Rounded loadings - No uniquenesses***: factor loadings and factor
    correlations to two decimal places but without uniquenesses.

5.  ***Censored loadings***: factor loadings to two decimal places, with
    loadings less than some arbitrary value removed for clarity of
    presentation, with uniquenesses.

6.  ***Censored loadings - No uniqueness***: factor loadings to two
    decimal places, with loadings less some arbitrary value removed for
    clarity, but without uniquenesses.

7.  ***Censored loadings, no uniqueness, no factor correlations***:
    factor loadings to two decimal places, with loadings less than some
    arbitrary value removed for clarity, no uniquenesses or factor
    correlations. Functionally, this is the equivalent of claiming
    orthogonal factors even with factor loadings from non-orthogonal
    rotation.

##### Evaluation

To compare the *True* correlation matrix with a *Synthetic* matrix, we
employ the `cortest.jennrich()` function from the `psych` package
([Revelle 2024](#ref-psych)). This is a *Chi-square* test of whether a
pair of matrices are equal ([Jennrich 1970](#ref-Jennrich1970)). We
report the raw $`\chi^2`$ statistic and corresponding p-value for each
test.

#### Exploratory Factor Analysis

Some pretesting suggests that two factors are appropriate for this
sample. And we’re confident that the factors will be correlated, so we
use promax rotation.

``` r
## factor analysis from `psych` package
rfaDose <- psych::fa(
  r = dat,
  nfactors = 2,
  rotate = "promax"
)
#> Loading required namespace: GPArotation

factorLoadings <- rfaDose$loadings[1:nrow(rfaDose$loadings), 1:ncol(rfaDose$loadings)]
factorNames <- paste("Factor", "_", seq_along(factorLoadings[1, ]), sep = "")
colnames(factorLoadings) <- factorNames
udf <- rfaDose$uniquenesses |> as.data.frame()
colnames(udf) <- "Uniqueness"
factorLoadings <- cbind(factorLoadings, udf)

factorCorrs <- rfaDose$Phi
colnames(factorCorrs) <- rownames(factorCorrs) <- factorNames
```

##### Factor Loadings

|             | Factor_1 | Factor_2 | Uniqueness |
|:------------|---------:|---------:|-----------:|
| long        |     0.11 |     0.41 |       0.80 |
| intensity   |    -0.04 |     0.79 |       0.39 |
| intoxicated |    -0.21 |     0.91 |       0.22 |
| energy      |     0.34 |     0.15 |       0.83 |
| euphoria    |     0.68 |     0.17 |       0.44 |
| insight     |     0.70 |    -0.07 |       0.53 |
| connection  |     0.86 |    -0.02 |       0.26 |
| contact     |     0.85 |    -0.05 |       0.30 |
| sex         |     0.42 |    -0.13 |       0.83 |

##### Factor Correlations

|          | Factor_1 | Factor_2 |
|:---------|---------:|---------:|
| Factor_1 |     1.00 |     0.25 |
| Factor_2 |     0.25 |     1.00 |

#### Test Case \#1: Full information

``` r
## round input values to 5 decimal places
# factor loadings
fl1 <- factorLoadings[, 1:2] |>
  round(5) |>
  as.matrix()
# item uniquenesses
un1 <- factorLoadings[, 3] |> round(5)
# factor correlations
fc1 <- round(factorCorrs, 5) |> as.matrix()
# run makeCorrLoadings() function
itemCors_1 <- makeCorrLoadings(
  loadings = fl1,
  factorCor = fc1,
  uniquenesses = un1
)
## Compare the two matrices
chiSq_1 <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_1,
  n1 = sampleSize, n2 = sampleSize
)
```

#### Test case \#2: Full information - No uniquenesses

factor loadings and factor correlations to 5 decimal places but without
uniquenesses

``` r
## round input values to 2 decimal places
# factor loadings
fl2 <- factorLoadings[, 1:2] |>
  round(5) |>
  as.matrix()
# factor correlations
fc2 <- factorCorrs |>
  round(5) |>
  as.matrix()
itemCors_2 <- makeCorrLoadings(
  loadings = fl2,
  factorCor = fc2,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_2 <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_2,
  n1 = sampleSize, n2 = sampleSize
)
```

#### Test case \#3: Rounded loadings

factor loadings and factor correlations to two decimal places.

``` r
## round input values to 2 decimal places
# factor loadings
fl3 <- factorLoadings[, 1:2] |>
  round(2) |>
  as.matrix()
# item uniquenesses
un3 <- factorLoadings[, 3] |>
  round(2)
## factor correlations
fc3 <- factorCorrs |>
  round(2) |>
  as.matrix()
## Compare the two matrices
itemCors_3 <- makeCorrLoadings(
  loadings = fl3,
  factorCor = fc3,
  uniquenesses = un3
)
## Compare the two matrices
chiSq_3 <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_3,
  n1 = sampleSize, n2 = sampleSize
)
```

#### Test case \#4: Rounded loadings - No uniquenesses

Factor loadings and factor correlations to two decimal places, and no
uniquenesses

``` r
## round input values to 2 decimal places
# factor loadings
fl4 <- factorLoadings[, 1:2] |>
  round(2) |>
  as.matrix()
## factor correlations
fc4 <- factorCorrs |>
  round(2) |>
  as.matrix()
# apply the function
itemCors_4 <- makeCorrLoadings(
  loadings = fl4,
  factorCor = fc4,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_4 <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_4,
  n1 = sampleSize, n2 = sampleSize
)
```

#### Censored loadings

Often, item-factor loadings are presented with lower values removed for
ease of reading. I’m calling these “Censored” loadings. This is usually
acceptable, because the purpose is to show the reader where the larger
loadings are. But such missing information may affect the results of
reverse-engineering that we’re employing with the
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function.

In this study, we set the level of hidden loadings at values less than
‘0.1’, ‘0.2’ and ‘0.3’.

[TABLE]

#### Test case \#5: Censored loadings

Factor loadings less than ‘0.1’, ‘0.2’, ‘0.3’ are removed for clarity,
presented to two decimal places.

``` r
## round input values to 2 decimal places
# factor loadings
fl5a <- factorLoadings[, 1:2] |>
  round(2)
# convert factor loadings < '0.1' to '0'
fl5a[abs(fl5a) < 0.1] <- 0
fl5a <- as.matrix(fl5a)
# item uniquenesses
un5 <- factorLoadings[, 3] |>
  round(2)
# factor correlations
fc5 <- factorCorrs |>
  round(2) |>
  as.matrix()
# apply the function
itemCors_5a <- makeCorrLoadings(
  loadings = fl5a,
  factorCor = fc5,
  uniquenesses = un5
)
## Compare the two matrices
chiSq_5a <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_5a,
  n1 = sampleSize, n2 = sampleSize
)

# factor loadings
fl5b <- factorLoadings[, 1:2] |>
  round(2)
# convert factor loadings < '0.2' to '0'
fl5b[abs(fl5b) < 0.2] <- 0
fl5b <- as.matrix(fl5b)
# apply the function
itemCors_5b <- makeCorrLoadings(
  loadings = fl5b,
  factorCor = fc5,
  uniquenesses = un5
)
## Compare the two matrices
chiSq_5b <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_5b,
  n1 = sampleSize, n2 = sampleSize
)

# factor loadings
fl5c <- factorLoadings[, 1:2] |>
  round(2)
# convert factor loadings < '0.2' to '0'
fl5c[abs(fl5c) < 0.3] <- 0
fl5c <- as.matrix(fl5c)
# apply the function
itemCors_5c <- makeCorrLoadings(
  loadings = fl5c,
  factorCor = fc5,
  uniquenesses = un5
)
## Compare the two matrices
chiSq_5c <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_5c,
  n1 = sampleSize, n2 = sampleSize
)
# kable(itemCors_5, digits = 2)
```

#### Test case \#6: Censored loadings - no uniquenesses

With no declared uniquenesses, they are inferred from estimated
communalities.

``` r
itemCors_6a <- makeCorrLoadings(
  loadings = fl5a,
  factorCor = fc5,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_6a <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_6a,
  n1 = sampleSize, n2 = sampleSize
)
# apply the function
itemCors_6b <- makeCorrLoadings(
  loadings = fl5b,
  factorCor = fc5,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_6b <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_6b,
  n1 = sampleSize, n2 = sampleSize
)
# apply the function
itemCors_6c <- makeCorrLoadings(
  loadings = fl5c,
  factorCor = fc5,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_6c <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_6c,
  n1 = sampleSize, n2 = sampleSize
)
```

#### Test case \#7 Censored loadings, no uniqueness, no factor correlations

No uniquenesses. That is, Uniquenesses are estimated from
1-communalities, where communalities = sum(factor-loadings^2). And no
factor correlations. That is, we assume orthogonal factors.

``` r
itemCors_7a <- makeCorrLoadings(
  loadings = fl5a,
  factorCor = NULL,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_7a <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_7a,
  n1 = sampleSize, n2 = sampleSize
)
# apply the function
itemCors_7b <- makeCorrLoadings(
  loadings = fl5b,
  factorCor = NULL,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_7b <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_7b,
  n1 = sampleSize, n2 = sampleSize
)
# apply the function
itemCors_7c <- makeCorrLoadings(
  loadings = fl5c,
  factorCor = NULL,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_7c <- cortest.jennrich(
  R1 = pp15_cor, R2 = itemCors_7c,
  n1 = sampleSize, n2 = sampleSize
)
```

### Summary results

| Treatment                                            |  chi2 |     p |
|:-----------------------------------------------------|------:|------:|
| Full information                                     | 21.07 | 0.978 |
| Full information - No uniqueness                     | 22.15 | 0.966 |
| Rounded loadings                                     | 21.06 | 0.978 |
| Rounded loadings - No uniqueness                     | 22.15 | 0.966 |
| Censored loadings \<0.1                              | 24.46 | 0.928 |
| Censored loadings \<0.2                              | 44.03 | 0.168 |
| Censored loadings \<0.3                              | 73.62 | 0.000 |
| Censored loadings \<0.1 - no uniqueness              | 26.09 | 0.888 |
| Censored loadings \<0.2 - no uniqueness              | 45.90 | 0.125 |
| Censored loadings \<0.3 - no uniqueness              | 78.12 | 0.000 |
| Censored loadings \<0.1 - no uniqueness, factor cors | 30.51 | 0.727 |
| Censored loadings \<0.2 - no uniqueness, factor cors | 49.63 | 0.065 |
| Censored loadings \<0.3 - no uniqueness, factor cors | 65.82 | 0.002 |

### Conclusion

The `makeCorrLoadings` function works quite well when it has information
on factor loadings, but less well when “summary” (censored) factor
loadings are given.

------------------------------------------------------------------------

### Study \#2: Big Five (bfi personality items)

#### Original data: bfi 25 Personality items representing 5 factors

25 personality self report items taken from the [International
Personality Item Pool (ipip.ori.org)](https://ipip.ori.org) were
included as part of the *Synthetic Aperture Personality Assessment*
*(SAPA)* web based personality assessment project. The data are
available through the `psychTools` package ([William Revelle
2024](#ref-psychTools)).

2800 subjects are included as a demonstration set for scale
construction, factor analysis, and Item Response Theory analysis. Three
additional demographic variables (sex, education, and age) are also
included.

For purposes of this study, we confine ourselves to women (sex==2) with
postgraduate qualifications (education==5), giving us a sample size of
229 subjects.

The dataset contains the following 28 variables. (The q numbers are the
SAPA item numbers).

- A1 Am indifferent to the feelings of others. (q_146)
- A2 Inquire about others’ well-being. (q_1162)
- A3 Know how to comfort others. (q_1206)
- A4 Love children. (q_1364)
- A5 Make people feel at ease. (q_1419)
- C1 Am exacting in my work. (q_124)
- C2 Continue until everything is perfect. (q_530)
- C3 Do things according to a plan. (q_619)
- C4 Do things in a half-way manner. (q_626)
- C5 Waste my time. (q_1949)
- E1 Don’t talk a lot. (q_712)
- E2 Find it difficult to approach others. (q_901)
- E3 Know how to captivate people. (q_1205)
- E4 Make friends easily. (q_1410)
- E5 Take charge. (q_1768)
- N1 Get angry easily. (q_952)
- N2 Get irritated easily. (q_974)
- N3 Have frequent mood swings. (q_1099
- N4 Often feel blue. (q_1479)
- N5 Panic easily. (q_1505)
- O1 Am full of ideas. (q_128)
- O2 Avoid difficult reading material.(q_316)
- O3 Carry the conversation to a higher level. (q_492)
- O4 Spend time reflecting on things. (q_1738)
- O5 Will not probe deeply into a subject. (q_1964)
- gender (Male=1, Female=2)
- education (1=HS, 2=finished_HS, 3=some_college, 4=college_graduate
  5=graduate_degree)
- age age in years

#### Second target correlation matrix

The correlations among these 25 items should be reproducable by the
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function.

``` r
## download data
data(bfi)
## filter for highly-educated women
bfi_short <- bfi |>
  filter(education == 5 & gender == 2) |>
  na.omit()
## keep just the 25 items
bfi_short <- bfi_short[, 1:25]
sampleSize <- nrow(bfi_short)
## derive correlation matrix
bfi_cor <- cor(bfi_short)
```

##### Test cases and Evaluation

As in the first study, we shall produce the following options for factor
correlation reporting:

1.  Full information
2.  Full information - No uniquenesses
3.  Rounded loadings
4.  Rounded loadings - No uniquenesses
5.  Censored loadings
6.  Censored loadings - No uniqueness
7.  Censored loadings - no uniqueness or factor cors

And, as in the first study, we compare the *True* correlation matrix
with a *Synthetic* matrix, employing a *Jennrich test*.

#### Exploratory Factor Analysis

Five correlated factors are appropriate for this sample, so we use
promax rotation.

``` r
## factor analysis from `psych::fa()` function

fa_bfi <- psych::fa(
  r = bfi_short,
  nfactors = 5,
  rotate = "promax"
)

bfiLoadings <- fa_bfi$loadings[1:nrow(fa_bfi$loadings), 1:ncol(fa_bfi$loadings)]
bfiFactorNames <- paste("Factor", "_", seq_along(bfiLoadings[1, ]), sep = "")
colnames(bfiLoadings) <- bfiFactorNames
bfiUdf <- fa_bfi$uniquenesses |> as.data.frame()
colnames(bfiUdf) <- "Uniqueness"
bfiLoadings <- cbind(bfiLoadings, bfiUdf)

bfiCorrs <- fa_bfi$Phi
colnames(bfiCorrs) <- rownames(bfiCorrs) <- bfiFactorNames
```

##### item-factor loadings & uniquenesses

|     | Factor_1 | Factor_2 | Factor_3 | Factor_4 | Factor_5 | Uniqueness |
|:----|---------:|---------:|---------:|---------:|---------:|-----------:|
| A1  |     0.07 |     0.14 |     0.03 |    -0.55 |    -0.15 |       0.70 |
| A2  |     0.06 |     0.13 |     0.06 |     0.55 |     0.13 |       0.59 |
| A3  |     0.16 |     0.12 |     0.17 |     0.63 |     0.05 |       0.50 |
| A4  |    -0.11 |     0.06 |     0.07 |     0.37 |    -0.08 |       0.81 |
| A5  |    -0.08 |     0.21 |    -0.05 |     0.53 |     0.01 |       0.57 |
| C1  |     0.03 |    -0.06 |     0.64 |     0.01 |     0.12 |       0.55 |
| C2  |     0.18 |     0.00 |     0.79 |     0.01 |    -0.07 |       0.44 |
| C3  |     0.08 |    -0.11 |     0.65 |     0.10 |    -0.07 |       0.63 |
| C4  |     0.15 |     0.06 |    -0.60 |    -0.04 |    -0.12 |       0.54 |
| C5  |     0.27 |    -0.04 |    -0.53 |    -0.02 |     0.08 |       0.59 |
| E1  |     0.01 |    -0.56 |     0.11 |    -0.07 |     0.13 |       0.67 |
| E2  |     0.18 |    -0.75 |     0.09 |    -0.11 |     0.14 |       0.35 |
| E3  |     0.14 |     0.49 |    -0.04 |     0.17 |     0.14 |       0.62 |
| E4  |    -0.05 |     0.54 |    -0.09 |     0.38 |    -0.18 |       0.44 |
| E5  |     0.07 |     0.54 |     0.25 |    -0.17 |     0.14 |       0.56 |
| N1  |     0.73 |     0.16 |     0.11 |    -0.14 |    -0.15 |       0.47 |
| N2  |     0.80 |     0.14 |     0.18 |    -0.16 |    -0.11 |       0.36 |
| N3  |     0.78 |    -0.01 |    -0.07 |     0.03 |     0.10 |       0.34 |
| N4  |     0.60 |    -0.17 |    -0.11 |    -0.05 |     0.16 |       0.51 |
| N5  |     0.58 |    -0.17 |    -0.04 |     0.27 |    -0.16 |       0.58 |
| O1  |     0.02 |     0.42 |    -0.10 |    -0.10 |     0.44 |       0.59 |
| O2  |     0.21 |    -0.02 |    -0.10 |     0.02 |    -0.57 |       0.60 |
| O3  |     0.12 |     0.46 |     0.01 |     0.05 |     0.35 |       0.55 |
| O4  |     0.07 |    -0.13 |    -0.01 |     0.11 |     0.48 |       0.76 |
| O5  |     0.08 |     0.01 |     0.02 |    -0.10 |    -0.74 |       0.45 |

##### factor correlations

|          | Factor_1 | Factor_2 | Factor_3 | Factor_4 | Factor_5 |
|:---------|---------:|---------:|---------:|---------:|---------:|
| Factor_1 |     1.00 |    -0.12 |    -0.22 |    -0.15 |     0.11 |
| Factor_2 |    -0.12 |     1.00 |     0.19 |     0.35 |     0.27 |
| Factor_3 |    -0.22 |     0.19 |     1.00 |     0.00 |     0.29 |
| Factor_4 |    -0.15 |     0.35 |     0.00 |     1.00 |     0.08 |
| Factor_5 |     0.11 |     0.27 |     0.29 |     0.08 |     1.00 |

#### Test Case \#1: Full information

``` r
## round input values to 5 decimal places
# factor loadings
fl1 <- bfiLoadings[, 1:5] |>
  round(5) |>
  as.matrix()
# item uniquenesses
un1 <- bfiLoadings[, 6] |> round(5)
# factor correlations
fc1 <- round(bfiCorrs, 5) |> as.matrix()
# run makeCorrLoadings() function
itemCors_1 <- makeCorrLoadings(
  loadings = fl1,
  factorCor = fc1,
  uniquenesses = un1
)
## Compare the two matrices
chiSq_1 <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_1,
  n1 = sampleSize, n2 = sampleSize
)
```

#### Other test cases as for the first study

The remaining test cases are as for the first study and this last test
case. Changes are made to the number of decimal places considered, the
presence of uniquenesses, presence of factor correlation matrix, and
level of item-factor loading that is included.

### Study \#2 Summary results

| Treatment                                               |  chi2 |     p |
|:--------------------------------------------------------|------:|------:|
| Full information                                        | 175.4 | 1.000 |
| Full information - No uniquenesses                      | 179.4 | 1.000 |
| Rounded loadings                                        | 175.8 | 1.000 |
| Rounded loadings - No uniquenesses                      | 179.6 | 1.000 |
| Censored loadings \<0.1                                 | 220.1 | 1.000 |
| Censored loadings \<0.2                                 | 451.4 | 0.000 |
| Censored loadings \<0.3                                 | 492.1 | 0.000 |
| Censored loadings \<0.1 - no uniqueness                 | 227.6 | 0.999 |
| Censored loadings \<0.2 - no uniqueness                 | 443.0 | 0.000 |
| Censored loadings \<0.3 - no uniqueness                 | 477.2 | 0.000 |
| Censored loadings \<0.1 - no uniqueness, no factor cors | 241.2 | 0.995 |
| Censored loadings \<0.2 - no uniqueness, no factor cors | 440.1 | 0.000 |
| Censored loadings \<0.3 - no uniqueness, no factor cors | 484.4 | 0.000 |

## Overall Results

Both studies show consistent results.

[TABLE]

### Conclusions

The
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function is designed to produce an item correlation matrix based on
item-factor loadings and factor correlations as one might see in the
results of Exploratory Factor Analysis (EFA) or Structural Equation
Modelling (SEM).

Results of this study suggest that the
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
function does a surprisingly good job of reproducing the target
correlation matrix when all item-factor loadings are present.

A correlation matrix created with
[`makeCorrLoadings()`](https://winzarh.github.io/LikertMakeR/reference/makeCorrLoadings.md)
seems to be robust even with the absence of specified *uniquenesses*, or
even without *factor correlations*. But a valid reproduction of a
correlation matrix should have complete item-factor loadings or, at
worst, item-factor loadings greater than 0.10.

------------------------------------------------------------------------

### References

Jennrich, Robert I. 1970. “An Asymptotic Χ2 Test for the Equality of Two
Correlation Matrices.” *Journal of the American Statistical Association*
65 (330): 904–12. <https://doi.org/10.1080/01621459.1970.10481133>.

Peters, Gjalt-Jorn, and Peter Verboon. 2023. *Rosetta: Parallel Use of
Statistical Packages in Teaching*. <https://rosettastats.com>.

Revelle, William. 2024. *Psych: Procedures for Psychological,
Psychometric, and Personality Research*. Evanston, Illinois:
Northwestern University. <https://CRAN.R-project.org/package=psych>.

William Revelle. 2024. *psychTools: Tools to Accompany the ’Psych’
Package for Psychological Research*. Evanston, Illinois: Northwestern
University. <https://CRAN.R-project.org/package=psychTools>.
