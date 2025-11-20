# tests/testthat/test-makeScalesRegression.R

test_that("makeScalesRegression: basic generation with provided IV correlation matrix", {
  set.seed(123)

  iv_corr <- matrix(c(1.0, 0.3, 0.3, 1.0), nrow = 2, byrow = TRUE)
  n <- 80L

  res <- suppressWarnings(
    makeScalesRegression(
      n = n,
      beta_std = c(0.4, 0.3),
      r_squared = 0.35,
      iv_cormatrix = iv_corr,
      iv_means = c(3.0, 3.5),
      iv_sds = c(1.0, 0.9),
      dv_mean = 3.8,
      dv_sd = 1.1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5,
      items_iv = 4,
      items_dv = 4,
      var_names = c("Attitude", "Intention", "Behaviour")
    )
  )

  # Structure
  testthat::expect_s3_class(res, "makeScalesRegression")
  testthat::expect_true(is.list(res))
  testthat::expect_true(is.data.frame(res$data))

  testthat::expect_identical(nrow(res$data), n)
  testthat::expect_identical(ncol(res$data), 3L)
  testthat::expect_identical(colnames(res$data), c("Attitude", "Intention", "Behaviour"))

  # Full correlation matrix has correct dim and names
  testthat::expect_true(is.matrix(res$full_cormatrix))
  testthat::expect_identical(dim(res$full_cormatrix), c(3L, 3L))
  testthat::expect_identical(
    rownames(res$full_cormatrix),
    c("Attitude", "Intention", "Behaviour")
  )

  # R-squared achieved is close to target (allowing for simulation noise)
  ach_r2 <- res$achieved_stats$r_squared
  testthat::expect_true(is.numeric(ach_r2))
  testthat::expect_lt(abs(ach_r2 - 0.35), 0.05)

  # Standardised betas achieved roughly match target (ignore names)
  testthat::expect_equal(
    unname(res$achieved_stats$beta_std),
    c(0.4, 0.3),
    tolerance = 0.12
  )

  # Means and SDs are in the right ballpark for IVs and DV (ignore names)
  targ_means <- c(res$target_stats$iv_means, res$target_stats$dv_mean)
  targ_sds <- c(res$target_stats$iv_sds, res$target_stats$dv_sd)

  ach_means <- c(res$achieved_stats$iv_means, res$achieved_stats$dv_mean)
  ach_sds <- c(res$achieved_stats$iv_sds, res$achieved_stats$dv_sd)

  testthat::expect_equal(unname(ach_means), targ_means, tolerance = 0.30)
  testthat::expect_equal(unname(ach_sds), targ_sds, tolerance = 0.35)
})


test_that("makeScalesRegression: optimisation mode works when iv_cormatrix is NULL", {
  set.seed(456)

  n <- 120L
  k <- 3L

  res <- suppressMessages(
    makeScalesRegression(
      n = n,
      beta_std = c(0.3, 0.25, 0.2),
      r_squared = 0.40,
      iv_cormatrix = NULL, # optimisation mode
      iv_cor_mean = 0.3,
      iv_cor_variance = 0.02,
      iv_cor_range = c(-0.7, 0.7),
      iv_means = c(3.0, 3.2, 2.8),
      iv_sds = c(1.0, 0.9, 1.1),
      dv_mean = 3.5,
      dv_sd = 1.0,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5,
      items_iv = 4,
      items_dv = 5
    )
  )

  # Structure of result
  testthat::expect_s3_class(res, "makeScalesRegression")
  testthat::expect_true(is.list(res$optimisation_info))
  testthat::expect_true(is.data.frame(res$data))
  testthat::expect_identical(nrow(res$data), n)
  testthat::expect_identical(ncol(res$data), k + 1L)

  # Default variable names are IV1..IVk, DV
  testthat::expect_identical(
    colnames(res$data),
    c(paste0("IV", seq_len(k)), "DV")
  )

  # Optimised IV correlation matrix in target_stats has correct shape
  testthat::expect_true(is.matrix(res$target_stats$iv_cormatrix))
  testthat::expect_identical(dim(res$target_stats$iv_cormatrix), c(k, k))

  # iv_dv_cors has length k and names of IVs
  testthat::expect_length(res$iv_dv_cors, k)
  testthat::expect_identical(names(res$iv_dv_cors), paste0("IV", seq_len(k)))

  # Achieved R-squared is reasonably close to target, given optimisation & simulation
  ach_r2 <- res$achieved_stats$r_squared
  testthat::expect_lt(abs(ach_r2 - 0.40), 0.08)
})

