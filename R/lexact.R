#' Deprecated. Use lfast() instead
#'
#' @name lexact
#'
#' @description \code{lexact} is DEPRECATED. Replaced by new version of
#'  \code{lfast}.
#'
#' \code{lexact} remains as a legacy for earlier package users.
#' It is now just a wrapper for \code{lfast}
#'
#' Previously, \code{lexact} used a Differential Evolution (DE) algorithm to
#' find an optimum solution with desired mean and standard deviation,
#' but we found that the updated \code{lfast} function is much faster and just
#' as accurate.
#'
#' Also the package is much less bulky.
#'
#' @param n (positive, int) number of observations to generate
#' @param mean (real) target mean
#' @param sd  (real) target standard deviation
#' @param lowerbound (positive, int) lower bound
#' @param upperbound (positive, int) upper bound
#' @param items (positive, int) number of items in the rating scale.
#'
#' @return a vector of simulated data approximating user-specified conditions.
#'
#' @importFrom stats rbeta
#'
#' @export lexact
#'
#' @examples
#'
#' x <- lexact(
#'   n = 256,
#'   mean = 4.0,
#'   sd = 1.0,
#'   lowerbound = 1,
#'   upperbound = 7,
#'   items = 6
#' )
#'
#' x <- lexact(256, 2, 1.8, 0, 10)
#'
lexact <- function(n, mean, sd, lowerbound, upperbound, items = 1) {
  message("lexact() function is deprecated.
          \nUsing the more efficient lfast() function instead")
  lfast(
    n = n, mean = mean, sd = sd,
    lowerbound = lowerbound, upperbound = upperbound, items = items
  )
}
