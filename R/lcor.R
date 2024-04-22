#' Rearrange columns in a data-frame to fit a predefined correlation matrix
#'
#' @name lcor
#'
#' @useDynLib LikertMakeR
#'
#' @importFrom Rcpp sourceCpp
NULL
#' @description \code{lcor_C()} rearranges values in each column of a
#' data-frame so that columns are correlated to match a predefined
#' correlation matrix.
#'
#' @details Values in a column do not change, so univariate
#' statistics remain the same.
#'
#' @param data data-frame that is to be rearranged
#' @param target target correlation matrix - should be a symmetric
#' k*k positive-semi-definite matrix
#'
#' @return Returns a dataframe whose column-wise correlations
#' approximate a user-specified correlation matrix
#'
#' @examples
#'
#' ## parameters
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
#' cor(mydat3) |> round(3)
#'
#' tgt3 <- matrix(
#'   c(
#'     1.00, 0.50, 0.75,
#'     0.50, 1.00, 0.25,
#'     0.75, 0.25, 1.00
#'     ),
#'   nrow = 3, ncol = 3
#' )
#'
#' ## apply function
#' new3 <- lcor(mydat3, tgt3)
#'
#' ## test output
#' cor(new3) |> round(3)
#'
#' @importFrom stats cor
#' @importFrom stats rbeta
#'
#' @export
lcor <- function(data, target) {
  .Call('_LikertMakeR_lcor_C', data, target, PACKAGE = 'LikertMakeR')
}
