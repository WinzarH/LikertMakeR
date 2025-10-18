## Unit tests for makePaired() function

test_that("makePaired runs without error with valid inputs", {
  n <- 20
  means <- c(2.5, 3.0)
  sds <- c(1.0, 1.5)
  lowerbound <- 1
  upperbound <- 5
  items <- 6
  t <- -2.5

  expect_no_error(
    pairedDat <- makePaired(
      n = n,
      means = means,
      sds = sds,
      lowerbound = lowerbound,
      upperbound = upperbound,
      items = items,
      t_value = t
    )
  )
})


test_that("makePaired runs with errors with unrealistic inputs", {
  n <- 64
  means <- c(2.5, 3.0)
  sds <- c(1.0, 1.5)
  lowerbound <- 1
  upperbound <- 5
  items <- 6
  t <- 0.5

  expect_error(
    pairedDat <- makePaired(
      n = n,
      means = means,
      sds = sds,
      lowerbound = lowerbound,
      upperbound = upperbound,
      items = items,
      t_value = t
    )
  )
})
