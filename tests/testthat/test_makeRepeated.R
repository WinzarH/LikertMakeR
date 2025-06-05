## Unit tests for makeRepeated() function

test_that("makeRepeated returns expected structure", {
  set.seed(42)

  result <- makeRepeated(
    n = 100,
    k = 3,
    means = c(3.1, 3.5, 3.9),
    sds = c(1.0, 1.1, 1.0),
    f_stat = 15,
    structure = "cs",
    diagnostics = TRUE
  )

  # Test class and structure of output
  expect_type(result, "list")
  expect_true(all(c("data", "correlation_matrix", "structure") %in% names(result)))

  # Check data frame shape and column names
  expect_s3_class(result$data, "data.frame")
  expect_equal(ncol(result$data), 3)
  expect_equal(nrow(result$data), 100)
  expect_equal(colnames(result$data), paste0("time_", 1:3))

  # Check correlation matrix
  expect_true(is.matrix(result$correlation_matrix))
  expect_equal(dim(result$correlation_matrix), c(3, 3))
  expect_true(all(diag(result$correlation_matrix) == 1))

  # Check structure is correctly labeled
  expect_equal(result$structure, "cs")

  # Check diagnostics elements exist
  expect_true(all(c("feasible_f_range", "recommended_f", "achieved_f") %in% names(result)))
  expect_type(result$feasible_f_range, "double")
  expect_type(result$recommended_f, "list")
})

test_that("makeRepeated returns only correlation matrix when requested", {
  result <- makeRepeated(
    n = 50,
    k = 4,
    means = c(2.5, 3.0, 3.2, 3.6),
    sds = c(0.9, 1.0, 1.0, 0.95),
    f_stat = 14.0,
    structure = "ar1",
    return_corr_only = TRUE
  )

  expect_type(result, "list")
  expect_named(result, c("correlation_matrix", "structure"))
  expect_true(is.matrix(result$correlation_matrix))
  expect_equal(dim(result$correlation_matrix), c(4, 4))
})

test_that("makeRepeated catches invalid input", {
  expect_error(
    makeRepeated(n = 100, k = 3, means = c(3.1, 3.5), sds = c(1, 1, 1), f_stat = 4.5),
    "Length of 'means' must equal k"
  )

  expect_error(
    makeRepeated(n = 100, k = 3, means = c(3.1, 3.5, 3.9), sds = c(1, 1), f_stat = 4.5),
    "Length of 'sds' must equal k"
  )

  expect_error(
    makeRepeated(n = 100, k = 3, means = c(3.1, 3.5, 3.9), sds = c(1, 1, 1), f_stat = -2),
    "F-statistic must be positive"
  )

  expect_error(
    makeRepeated(n = 1, k = 3, means = c(3.1, 3.5, 3.9), sds = c(1, 1, 1), f_stat = 4.5),
    "Sample size.*must be > 1"
  )
})
