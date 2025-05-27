## Unit tests for makeItems() function

test_that("makeItems runs silently with valid inputs", {
  ## define parameters
  n <- 16
  lowerbound <- rep(1, 4)
  upperbound <- rep(5, 4)

  dfMeans <- c(2.5, 3.0, 3.0, 3.5)
  dfSds <- c(1.0, 1.0, 1.5, 0.75)

  corMat <- matrix(
    c(
      1.00, 0.25, 0.35, 0.40,
      0.25, 1.00, 0.70, 0.75,
      0.35, 0.70, 1.00, 0.80,
      0.40, 0.75, 0.80, 1.00
    ),
    nrow = 4, ncol = 4
  )

  ## apply function test

  expect_no_warning(makeItems(
    n = n,
    lowerbound = lowerbound,
    upperbound = upperbound,
    means = dfMeans,
    sds = dfSds,
    cormatrix = corMat
  ))
})
