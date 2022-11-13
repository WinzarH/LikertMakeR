#' Rating scale data (e.g. Likert scale) from a Scaled Beta Distribution
#' @name lfast
#' @description \code{lfast()} is a function to randomly generate discrete values from a (scaled beta distribution).
#'
#' @details \code{lfast()} is adapted from the \code{rbnorm()} function in Steve Miller's (stevemisc) package at (https://github.com/svmiller/stevemisc).
#'
#' @details A Likert scale is the mean, or sum, of several ordinal rating scales.
#' They are bipolar (usually “agree-disagree”) responses to propositions that are determined to be moderately-to-highly correlated and capturing various facets of a construct.
#'
#' @details Rating scales are not continuous or unbounded.
#' For example, a 5-point Likert scale that is constructed with, say, five items (questions) will have a summed range of between 5 (all rated ‘1’) and 25 (all rated ‘5’) with all integers in between, and the mean range will be ‘1’ to ‘5’ with intervals of 1/5=0.20.
#' A 7-point Likert scale constructed from eight items will have a summed range between 8 (all rated ‘1’) and 56 (all rated ‘7’) with all integers in between, and the mean range will be ‘1’ to ‘7’ with intervals of 1/8=0.125
#'
#'
#' @param n the number of observations to simulate
#' @param mean a mean to approximate
#' @param sd a standard deviation to approximate
#' @param lowerbound a lower bound for the scale (e.g. '1' for a 1-5 rating scale)
#' @param upperbound an upper bound for the scale (e.g. '5' for a 1-5 rating scale)
#' @param items number of items in the rating scale. Default = 1
#' @param seed optional seed for reproducibility
#'
#' @return a vector of simulated data approximating the user-specified conditions.
#'
#' @export lfast
#' @export tibble
#'
#' @examples
#'
#' x <- lfast(n = 256, mean = 4.5, sd = 1.0, lowerbound = 1, upperbound = 7, items = 6)
#'
#' x <- lfast(256, 2, 1.8, 0, 10, seed = 42)
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
