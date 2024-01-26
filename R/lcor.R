#' Rearrange columns in a data-frame to fit a predefined correlation matrix
#'
#' @name lcor
#'
#' @description \code{lcor()} rearranges values in each column of a
#' data-frame so that columns are correlated to match a predefined
#' correlation matrix.
#'
#' @details Values in a column do not change, so univariate
#' statistics remain the same.
#'
#'
#' @param data data-frame that is to be rearranged
#' @param target target correlation matrix - should be a symmetric
#' (square) k*k matrix
#'
#' @return Returns a data-frame whose column-wise correlations
#' approximate a user-specified correlation matrix
#'
#' @importFrom stats cor
#' @importFrom stats rbeta
#'
#' @export lcor
#'
#' @examples
#'
#' ## generate uncorrelated synthetic data
#'
#' n <- 32
#' lowerbound <- 1
#' upperbound <- 5
#' items <- 5
#'
#' mydat3 <- data.frame(
#'   x1 = lexact(n, 2.5, 0.75, lowerbound, upperbound, items),
#'   x2 = lexact(n, 3.0, 1.50, lowerbound, upperbound, items),
#'   x3 = lexact(n, 3.5, 1.00, lowerbound, upperbound, items)
#' )
#'
#'
#' cor(mydat3) |> round(3)
#'
#' ## describe a target correlation matrix
#' tgt3 <- matrix(
#'   c(
#'     1.00, 0.50, 0.75,
#'     0.50, 1.00, 0.25,
#'     0.75, 0.25, 1.00
#'   ),
#'   nrow = 3, ncol = 3
#' )
#'
#' ## apply lcor function
#' new3 <- lcor(mydat3, tgt3)
#'
#' cor(new3) |> round(3)
#'
lcor <- function(data, target) {
  current_dat <- data
  target_cor <- target

  #### idiot checks
  if (ncol(target_cor) != nrow(target_cor)) {
    stop("ERROR:
         \ntarget correlation matrix should be a square matrix,
         \nwith symetrical upper and lower triangles and '1' in the diagonal")
  }
  # Check if the diagonal has all 1s
  if (!all(diag(target_cor) == 1)) {
    stop("ERROR:
         \nDiagonal should be all '1'.")
  }
  # Check if the lower triangle mirrors the upper triangle
  if (!all(target_cor == t(target_cor))) {
    stop("ERROR:
         \nLower triangle does not mirror the upper triangle.")
  }
  # Check if values range from -1 to +1
  if (any(target_cor < -1) || any(target_cor > 1)) {
    stop("Correlations must range between -1 to +1.")
  }
  if (ncol(target_cor) != ncol(current_dat)) {
    stop("ERROR:
         \ndimensions of target correlation matrix should match
         \nthe number of columns in the data-frame")
  }
  ## test for positive-definite correlation matrix
  eigen_values <- eigen(target_cor)$values
  is_positive_definite <- any(eigen_values >= 0)
  if (is_positive_definite == FALSE) {
    stop("ERROR: \nTarget correlation matrix is not positive definite.
	\nSome requested correlations are impossible")
  }
  #### end idiot checks


  n <- nrow(current_dat)
  nc <- ncol(current_dat)

  current_cor <- cor(current_dat)
  multiplier <- 1000
  diff.score <- sum((abs(target_cor - current_cor)) * multiplier)


  ## generate a complete list of value-pairs as switch candidates
  y1 <- expand.grid(c(1:n), c(1:n))
  ## no need to switch with yourself so we can remove these pairs
  y1 <- subset(y1, y1[, 1] != y1[, 2])
  ## shuffle rows for cases where data are systematically ordered
  ye <- y1[sample(nrow(y1)), ]
  ny <- nrow(ye)

  ## Within each column we select a pair of values and swap their places,
  ## then check if this improves the fit between the data correlation
  ## matrix and target correlation matrix.
  ## Repeat until all row-swaps within all columns are complete.
  ##
  ## begin column selection loop
  ## for each column in the data set ...
  for (r in 1:ny) {
    ## Other columns are relative to first column
    ## so we can save a little time skipping this column
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
      new.diff.score <- sum((abs(target_cor - cor(current_dat))) * multiplier)
      if (new.diff.score < diff.score) {
        ## update data-frame and target statistic
        current_cor <- cor(current_dat)
        diff.score <- new.diff.score
      } else {
        ## swap values back
        current_dat[i, colID] <- ii
        current_dat[j, colID] <- jj
      }
    } ## end row values swap loop
  } ## end column selection loop

  return(current_dat)
} ## end lcor function
