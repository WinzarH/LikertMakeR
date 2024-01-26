#' Generate rating-scale data with only Mean and Standard Deviation
#' @name lexact
#' @description \code{lexact()} generates rating-scale values with
#' predefined first and second moments.
#'
#' @details If feasible, moments are exact to two decimal places.
#'
#'
#' @param n (positive, int) the number of observations to simulate
#' @param mean (real)  target mean
#' @param sd (real)  target standard deviation
#' @param lowerbound (positive, int) a lower bound for the data to be generated
#' @param upperbound (positive, int) an upper bound for the data to be generated
#' @param items (positive, int) number of items in the Likert scale. Default = 1
#' @param seed (real)  optional seed for reproducibility
#'
#' @return a vector with user-specified parameters
#'
#' @importFrom DEoptim DEoptim
#' @importFrom DEoptim DEoptim.control
#'
#' @export lexact
#'
#' @examples
#'
#' x <- lexact(
#'   n = 16,
#'   mean = 3.25,
#'   sd = 1.00,
#'   lowerbound = 1,
#'   upperbound = 5,
#'   items = 4
#' )
#'
#'
#' eleven_point <- lfast(32, 3.0, 2.0, 0, 10)
#'
#' positive_negative <- lfast(32, 0.5, 2.0, -3, 3)
#'
##
## Create lexact function
lexact <- function(n, mean, sd, lowerbound, upperbound, items = 1, seed = NULL) {
  min <- lowerbound * items
  max <- upperbound * items
  mean <- mean * items
  target_sd <- sd * items

  ## idiot check
  if (mean <= min || mean >= max) {
    stop("ERROR: mean is out of range")
  }
  if (target_sd >= (max - min) * 0.5) {
    warning("Standard Deviation is large relative to range
            \nDerived SD will be less than specified")
  }
  ##
  ## define target statistic to be minimised
  ## Two parameters must be optimised: mean & sd.
  ## Difference between mean & target mean, and
  ## difference between sd & target sd.
  ## Target statistic is the sum of the differences,
  ## with a slight advantage to mean.
  ##
  opt_scale <- function(x) {
    target_stat <- ((mean - mean(x)) * 200)^2 + ((target_sd - sd(x)) * 100)^2
    return(target_stat)
  }
  lower <- rep(min, each = n)
  upper <- rep(max, each = n)
  itermax <- n * 10
  fnmap_f <- function(x) round(x) ## integer output

  ## run the optimisation algorithm
  ## this can take some time
  my_vector <- DEoptim::DEoptim(opt_scale, lower, upper,
    control = DEoptim::DEoptim.control(
      VTR = 0,
      strategy = 2,
      itermax = itermax,
      trace = FALSE,
      parallelType = "none"
    ),
    fnMap = fnmap_f
  )

  my_best <- summary(my_vector)
  my_data <- my_best[["optim"]][["bestmem"]] / items
  row.names(my_data) <- NULL

  return(my_data)
}
