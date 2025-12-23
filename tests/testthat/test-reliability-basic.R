test_that("reliability() returns a valid likert_reliability object", {

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

  res <- reliability(dat)

  # class
  expect_s3_class(res, "likert_reliability")

  # structure
  expect_true(is.data.frame(res))
  expect_true(all(c("coef_name", "estimate", "notes") %in% names(res)))

  # defaults: no CIs
  expect_false("ci_lower" %in% names(res))
  expect_false("ci_upper" %in% names(res))

  # defaults: only alpha + omega
  expect_equal(res$coef_name, c("alpha", "omega_total"))

  # attributes
  expect_identical(attr(res, "include"), "none")
  expect_false(isTRUE(attr(res, "ci")))
})
