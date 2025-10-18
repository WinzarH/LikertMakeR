# test-makeCorrLoadings.R

test_that("makeCorrLoadings returns a valid correlation matrix by default", {
  Lambda <- matrix(
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
  Phi <- matrix(
    c(
      1.0, 0.7, 0.6,
      0.7, 1.0, 0.4,
      0.6, 0.4, 1.0
    ),
    nrow = 3, byrow = TRUE
  )

  R <- makeCorrLoadings(Lambda, Phi)

  # Check dimensions: 8 items -> 8x8 matrix
  expect_true(is.matrix(R))
  expect_equal(nrow(R), 8)
  expect_equal(ncol(R), 8)

  # Diagonal elements should be close to 1
  expect_equal(diag(R), rep(1, 8), tolerance = 1e-6)

  # Correlation matrix should be symmetric
  expect_true(isSymmetric(R))
})