test_that("makeScalesRegression: r_squared outside [0, 1] throws error", {
  set.seed(1)
  iv_corr <- diag(2)

  testthat::expect_error(
    makeScalesRegression(
      n = 50L,
      beta_std = c(0.4, 0.3),
      r_squared = 1.2, # invalid
      iv_cormatrix = iv_corr,
      iv_means = c(3, 3.5),
      iv_sds = c(1, 0.9),
      dv_mean = 4,
      dv_sd = 1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5
    ),
    regexp = "r_squared must be between 0 and 1"
  )
})

test_that("makeScalesRegression: iv_cormatrix dimension mismatch throws error", {
  set.seed(2)
  iv_corr <- diag(3) # 3x3, but only 2 betas

  testthat::expect_error(
    makeScalesRegression(
      n = 40L,
      beta_std = c(0.4, 0.3),
      r_squared = 0.25,
      iv_cormatrix = iv_corr,
      iv_means = c(3, 3),
      iv_sds = c(1, 1),
      dv_mean = 4,
      dv_sd = 1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5
    ),
    regexp = "iv_cormatrix dimensions must match number of IVs"
  )
})

test_that("makeScalesRegression: iv_means / iv_sds length mismatch throws error", {
  set.seed(3)
  iv_corr <- diag(3)

  testthat::expect_error(
    makeScalesRegression(
      n = 40L,
      beta_std = c(0.4, 0.3, 0.2),
      r_squared = 0.25,
      iv_cormatrix = iv_corr,
      iv_means = c(3, 3), # too short
      iv_sds = c(1, 1, 1),
      dv_mean = 4,
      dv_sd = 1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5
    ),
    regexp = "iv_means and iv_sds must have same length as beta_std"
  )

  testthat::expect_error(
    makeScalesRegression(
      n = 40L,
      beta_std = c(0.4, 0.3, 0.2),
      r_squared = 0.25,
      iv_cormatrix = iv_corr,
      iv_means = c(3, 3, 3),
      iv_sds = c(1, 1), # too short
      dv_mean = 4,
      dv_sd = 1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5
    ),
    regexp = "iv_means and iv_sds must have same length as beta_std"
  )
})

test_that("makeScalesRegression: var_names length mismatch throws error", {
  set.seed(4)
  iv_corr <- diag(2)

  testthat::expect_error(
    makeScalesRegression(
      n = 50L,
      beta_std = c(0.4, 0.3),
      r_squared = 0.30,
      iv_cormatrix = iv_corr,
      iv_means = c(3, 3.5),
      iv_sds = c(1, 1),
      dv_mean = 4,
      dv_sd = 1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5,
      var_names = c("TooFew", "NamesOnly") # length 2 instead of k+1 = 3
    ),
    regexp = "var_names must have length k\\+1"
  )
})


test_that("print.makeScalesRegression produces informative output", {
  set.seed(321)

  iv_corr <- matrix(c(1.0, 0.3, 0.3, 1.0), nrow = 2, byrow = TRUE)

  res <- suppressWarnings(
    makeScalesRegression(
      n = 40L,
      beta_std = c(0.4, 0.3),
      r_squared = 0.35,
      iv_cormatrix = iv_corr,
      iv_means = c(3.0, 3.5),
      iv_sds = c(1.0, 0.9),
      dv_mean = 3.8,
      dv_sd = 1.1,
      lowerbound_iv = 1,
      upperbound_iv = 5,
      lowerbound_dv = 1,
      upperbound_dv = 5,
      items_iv = 4,
      items_dv = 4,
      var_names = c("Attitude", "Intention", "Behaviour")
    )
  )

  out <- capture.output(print(res))

  testthat::expect_true(any(grepl("Regression Data Generation Results", out)))
  testthat::expect_true(any(grepl("Target R-squared", out)))
  testthat::expect_true(any(grepl("Achieved R-squared", out)))

  # print() should return the object invisibly
  testthat::expect_invisible(print(res))
})
