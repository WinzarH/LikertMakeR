## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup-packages, message=FALSE, warning=FALSE-----------------------------
# Load required packages only if installed
if (requireNamespace("rosetta", quietly = TRUE)) library(rosetta)
if (requireNamespace("dplyr", quietly = TRUE)) library(dplyr)
if (requireNamespace("psych", quietly = TRUE)) library(psych)
if (requireNamespace("psychTools", quietly = TRUE)) library(psychTools)
if (requireNamespace("knitr", quietly = TRUE)) library(knitr)
if (requireNamespace("kableExtra", quietly = TRUE)) library(kableExtra)

library(LikertMakeR)

## -----------------------------------------------------------------------------
itemQuestions <- c(
  "Expectation that a high dose results in a longer trip",
  "Expectation that a high dose results in a more intense trip",
  "Expectation that a high dose makes you more intoxicated",
  "Expectation that a high dose provides more energy",
  "Expectation that a high dose produces more euphoria",
  "Expectation that a high dose yields more insight",
  "Expectation that a high dose strengthens your connection with others",
  "Expectation that a high dose facilitates making contact with others",
  "Expectation that a high dose improves sex"
)

itemLabels <- c(
  "long",
  "intensity",
  "intoxicated",
  "energy",
  "euphoria",
  "insight",
  "connection",
  "contact",
  "sex"
)

labels <- data.frame(
  Questions = itemQuestions,
  Labels = itemLabels
)

kable(labels) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
## correlation matrix
pp15_cor <- cor(dat)

## -----------------------------------------------------------------------------
kable(pp15_cor, digits = 2) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
## factor analysis from `rosetta` package
rfaDose <- rosetta::factorAnalysis(
  data = dat,
  nfactors = 2,
  rotate = "promax"
)

factorLoadings <- rfaDose$output$loadings
factorCorrs <- rfaDose$output$correlations

## -----------------------------------------------------------------------------
kable(factorLoadings, digits = 2) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
kable(factorCorrs, digits = 2) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
fl_0 <- factorLoadings[, 1:2] |>
  round(2)
fl_a <- fl_0
# convert factor loadings < '0.1' to '0'
censor_a <- 0.1
fl_a[abs(fl_a) < censor_a] <- 0
fl_a_mean <- mean(fl_a == 0, na.rm = TRUE) |> round(2)
fl_a[fl_a == 0] <- " "
fl_b <- fl_0
# convert factor loadings < '0.2' to '0'
censor_b <- 0.2
fl_b[abs(fl_b) < censor_b] <- 0
fl_b_mean <- mean(fl_b == 0, na.rm = TRUE) |> round(2)
fl_b[fl_b == 0] <- " "
fl_c <- fl_0
# convert factor loadings < '0.3' to '0'
censor_c <- 0.3
fl_c[abs(fl_c) < censor_c] <- 0
fl_c_mean <- mean(fl_c == 0, na.rm = TRUE) |> round(2)
fl_c[fl_c == 0] <- " "
#  bring factor loadings together
fl <- cbind(fl_0, fl_a, fl_b, fl_c)
colnames(fl) <- c("f1", "f2", "f1", "f2", "f1", "f2", "f1", "f2")
header_text <- c("Item" = 1, "all values" = 2, "< 0.1 out" = 2, "< 0.2 out" = 2, "<0.3 out" = 2)
# print summary factor loadings
kable(fl, digits = 2, align = rep("c", 8)) |>
  column_spec(1:9, border_left = T, border_right = T) |>
  kable_styling() |>
  add_header_above(
    header = header_text,
    align = "c"
  )

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
cases <- c(
  "Full information",
  "Full information - No uniqueness",
  "Rounded loadings",
  "Rounded loadings - No uniqueness",
  "Censored loadings <0.1",
  "Censored loadings <0.2",
  "Censored loadings <0.3",
  "Censored loadings <0.1 - no uniqueness",
  "Censored loadings <0.2 - no uniqueness",
  "Censored loadings <0.3 - no uniqueness",
  "Censored loadings <0.1 - no uniqueness, factor cors",
  "Censored loadings <0.2 - no uniqueness, factor cors",
  "Censored loadings <0.3 - no uniqueness, factor cors"
)

chi2 <- c(
  chiSq_1$chi2,
  chiSq_2$chi2,
  chiSq_3$chi2,
  chiSq_4$chi2,
  chiSq_5a$chi2,
  chiSq_5b$chi2,
  chiSq_5c$chi2,
  chiSq_6a$chi2,
  chiSq_6b$chi2,
  chiSq_6c$chi2,
  chiSq_7a$chi2,
  chiSq_7b$chi2,
  chiSq_7c$chi2
) |> round(2)

