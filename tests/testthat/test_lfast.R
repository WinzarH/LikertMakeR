## context("check-output") 
library(testthat)  # load testthat package
library(LikertMakeR)   # load our package

# Test whether the output is a data frame
test_that("lfast() returns a list", {
  x1 <- lfast(n = 128, mean = 3, sd = 1.5, lowerbound = 1, upperbound = 5, items = 5)
  x1 <- data.frame(x1)
  expect_type(x1, 'list')
})

# ## Test whether the output contains the right number of rows
# test_that("lfast() returns a dataframe with correct number of rows", {
#   x1 <- lfast(n = 128, mean = 3, sd = 1.5, lowerbound = 1, upperbound = 5, items = 5)
#   x1 <- data.frame(x1)
#   expect_equal(nrow(x1), 128)
# })
