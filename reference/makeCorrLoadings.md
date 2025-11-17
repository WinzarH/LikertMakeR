# Generate Inter-Item Correlation Matrix from Factor Loadings

Constructs an inter-item correlation matrix based on a user-supplied
matrix of standardised factor loadings and (optionally) a factor
correlation matrix. The `makeCorrLoadings()` function does a
surprisingly good job of reproducing a target correlation matrix when
all item-factor loadings are present, as shown in the
*makeCorrLoadings() validation article*.

## Usage

``` r
makeCorrLoadings(
  loadings,
  factorCor = NULL,
  uniquenesses = NULL,
  nearPD = FALSE,
  diagnostics = FALSE
)
```

## Arguments

- loadings:

  Numeric matrix. A \\k \times f\\ matrix of standardized factor
  loadings \\items \times factors\\. Row names and column names are used
  for diagnostics if present.

- factorCor:

  Optional \\f \times f\\ matrix of factor correlations (\\\Phi\\). If
  NULL, assumes orthogonal factors.

- uniquenesses:

  Optional vector of length k. If NULL, calculated as \\1 -
  rowSums(loadings^2)\\.

- nearPD:

  Logical. If `TRUE`, attempts to coerce non–positive-definite matrices
  using
  [`Matrix::nearPD()`](https://rdrr.io/pkg/Matrix/man/nearPD.html).

- diagnostics:

  Logical. If `TRUE`, returns diagnostics including McDonald's Omega and
  item-level summaries.

## Value

If diagnostics = FALSE, returns a correlation matrix (class: matrix). If
diagnostics = TRUE, returns a list with: - R: correlation matrix -
Omega: per-factor Omega or adjusted Omega - OmegaTotal: total Omega
across all factors - Diagnostics: dataframe of communalities,
uniquenesses, and primary factor

## See also

- makeCorrLoadings() validation article:
  <https://winzarh.github.io/LikertMakeR/articles/makeCorrLoadings_validate.html>

- Package website: <https://winzarh.github.io/LikertMakeR/>

## Examples

``` r
# --------------------------------------------------------
# Example 1: Basic use without diagnostics
# --------------------------------------------------------

factorLoadings <- matrix(
  c(
    0.05, 0.20, 0.70,
    0.10, 0.05, 0.80,
    0.05, 0.15, 0.85,
    0.20, 0.85, 0.15,
    0.05, 0.85, 0.10,
    0.10, 0.90, 0.05,
    0.90, 0.15, 0.05,
    0.80, 0.10, 0.10
  ),
  nrow = 8, ncol = 3, byrow = TRUE
)

rownames(factorLoadings) <- paste0("Q", 1:8)
colnames(factorLoadings) <- c("Factor1", "Factor2", "Factor3")

factorCor <- matrix(
  c(
    1.0,  0.7, 0.6,
    0.7,  1.0, 0.4,
    0.6,  0.4, 1.0
  ),
  nrow = 3, byrow = TRUE
)

itemCor <- makeCorrLoadings(factorLoadings, factorCor)
round(itemCor, 3)
#>       Q1    Q2    Q3    Q4    Q5    Q6    Q7    Q8
#> Q1 1.000 0.638 0.683 0.537 0.477 0.484 0.552 0.521
#> Q2 0.638 1.000 0.735 0.503 0.434 0.436 0.557 0.531
#> Q3 0.683 0.735 1.000 0.569 0.499 0.503 0.601 0.570
#> Q4 0.537 0.503 0.569 1.000 0.799 0.839 0.751 0.676
#> Q5 0.477 0.434 0.499 0.799 1.000 0.805 0.670 0.599
#> Q6 0.484 0.436 0.503 0.839 0.805 1.000 0.709 0.633
#> Q7 0.552 0.557 0.601 0.751 0.670 0.709 1.000 0.790
#> Q8 0.521 0.531 0.570 0.676 0.599 0.633 0.790 1.000

# --------------------------------------------------------
# Example 2: Diagnostics with factor correlations (Adjusted Omega)
# --------------------------------------------------------

result_adj <- makeCorrLoadings(
  loadings = factorLoadings,
  factorCor = factorCor,
  diagnostics = TRUE
)
#> Diagnostics returned with Adjusted Omega (accounting for factor correlations).

# View outputs
round(result_adj$R, 3) # correlation matrix
#>       Q1    Q2    Q3    Q4    Q5    Q6    Q7    Q8
#> Q1 1.000 0.638 0.683 0.537 0.477 0.484 0.552 0.521
#> Q2 0.638 1.000 0.735 0.503 0.434 0.436 0.557 0.531
#> Q3 0.683 0.735 1.000 0.569 0.499 0.503 0.601 0.570
#> Q4 0.537 0.503 0.569 1.000 0.799 0.839 0.751 0.676
#> Q5 0.477 0.434 0.499 0.799 1.000 0.805 0.670 0.599
#> Q6 0.484 0.436 0.503 0.839 0.805 1.000 0.709 0.633
#> Q7 0.552 0.557 0.601 0.751 0.670 0.709 1.000 0.790
#> Q8 0.521 0.531 0.570 0.676 0.599 0.633 0.790 1.000
round(result_adj$Omega, 3) # adjusted Omega
#> Factor1 Factor2 Factor3 
#>   0.691   0.683   0.638 
round(result_adj$OmegaTotal, 3) # total Omega
#> [1] 0.768
print(result_adj$Diagnostics) # communality and uniqueness per item
#>    Item Communality Uniqueness PrimaryFactor
#> Q1   Q1      0.5325     0.4675       Factor3
#> Q2   Q2      0.6525     0.3475       Factor3
#> Q3   Q3      0.7475     0.2525       Factor3
#> Q4   Q4      0.7850     0.2150       Factor2
#> Q5   Q5      0.7350     0.2650       Factor2
#> Q6   Q6      0.8225     0.1775       Factor2
#> Q7   Q7      0.8350     0.1650       Factor1
#> Q8   Q8      0.6600     0.3400       Factor1

# --------------------------------------------------------
# Example 3: Diagnostics assuming orthogonal factors (Per-Factor Omega)
# --------------------------------------------------------

result_orth <- makeCorrLoadings(
  loadings = factorLoadings,
  diagnostics = TRUE
)
#> Diagnostics returned with Per-Factor Omega (assuming orthogonal factors).

round(result_orth$Omega, 3) # per-factor Omega
#> Factor1 Factor2 Factor3 
#>   0.405   0.513   0.460 
round(result_orth$OmegaTotal, 3) # total Omega
#> [1] 0.721
print(result_orth$Diagnostics)
#>    Item Communality Uniqueness PrimaryFactor
#> Q1   Q1      0.5325     0.4675       Factor3
#> Q2   Q2      0.6525     0.3475       Factor3
#> Q3   Q3      0.7475     0.2525       Factor3
#> Q4   Q4      0.7850     0.2150       Factor2
#> Q5   Q5      0.7350     0.2650       Factor2
#> Q6   Q6      0.8225     0.1775       Factor2
#> Q7   Q7      0.8350     0.1650       Factor1
#> Q8   Q8      0.6600     0.3400       Factor1
```
