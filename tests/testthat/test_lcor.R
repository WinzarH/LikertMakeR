## context("check-output") 
library(testthat) # load testthat package
library(LikertMakeR) # load our package

## generate data
x1 <- lexact(64, 3.5, 1.00, 1, 5, 5)
x2 <- lexact(64, 2.5, 0.75, 1, 5, 5)
x3 <- lexact(64, 3.0, 1.50, 1, 5, 5)
mydat3 <- cbind(x1, x2, x3) |> data.frame()

## describe target correlation matrix
tgt3 <- matrix(
  c(
    1.00, 0.50, 0.75,
    0.50, 1.00, 0.60,
    0.75, 0.60, 1.00
  ),
  nrow = 3
)


# Test whether the output is a data frame
test_that("lcor() returns a data frame", {
  ## generate data
  x1 <- lexact(64, 3.5, 1.00, 1, 5, 5)
  x2 <- lexact(64, 2.5, 0.75, 1, 5, 5)
  x3 <- lexact(64, 3.0, 1.50, 1, 5, 5)
  mydat3 <- cbind(x1, x2, x3) |> data.frame()
  
  ## describe target correlation matrix
  tgt3 <- matrix(
    c(
      1.00, 0.50, 0.75,
      0.50, 1.00, 0.60,
      0.75, 0.60, 1.00
    ),
    nrow = 3
  )
  
  new3 <- lcor(data = mydat3, target = tgt3)
  
  expect_type(new3, 'list')
})

## Test whether the output contains the right number of rows
test_that("lcor() returns a dataframe with correct number of rows", {

  ## generate data
  x1 <- lexact(64, 3.5, 1.00, 1, 5, 5)
  x2 <- lexact(64, 2.5, 0.75, 1, 5, 5)
  x3 <- lexact(64, 3.0, 1.50, 1, 5, 5)
  mydat3 <- cbind(x1, x2, x3) |> data.frame()
  
  ## describe target correlation matrix
  tgt3 <- matrix(
    c(
      1.00, 0.50, 0.75,
      0.50, 1.00, 0.60,
      0.75, 0.60, 1.00
    ),
    nrow = 3
  )
  
  new3 <- lcor(data = mydat3, target = tgt3)
  
  expect_equal(nrow(new3), nrow(mydat3))
})


test_that("lcor() returns a dataframe with columns that are correlated close to target matrix", {
  
  ## generate data
  x1 <- lexact(64, 3.5, 1.00, 1, 5, 5)
  x2 <- lexact(64, 2.5, 0.75, 1, 5, 5)
  x3 <- lexact(64, 3.0, 1.50, 1, 5, 5)
  mydat3 <- cbind(x1, x2, x3) |> data.frame()
  
  ## describe target correlation matrix
  tgt3 <- matrix(
    c(
      1.00, 0.50, 0.75,
      0.50, 1.00, 0.60,
      0.75, 0.60, 1.00
    ),
    nrow = 3
  )
  
  new3 <- lcor(data = mydat3, target = tgt3)
  
  newmat3 <- cor(new3) |> round(2)
  testthat::expect_setequal(newmat3, tgt3)
})

