## Unit tests for lfast() function

test_that("lfast_R produces correct length and bounded output", {
  set.seed(123) # for reproducibility
  x <- lfast_R(n = 128, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5)

  # Check the length of the output
  expect_length(x, 128)

  # Check if the values are within the specified bounds
  expect_true(all(x >= 1 & x <= 7))

  # Check if moments are within tolerance bounds
  expect_true(abs(mean(x) - 4.5) < 0.05)
  expect_true(abs(sd(x) - 1.0) < 0.05)
})


test_that("lfast_R runs silently with valid inputs", {
  set.seed(123)
  expect_no_warning(lfast_R(n = 64, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5))
})


test_that("lfast_R throws an error with invalid inputs", {
  expect_error(
    lfast_R(n = -1, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 5)
  )
})
