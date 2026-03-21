### Unit tests for alpha_sensitivity()

## Core correctness (formula check)
test_that("alpha_sensitivity computes correct alpha values", {
  res <- alpha_sensitivity(k = 4, r_bar = 0.5, plot = FALSE)

  expected <- (4 * 0.5) / (1 + (4 - 1) * 0.5)

  expect_equal(
    res$alpha[res$r_bar == 0.5],
    round(expected, 3)
  )
})

## Monotonic behaviour (conceptual integrity)
test_that("alpha increases monotonically with r_bar", {
  res <- alpha_sensitivity(k = 6, vary = "r_bar", plot = FALSE)

  expect_true(all(diff(res$alpha) > 0))
})

## Empirical mode works
test_that("empirical mode derives k and r_bar correctly", {
  df <- data.frame(
    x1 = c(1, 2, 3, 4),
    x2 = c(1, 2, 3, 4),
    x3 = c(1, 2, 3, 4)
  )

  res <- alpha_sensitivity(data = df, plot = FALSE)

  expect_equal(unique(res$k), 3)
  expect_equal(attr(res, "baseline")$r_bar, 1, tolerance = 1e-8)
})

## Input validation (combined)
test_that("input validation works correctly", {
  df <- data.frame(a = 1:3, b = 1:3)

  expect_error(alpha_sensitivity())
  expect_error(alpha_sensitivity(data = df, k = 3, r_bar = 0.3))
  expect_error(alpha_sensitivity(k = 1, r_bar = 0.3))
  expect_error(alpha_sensitivity(k = 4, r_bar = 1))
})
