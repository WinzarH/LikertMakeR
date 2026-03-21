## Unit tests for makeCorrAlpha() function

test_that("makeCorrAlpha runs silently with valid inputs", {
  ## define parameters

  items <- 4
  alpha <- 0.85
  variance <- 0.1

  ## apply function tests

  expect_no_warning(makeCorrAlpha(items, alpha, variance))

  expect_no_warning(makeCorrAlpha(items, alpha))
})


test_that("makeCorrAlpha approximates requested alpha", {
  target <- 0.8

  R <- makeCorrAlpha(items = 6, alpha = target)

  a <- LikertMakeR::alpha(R)

  expect_equal(a, target, tolerance = 0.02)
})
