#' A C++ implementation of the lcor() function to rearrange columns
#' in a data-frame to fit a predefined correlation matrix
#'
#' @name lcor_C
#'
#' @description \code{lcor_C()} rearranges values in each column of a
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
#' @export lcor_C
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
#'   x1 = lfast(n, 2.5, 0.75, lowerbound, upperbound, items),
#'   x2 = lfast(n, 3.0, 1.50, lowerbound, upperbound, items),
#'   x3 = lfast(n, 3.5, 1.00, lowerbound, upperbound, items)
#' )
#'
#' ### check correlation
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
#' ## apply lcor_C function
#' # new3 <- lcor_C(mydat3, tgt3)
#'
#' ### check new correlation
#' # cor(new3) |> round(3)
#'
lcor_C <- function(data, target) {
  .Call('_LikertMakeR_lcor_C', data, target, PACKAGE = 'LikertMakeR')
}

 ## end lcor_C function
