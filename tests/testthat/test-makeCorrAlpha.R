## Unit tests for makeCorrAlpha() function

test_that("makeCorrAlpha runs silently with valid inputs", {
  ## define parameters

  items <- 4
  alpha <- 0.85
  variance <- 0.5

  ## apply function tests

  expect_no_warning(makeCorrAlpha(items, alpha, variance))

  expect_no_warning(makeCorrAlpha(items, alpha))
})
