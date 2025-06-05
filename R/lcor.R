#' Rearrange elements in each column of a data-frame to fit a
#' predefined correlation matrix
#'
#' @name lcor
#'
#' @useDynLib LikertMakeR
#'
#' @importFrom Rcpp sourceCpp
#'
#' @description \code{lcor()} rearranges values in each column of a
#' data-frame so that columns are correlated to match a predefined
#' correlation matrix.
#'
#' @details Values in a column do not change, so univariate
#' statistics remain the same.
#'
#' @param data data-frame that is to be rearranged
#'
#' @param target target correlation matrix.
#' Must have same dimensions as number of columns in data-frame.
#'
<<<<<<< HEAD
#' @param passes number of passes when searching for suitable permutation.
#' Default = 10.
#' You _may_ get a better result if dealing with a large number of columns.
#'
#' @return Returns a data frame whose column-wise correlations
=======
#' @param passes Number of optimization passes (default = 10)
#' Increasing this value *MAY* improve results if n-columns
#' (target correlation matrix dimensions) are many.
#'
#' @return Returns a dataframe whose column-wise correlations
>>>>>>> 3d74fa4cd51d231e275d7d13e6348f51946f84d7
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
#'   ),
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
<<<<<<< HEAD
lcor <- function(data, target, passes = 10L) {
=======
lcor <- function(data, target, passes = 10) {
>>>>>>> 3d74fa4cd51d231e275d7d13e6348f51946f84d7
  .Call("_LikertMakeR_lcor_C_randomised", data, target, passes, PACKAGE = "LikertMakeR") |>
    data.frame()
}
