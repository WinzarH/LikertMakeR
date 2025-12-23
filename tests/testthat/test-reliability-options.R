test_that("include = lambda6 adds lambda6 row", {

  skip_if_not_installed("psych")

  set.seed(123)

  cor_mat <- LikertMakeR::makeCorrAlpha(
    items = 4,
    alpha = 0.80
  )

  dat <- LikertMakeR::makeScales(
    n = 50,
    means = c(3, 3, 3, 3),
    sds   = c(1, 1, 1, 1),
    lowerbound = rep(1, 4),
    upperbound = rep(5, 4),
    cormatrix = cor_mat
  )

  res <- reliability(dat, include = "lambda6")

  expect_true("lambda6" %in% res$coef_name)
})


test_that("polychoric requested but skipped produces NA ordinal estimates", {

  set.seed(123)

  # force sparsity
  dat <- data.frame(
    i1 = c(rep(1, 49), 5),
    i2 = sample(1:5, 50, replace = TRUE),
    i3 = sample(1:5, 50, replace = TRUE),
    i4 = sample(1:5, 50, replace = TRUE)
  )

  res <- reliability(
    dat,
    include = "polychoric",
    verbose = FALSE
  )

  expect_true("ordinal_alpha" %in% res$coef_name)
  expect_true(all(is.na(res$estimate[res$coef_name == "ordinal_alpha"])))
  expect_true(!is.null(attr(res, "ordinal_diagnostics")))
})
