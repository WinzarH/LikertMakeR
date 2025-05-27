## Unit tests for eigenvalues() function

test_that("eigenvalues runs silently with valid inputs", {
  ## define parameters

  correlationMatrix <- matrix(
    c(
      1.00, 0.25, 0.35, 0.40,
      0.25, 1.00, 0.70, 0.75,
      0.35, 0.70, 1.00, 0.80,
      0.40, 0.75, 0.80, 1.00
    ),
    nrow = 4, ncol = 4
  )


  ## apply function examples

  expect_no_warning(eigenvalues(cormatrix = correlationMatrix))

  expect_no_warning(eigenvalues(correlationMatrix, 1))
})
