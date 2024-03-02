## Unit tests for alpha() function

test_that("alpha runs silently with valid inputs", {
  ## example data frame
  df <- data.frame(
    V1  =  c(4, 2, 4, 3, 2, 2, 2, 1),
    V2  =  c(4, 1, 3, 4, 4, 3, 2, 3),
    V3  =  c(4, 1, 3, 5, 4, 1, 4, 2),
    V4  =  c(4, 3, 4, 5, 3, 3, 3, 3)
  )

  ## example correlation matrix
  corMat <- matrix(
    c(
      1.00, 0.35, 0.45, 0.70,
      0.35, 1.00, 0.60, 0.55,
      0.45, 0.60, 1.00, 0.65,
      0.70, 0.55, 0.65, 1.00
    ),
    nrow = 4, ncol = 4
  )

  ## apply function examples

  expect_no_warning(alpha(corMat))

  expect_no_warning(alpha(corMat, df))

  expect_no_warning(alpha(NULL, df))
})
