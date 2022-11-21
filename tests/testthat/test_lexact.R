## context("check-output") 
library(testthat) # load testthat package
library(LikertMakeR) # load our package

# Test whether the output is a data frame
test_that("lexact() returns a numeric vector", {
  x1 <- lexact(n = 128, mean = 3, sd = 1.5, lowerbound = 1, upperbound = 5, items = 5)
  expect_type(x1, 'double')
})

# ## Test whether the output contains the right number of rows
# test_that("lexact() returns a dataframe with correct number of rows", {
#   x1 <- lexact(n = 128, mean = 3, sd = 1.5, lowerbound = 1, upperbound = 5, items = 5)
#   expect_equal(nrow(x1), 128)
# })


test_that("lexact() returns a dataframe with correct mean to 2 decimal places", {
  x1 <- lexact(n = 128, mean = 3, sd = 1.5, lowerbound = 1, upperbound = 5, items = 5)
  # meanx1 <- round(mean(x1), 2)
  expect_equal(round(mean(x1), 2), 3.00)
})

test_that("lexact() returns a dataframe with correct SD to 2 decimal places", {
  x1 <- lexact(n = 128, mean = 3, sd = 1.5, lowerbound = 1, upperbound = 5, items = 5)
  # sdx1 <- round(sd(x1), 2)
  expect_equal(round(sd(x1), 2), 1.50)
})
