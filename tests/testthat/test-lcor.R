## Unit tests for lcor() function



test_that("lcor runs silently with valid inputs", {
  n <- 32


  tgt4 <- matrix(
    c(
      1.00, 0.50, 0.50, 0.75,
      0.50, 1.00, 0.25, 0.65,
      0.50, 0.25, 1.00, 0.80,
      0.75, 0.65, 0.80, 1.00
    ),
    nrow = 4
  )

  set.seed(42)

  dat4 <- data.frame(
    x1 = sample(c(1:5), n, replace = TRUE),
    x2 = sample(c(1:5), n, replace = TRUE),
    x3 = sample(c(1:5), n, replace = TRUE),
    x4 = sample(c(1:5), n, replace = TRUE)
  )


  expect_silent(
    lcor(data = dat4, target = tgt4)
  )
})


test_that("lcor runs without errors", {
  n <- 32


  tgt4 <- matrix(
    c(
      1.00, 0.50, 0.50, 0.75,
      0.50, 1.00, 0.25, 0.65,
      0.50, 0.25, 1.00, 0.80,
      0.75, 0.65, 0.80, 1.00
    ),
    nrow = 4
  )

  set.seed(42)

  dat4 <- data.frame(
    x1 = sample(c(1:5), n, replace = TRUE),
    x2 = sample(c(1:5), n, replace = TRUE),
    x3 = sample(c(1:5), n, replace = TRUE),
    x4 = sample(c(1:5), n, replace = TRUE)
  )


  expect_error(
    lcor(data = dat4, target = tgt4),
    regexp = NA
  )
})
