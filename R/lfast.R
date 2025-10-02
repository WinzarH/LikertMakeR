#' Synthesise rating-scale data with predefined mean and standard deviation
#'
#' @name lfast
#'
#' @description `lfast()` applies a simple Evolutionary Algorithm to
#' find a vector that best fits the desired moments.
#'
#' `lfast()` generates random discrete values from a
#' scaled Beta distribution so the data replicate a rating scale -
#' for example, a 1-5 Likert scale made from 5 items (questions) or 0-10
#' likelihood-of-purchase scale.
#'
#'
#'
#' @param n (positive, int) number of observations to generate
#' @param mean (real) target mean, between upper and lower bounds
#' @param sd  (positive, real) target standard deviation
#' @param lowerbound (int) lower bound (e.g. '1' for a 1-5 rating scale)
#' @param upperbound (int) upper bound (e.g. '5' for a 1-5 rating scale)
#' @param items (positive, int) number of items in the rating scale. Default = 1
#' @param precision (positive, real) can relax the level of accuracy required.
#' (e.g. '1' generally generates a vector with moments correct within '0.025',
#' '2' generally within '0.05') Default = 0
#'
#' @return a vector approximating user-specified conditions.
#'
#' @importFrom stats rbeta
#'
#' @export lfast
#'
#' @examples
#'
#' ## six-item 1-7 rating scale
#' x <- lfast(
#'   n = 256,
#'   mean = 4.0,
#'   sd = 1.25,
#'   lowerbound = 1,
#'   upperbound = 7,
#'   items = 6
#' )
#'
#' ## five-item -3 to +3 rating scale
#' x <- lfast(
#'   n = 64,
#'   mean = 0.025,
#'   sd = 1.25,
#'   lowerbound = -3,
#'   upperbound = 3,
#'   items = 5
#' )
#'
#' ## four-item 1-5 rating scale with medium variation
#' x <- lfast(
#'   n = 128,
#'   mean = 3.0,
#'   sd = 1.00,
#'   lowerbound = 1,
#'   upperbound = 5,
#'   items = 4,
#'   precision = 5
#' )
#'
#' ## eleven-point 'likelihood of purchase' scale
#' x <- lfast(256, 3, 3.0, 0, 10)
#'
lfast <- function(n, mean, sd,
                  lowerbound, upperbound,
                  items = 1, precision = 0) {
  tolerance <- 0.0025 * 2^precision
  range <- upperbound - lowerbound
  m <- (mean - lowerbound) / range ## rescale mean
  s <- sd / range ## rescale sd
  ## idiot checks
  if (mean <= lowerbound || mean >= upperbound) {
    stop("ERROR: mean is out of range")
  }
  if (sd >= range * 0.6) {
    warning("Standard Deviation is large relative to range
            \nDerived SD may be less than specified
            \nOr the solution is not feasible, producing 'NA' values")
  }
  ## Beta distribution shape parameters
  a <- (m^2 - m^3 - m * s^2) / s^2 ## alpha shape parameter
  b <- (m - 2 * m^2 + m^3 - s^2 + m * s^2) / s^2 ## beta shape parameter

  best_value <- 1e+5 ## set high value to start
  best_vector <- rep(1e+5, n) ## set high value to start
  maxiter <- max(1024, n^2) ## at least 2^10 iterations

  for (i in 1:maxiter) {
    ## generate data with range 0-1 as Beta distribution
    item_vector <- rbeta(n, a, b)
    ## rescale Beta values to desired parameters
    item_vector <- round((item_vector * range + lowerbound) * items) / items

    ## difference between target moments and actual moments
    mean_dif <- mean(item_vector) - mean
    sd_dif <- sd(item_vector) - sd
    temp_value <- abs(mean_dif) + abs(sd_dif) ## simple figure to be minimised

    ## keep the best result so far
    if (temp_value < best_value) {
      best_vector <- item_vector
      best_value <- temp_value
    } else {
      next
    }

    ## tolerance ensures both mean and sd accurate to 2 decimal places
    if (best_value < tolerance) {
      break
    }
  }

  ## print iterations reached
  if (i == maxiter) {
    message(paste0("reached maximum of ", i, " iterations"))
  } else {
    message(paste0("best solution in ", i, " iterations"))
  }

  return(best_vector)
}
