## likertMakeR
##

#' Rearrange columns in a data-frame to fit a predefined correlation matrix
#'
#' @name lcor
#'
#' @description \code{lcor()} is a function to  rearrange values in each column so that columns are correlated to match a predefined correlation matrix.
#'
#' @details Values in a column do not change, so univariate statistics remain the same, but they are rearranged.
#'
#' @details \code{lcor()} systematically selects pairs of values in a column and swaps their places, and checks to see if this swap improves the correlation matrix. If so, the swap is retained. Otherwise, the values are returned to their original places. This process is iterated across each column. A large dataframe can take some time.
#'
#' @details Value pairs are evaluated one pair at a time, so a vectorised process is infeasible at present. I am working on a faster loop solution using compiled code.
#'
#' @param data beginning data-frame that is to be rearranged
#' @param target target correlation matrix - should be a symmetric (square) k*k matrix, where k=n_columns of the data file
#'
#' @return Returns a dataframe whose column-wise correlations approximate a user-specified correlation matrix.
#'
#' @export lcor
#' @export tibble
#'
#' @examples
#'
#' ## generate uncorrelated synthetic data
#' set.seed(42)
#' x1 <- lexact(64, 3.5, 1.0, 1, 5, 5)
#' x2 <- lexact(64, 1.5, 0.75, 1, 5, 5)
#' x3 <- lexact(64, 3.0, 2.0, 1, 5, 5)
#' x4 <- lexact(64, 2.5, 1.5, 1, 5, 10)
#' mydat4 <- cbind(x1, x2, x3, x4) |> data.frame()
#' cor(mydat4)
#'
#' ## describe a target correlation matrix
#' tgt4 <- matrix(
#'   c(
#'     1.00, 0.50, 0.50, 0.75,
#'     0.50, 1.00, 0.25, 0.65,
#'     0.50, 0.25, 1.00, 0.80,
#'     0.75, 0.65, 0.80, 1.00
#'   ),
#'   nrow = 4
#' )
#'
#' ## apply lcor function
#' new4 <- lcor(mydat4, tgt4)
#'
#' cor(new4) |> round(3)
#'
#' ## ---
#' mydat3 <- cbind(x1, x2, x3) |> data.frame()
#'
#' tgt3 <- matrix(
#'   c(
#'     1.00, 0.50, 0.95,
#'     0.50, 1.00, 0.65,
#'     0.95, 0.65, 1.00
#'   ),
#'   nrow = 3
#' )
#' cor(mydat3)
#'
#' new3 <- lcor(mydat3, tgt3)
#'
#' cor(new3)
#'
#' ## ---
#'
#' tgt3 <- matrix(
#'   c(
#'     1.00, -0.50, -0.95,
#'     -0.50, 1.00, 0.60,
#'     -0.85, 0.60, 1.00
#'   ),
#'   nrow = 3
#' )
#'
#' new3 <- lcor(mydat3, tgt3)
#'
#' cor(new3) |> round(3)
#'
#' ## ---
#'
#' ## generate random data
#' n <- 128
#' x1 <- sample(c(5:25), n, replace = TRUE) / 5 ## 5-point 5-items
#' x2 <- sample(c(5:25), n, replace = TRUE) / 5 ## 5-point 5-items
#' x3 <- sample(c(6:30), n, replace = TRUE) / 6 ## 5-point 6-items
#' x4 <- sample(c(8:56), n, replace = TRUE) / 8 ## 7-point 8-items
#' x5 <- sample(c(5:35), n, replace = TRUE) / 5 ## 7-point 5-items
#' mydat5 <- cbind(x1, x2, x3, x4, x5) |> data.frame()
#'
#' tgt5 <- matrix(
#'   c(
#'     1.00, -0.10, -0.25, -0.50, -0.75,
#'     -0.10, 1.00, 0.50, 0.50, 0.50,
#'     -0.25, 0.50, 1.00, 0.50, 0.50,
#'     -0.50, 0.50, 0.50, 1.00, 0.50,
#'     -0.75, 0.50, 0.50, 0.50, 1.00
#'   ),
#'   nrow = 5
#' )
#'
#' ## (Note: this will take a little longer)
#' new5 <- lcor(mydat5, tgt5)
#'
#' cor(new5) |> round(3)
#'
lcor <- function(data, target) {
  current_dat <- data
  current_cor <- cor(current_dat)
  target_cor <- target
  diff.score <- sum((abs(target_cor - current_cor)) * 1000)
  n <- nrow(current_dat)
  nc <- ncol(current_dat)

  ## generate a complete list of value-pairs as switch candidates
  ye <- expand.grid(c(1:n), c(1:n))
  ye <- subset(ye, ye[, 1] != ye[, 2])
  ny <- nrow(ye)

  ## begin column selection loop
  for (r in 1:ny) {
    ## for each column in the data set ...
    ## Other columns are relative to first column
    ### begin row values swap loop
    for (colID in 2:nc) {
      ## locate data points to switch
      i <- ye[r, 1]
      j <- ye[r, 2]

      ## check that values in two locations are different
      if (current_dat[i, colID] == current_dat[j, colID]) {
        break
      }

      ## record values in case they need to be put back
      ii <- current_dat[i, colID]
      jj <- current_dat[j, colID]

      ## swap the values in selected locations
      current_dat[i, colID] <- jj
      current_dat[j, colID] <- ii

      ## if switched values reduce the difference between correlation
      ## matrices then keep the switch, otherwise put them back
      if (sum((abs(target_cor - cor(current_dat))) * 1000) < diff.score) {
        ## update data-frame and target statistic
        current_cor <- cor(current_dat)
        diff.score <- sum((abs(target_cor - current_cor)) * 1000)
      } else {
        ## swap values back
        current_dat[i, colID] <- ii
        current_dat[j, colID] <- jj
      }
    } ## end row values swap loop
  } ## end column selection loop
  return(current_dat)
} ## end lcor function
