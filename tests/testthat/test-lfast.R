## Unit tests for lfast() function

test_that("lfast produces correct length and bounded output", {
  set.seed(123) # for reproducibility
  x <- lfast(n = 256, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5)

  # Check the length of the output
  expect_length(x, 256)

  # Check if the values are within the specified bounds
  expect_true(all(x >= 1 & x <= 7))

  # Check if moments are within tolerance bounds
  expect_true(abs(mean(x) - 4.5) < 0.1)
  expect_true(abs(sd(x) - 1.0) < 0.1)
})


test_that("lfast runs silently with valid inputs", {
  set.seed(123)
  expect_no_warning(lfast(n = 64, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5))
})


test_that("lfast throws an error with invalid inputs", {
  expect_error(
    lfast(n = -1, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5)
  )
})
