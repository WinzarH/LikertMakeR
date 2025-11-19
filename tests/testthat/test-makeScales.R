# tests/testthat/test-makeScales.R

testthat::test_that("makeScales: basic generation works and respects shapes, names, bounds", {
  # Ensure testthat is loaded
  if (!requireNamespace("LikertMakeR", quietly = TRUE)) {
    testthat::skip("LikertMakeR not installed; skipping this test.")
  }

  set.seed(123)

  n  <- 128L
  k <- 4L
  means <- c(2.5, 3.0, 3.0, 3.5)
  sds   <- c(1.0, 1.0, 1.5, 0.75)
  lb    <- rep(1L, k)
  ub    <- rep(5L, k)


  corMat <- matrix(c(
    1.00, 0.30, 0.40, 0.60,
    0.30, 1.00, 0.50, 0.70,
    0.40, 0.50, 1.00, 0.80,
    0.60, 0.70, 0.80, 1.00
  ), nrow = k, byrow = TRUE)
  dimnames(corMat) <- list(paste0("Q", 1:k), paste0("Q", 1:k))


  df <- makeScales(
    n = n, means = means, sds = sds,
    lowerbound = lb, upperbound = ub, cormatrix = corMat
  )

  # structure
  testthat::expect_true(is.data.frame(df))
  testthat::expect_identical(nrow(df), n)
  testthat::expect_identical(ncol(df), k)
  testthat::expect_identical(colnames(df), colnames(corMat))

  # bounds respected
  for (j in seq_len(k)) {
    testthat::expect_true(all(df[[j]] >= lb[j] & df[[j]] <= ub[j]))
  }

  # moments are in the ballpark (tolerances reflect discreteness and finite n)
  m_hat <- vapply(df, mean, numeric(1))
  s_hat <- vapply(df, stats::sd, numeric(1))

  testthat::expect_true(all(abs(m_hat - means) <= 0.25))
  testthat::expect_true(all(abs(s_hat - sds)   <= 0.35))

  # correlations roughly match target (off-diagonal)
  Rhat <- stats::cor(df)
  offdiag <- function(M) M[upper.tri(M)]
  testthat::expect_true(all(abs(offdiag(Rhat) - offdiag(corMat)) <= 0.15))
})

testthat::test_that("makeScales: scalar lower/upper/items recycle correctly", {
  set.seed(42)
  n <- 150L
  k <- 5L

  means <- rep(3, k)
  sds   <- rep(1, k)
  lb    <- 1L      # scalar, should recycle
  ub    <- 7L      # scalar, should recycle
  items <- 3L      # scalar, should recycle

  corMat <- diag(k)
  dimnames(corMat) <- list(LETTERS[1:k], LETTERS[1:k])

  df <- makeScales(
    n = n, means = means, sds = sds,
    lowerbound = lb, upperbound = ub, items = items,
    cormatrix = corMat
  )

  testthat::expect_true(is.data.frame(df))
  testthat::expect_identical(nrow(df), n)
  testthat::expect_identical(ncol(df), k)
  testthat::expect_identical(colnames(df), colnames(corMat))
  for (j in seq_len(k)) {
    testthat::expect_true(all(df[[j]] >= 1L & df[[j]] <= 7L))
  }
})

testthat::test_that("makeScales: rejects non-PSD correlation matrices early with a clear error", {
  testthat::skip("Enable after makeScales() actually calls check_PD_matrix().")

  set.seed(99)
  n <- 50L
  means <- c(3, 3)
  sds   <- c(1, 1)
  lb    <- c(1, 1)
  ub    <- c(5, 5)

  # Non-PSD: enforce diagonal 1 but off-diagonals > 1 in magnitude
  badCor <- matrix(c(1, 1.2, 1.2, 1), nrow = 2)

  testthat::expect_error(
    makeScales(n, means, sds, lb, ub, cormatrix = badCor),
    regexp = "not Positive Definite|Requested correlations are not possible"
  )
})



testthat::test_that("makeScales: mismatched lengths and dimensions fail fast with a descriptive error", {
  testthat::skip("Enable after makeScales() validates lengths AFTER recycling and uses stop().")

  set.seed(1)
  n <- 40L
  means <- c(3, 3, 3)  # length 3
  sds   <- c(1, 1)     # length 2 -> mismatch
  lb    <- 1
  ub    <- 5
  items <- 2L
  corMat <- diag(3)

  testthat::expect_error(
    makeScales(n, means, sds, lb, ub, items, cormatrix = corMat),
    regexp = "Parameters have unequal length"
  )
})



testthat::test_that("makeScales: NA/Inf inputs are rejected", {
  testthat::skip("Enable after adding explicit NA/Inf/type checks that stop().")

  n <- 20L
  means <- c(3, NA)
  sds   <- c(1, 1)
  lb    <- c(1, 1)
  ub    <- c(5, 5)
  corMat <- diag(2)

  testthat::expect_error(
    makeScales(n, means, sds, lb, ub, cormatrix = corMat),
    regexp = "missing|NA|finite|numeric"
  )

  means2 <- c(3, Inf)
  testthat::expect_error(
    makeScales(n, means2, sds, lb, ub, cormatrix = corMat),
    regexp = "finite"
  )
})

testthat::test_that("makeScales: lowerbound < upperbound and within-range means are enforced", {
  testthat::skip("Enable after adding bound order and mean-range checks that stop().")

  n <- 30L
  means <- c(6, 2)       # first mean outside [lb, ub] if lb=1,ub=5
  sds   <- c(1, 1)
  lb    <- c(1, 3)
  ub    <- c(5, 2)       # invalid: lb >= ub in 2nd position
  corMat <- diag(2)

  testthat::expect_error(
    makeScales(n, means, sds, lb, ub, cormatrix = corMat),
    regexp = "lower.*<.*upper|bounds"
  )

  lb2 <- c(1, 1); ub2 <- c(5, 5)
  testthat::expect_error(
    makeScales(n, means, sds, lb2, ub2, cormatrix = corMat),
    regexp = "means.*within.*bounds|outside"
  )
})