p <- c(
  chiSq_1$prob,
  chiSq_2$prob,
  chiSq_3$prob,
  chiSq_4$prob,
  chiSq_5a$prob,
  chiSq_5b$prob,
  chiSq_5c$prob,
  chiSq_6a$prob,
  chiSq_6b$prob,
  chiSq_6c$prob,
  chiSq_7a$prob,
  chiSq_7b$prob,
  chiSq_7c$prob
) |> round(3)

summary_results_1 <- data.frame(
  Treatment = cases,
  chi2 = chi2,
  p = p
)

kable(summary_results_1) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
## factor analysis from `rosetta` package is a less messy version of the `psych::fa()` function

fa_bfi <- rosetta::factorAnalysis(
  data = bfi_short,
  nfactors = 5,
  rotate = "promax"
)

bfiLoadings <- fa_bfi$output$loadings
bfiCorrs <- fa_bfi$output$correlations

## -----------------------------------------------------------------------------
kable(bfiLoadings, digits = 2) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
kable(bfiCorrs, digits = 2) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
## round input values to 5 decimal places
# factor loadings
fl2 <- bfiLoadings[, 1:5] |>
  round(5) |>
  as.matrix()
# factor correlations
fc2 <- bfiCorrs |>
  round(5) |>
  as.matrix()
# run makeCorrLoadings() function
itemCors_2 <- makeCorrLoadings(
  loadings = fl2,
  factorCor = fc2,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_2 <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_2,
  n1 = sampleSize, n2 = sampleSize
)

## -----------------------------------------------------------------------------
## round input values to 2 decimal places
# factor loadings
fl3 <- bfiLoadings[, 1:5] |>
  round(2) |>
  as.matrix()

# item uniquenesses
un3 <- bfiLoadings[, 6] |>
  round(2)
## factor correlations
fc3 <- bfiCorrs |>
  round(2) |>
  as.matrix()
# run makeCorrLoadings() function
itemCors_3 <- makeCorrLoadings(
  loadings = fl3,
  factorCor = fc3,
  uniquenesses = un3
)

## Compare the two matrices
chiSq_3 <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_3,
  n1 = sampleSize, n2 = sampleSize
)

## -----------------------------------------------------------------------------
## round input values to 2 decimal places
# factor loadings
fl4 <- bfiLoadings[, 1:5] |>
  round(2) |>
  as.matrix()
## factor correlations
fc4 <- bfiCorrs |>
  round(2) |>
  as.matrix()
# run makeCorrLoadings() function
itemCors_4 <- makeCorrLoadings(
  loadings = fl4,
  factorCor = fc4,
  uniquenesses = NULL
)

## Compare the two matrices
chiSq_4 <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_4,
  n1 = sampleSize, n2 = sampleSize
)

## -----------------------------------------------------------------------------
## round input values to 2 decimal places
# factor loadings
fl5a <- bfiLoadings[, 1:5] |>
  round(2)
# convert factor loadings < '0.1' to '0'
fl5a[abs(fl5a) < 0.1] <- 0
fl5a <- as.matrix(fl5a)
# factor correlations
fc5 <- bfiCorrs |>
  round(2) |>
  as.matrix()
# item uniquenesses
un5 <- bfiLoadings[, 6] |>
  round(2)
# run makeCorrLoadings() function
itemCors_5a <- makeCorrLoadings(
  loadings = fl5a,
  factorCor = fc5,
  uniquenesses = un5
)
## Compare the two matrices
chiSq_5a <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_5a,
  n1 = sampleSize, n2 = sampleSize
)
# factor loadings
fl5b <- bfiLoadings[, 1:5] |>
  round(2)
# convert factor loadings < '0.2' to '0'
fl5b[abs(fl5b) < 0.2] <- 0
fl5b <- as.matrix(fl5b)
# run makeCorrLoadings() function
itemCors_5b <- makeCorrLoadings(
  loadings = fl5b,
  factorCor = fc5,
  uniquenesses = un5
)
## Compare the two matrices
chiSq_5b <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_5b,
  n1 = sampleSize, n2 = sampleSize
)
# factor loadings
fl5c <- bfiLoadings[, 1:5] |>
  round(2)
