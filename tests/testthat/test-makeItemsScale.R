## Unit tests for makeItemsScale() function

test_that("makeItemsScale runs silently with valid inputs", {
  ## define parameters

  lowerbound <- 1
  upperbound <- 5
  items <- 4

  myvalues <- c((lowerbound * items):(upperbound * items))

  ## apply function test

  expect_no_warning(makeItemsScale(
    scale = myvalues,
    lowerbound = lowerbound,
    upperbound = upperbound,
    items = items
  ))
})
