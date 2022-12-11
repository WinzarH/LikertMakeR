#' Rating scale data (e.g. Likert scale) from a Scaled Beta Distribution
#' @name lfast
#' @description \code{lfast()} generates random discrete values from a
#' (scaled Beta distribution) so the data replicate a rating scale -
#' for example,a 1-5 scale made from 5 items (questions) or 0-10
#' likelihood-of-purchase scale.
#'
#'
#'
#' @param n number of observations to generate
#' @param mean target mean
#' @param sd target standard deviation
#' @param lowerbound lower bound (e.g. '1' for a 1-5 rating scale)
#' @param upperbound upper bound (e.g. '5' for a 1-5 rating scale)
#' @param items number of items in the rating scale. Default = 1
#' @param seed optional seed for reproducibility
#'
#' @return a vector of simulated data approximating user-specified conditions.
#'
#' @export lfast
#' @export tibble
#'
#' @examples
#'
#' x <- lfast(
#'   n = 256,
#'   mean = 4.0,
#'   sd = 1.0,
#'   lowerbound = 1,
#'   upperbound = 7,
#'   items = 6
#' )
#'
#' x <- lfast(256, 2, 1.8, 0, 10)
#'
#' x <- lfast(256, 2, 1.0, 1, 5, 5)
#'
lfast <- function(n, mean, sd, lowerbound, upperbound, items = 1, seed) {
  range <- upperbound - lowerbound
  m <- (mean - lowerbound) / range ## rescale mean
  s <- sd / range ## rescale sd

  a <- (m^2 - m^3 - m * s^2) / s^2 ## alpha shape parameter
  b <- (m - 2 * m^2 + m^3 - s^2 + m * s^2) / s^2 ## beta shape parameter
  if (missing(seed)) {
  } else {
    set.seed(seed)
  }
  ## generate data with range 0-1 as Beta distribution
  data <- rbeta(n, a, b)
  ## rescale Beta values to desired parameters
  data <- round((data * range + lowerbound) * items) / items

  return(data)
}