# convert factor loadings < '0.3' to '0'
fl5c[abs(fl5c) < 0.3] <- 0
fl5c <- as.matrix(fl5c)
# run makeCorrLoadings() function
itemCors_5c <- makeCorrLoadings(
  loadings = fl5c,
  factorCor = fc5,
  uniquenesses = un5
)
## Compare the two matrices
chiSq_5c <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_5c,
  n1 = sampleSize, n2 = sampleSize
)

## -----------------------------------------------------------------------------
## Loadings and factor correlations are the same, so we only need to change
## parameters of the makeCorrLoadings() application.

# run makeCorrLoadings() function
itemCors_6a <- makeCorrLoadings(
  loadings = fl5a,
  factorCor = fc5,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_6a <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_6a,
  n1 = sampleSize, n2 = sampleSize
)
# run makeCorrLoadings() function
itemCors_6b <- makeCorrLoadings(
  loadings = fl5b,
  factorCor = fc5,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_6b <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_6b,
  n1 = sampleSize, n2 = sampleSize
)
# run makeCorrLoadings() function
itemCors_6c <- makeCorrLoadings(
  loadings = fl5c,
  factorCor = fc5,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_6c <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_6c,
  n1 = sampleSize, n2 = sampleSize
)

## -----------------------------------------------------------------------------
## Loadings and factor correlations are the same, so we only need to change
## parameters of the makeCorrLoadings() application.

# run makeCorrLoadings() function
itemCors_7a <- makeCorrLoadings(
  loadings = fl5a,
  factorCor = NULL,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_7a <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_7a,
  n1 = sampleSize, n2 = sampleSize
)
# run makeCorrLoadings() function
itemCors_7b <- makeCorrLoadings(
  loadings = fl5b,
  factorCor = NULL,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_7b <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_7b,
  n1 = sampleSize, n2 = sampleSize
)
# run makeCorrLoadings() function
itemCors_7c <- makeCorrLoadings(
  loadings = fl5c,
  factorCor = NULL,
  uniquenesses = NULL
)
## Compare the two matrices
chiSq_7c <- cortest.jennrich(
  R1 = bfi_cor, R2 = itemCors_7c,
  n1 = sampleSize, n2 = sampleSize
)

## -----------------------------------------------------------------------------
cases <- c(
  "Full information",
  "Full information - No uniquenesses",
  "Rounded loadings",
  "Rounded loadings - No uniquenesses",
  "Censored loadings <0.1",
  "Censored loadings <0.2",
  "Censored loadings <0.3",
  "Censored loadings <0.1 - no uniqueness",
  "Censored loadings <0.2 - no uniqueness",
  "Censored loadings <0.3 - no uniqueness",
  "Censored loadings <0.1 - no uniqueness, no factor cors",
  "Censored loadings <0.2 - no uniqueness, no factor cors",
  "Censored loadings <0.3 - no uniqueness, no factor cors"
)

chi2 <- c(
  chiSq_1$chi2,
  chiSq_2$chi2,
  chiSq_3$chi2,
  chiSq_4$chi2,
  chiSq_5a$chi2,
  chiSq_5b$chi2,
  chiSq_5c$chi2,
  chiSq_6a$chi2,
  chiSq_6b$chi2,
  chiSq_6c$chi2,
  chiSq_7a$chi2,
  chiSq_7b$chi2,
  chiSq_7c$chi2
) |> round(2)

p <- c(
  chiSq_1$prob,
  chiSq_2$prob,
  chiSq_3$prob,
  chiSq_4$prob,
  chiSq_5a$prob,
  chiSq_5b$prob,
  chiSq_5c$prob,
  chiSq_6a$prob,
  chiSq_6b$prob,
  chiSq_6c$prob,
  chiSq_7a$prob,
  chiSq_7b$prob,
  chiSq_7c$prob
) |> round(3)

summary_results_2 <- data.frame(
  Treatment = cases,
  chi2 = chi2,
  p = p
)

# summary_results_2
kable(summary_results_2, digits = c(0, 1, 5)) |>
  kable_classic(full_width = F)

## -----------------------------------------------------------------------------
overall_summary <- data.frame(
  treatment = cases,
  chi2.1 = summary_results_1[, 2],
  p.1 = summary_results_1[, 3],
  chi2.2 = summary_results_2[, 2],
  p.2 = summary_results_2[, 3]
)

names(overall_summary) <- c("treatment", "chi2", "p", "chi2", "p")

kable(overall_summary, digits = c(0, 1, 3, 1, 3)) |>
  column_spec(4, border_left = T) |>
  kable_classic(full_width = F) |>
  add_header_above(c(" " = 1, "Party panel" = 2, "Big 5 (bfi)" = 2))

