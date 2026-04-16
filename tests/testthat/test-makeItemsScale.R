## Unit tests for makeItemsScale() function

test_that("makeItemsScale runs silently with valid inputs", {
  ## define parameters

  myvalues <- c(2.25, 3.75, 2.50, 2.50, 4.25, 2.50, 4.25, 4.00)

  ## apply function test

  expect_no_warning(makeItemsScale(
    scale = myvalues,
    lowerbound = 1,
    upperbound = 5,
    items = 4,
    summated = FALSE
  ))
})
