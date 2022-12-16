#' Generate rating-scale data with only Mean and Standard Deviation
#' @name lexact
#' @description \code{lexact()} generates rating-scale values with
#' predefined first and second moments.
#'
#' @details If feasible, moments are exact to two decimal places.
#'
#'
#' @param n the number of observations to simulate
#' @param mean target mean
#' @param sd target standard deviation
#' @param lowerbound a lower bound for the data to be generated
#' @param upperbound an upper bound for the data to be generated
#' @param items number of items in the Likert scale. Default = 1
#' @param seed optional seed for reproducibility
#'
#' @return a vector of simulated data with user-specified mean and standard deviation.
#'
#' @importFrom DEoptim DEoptim
#' @importFrom DEoptim DEoptim.control
#' @import parallelly
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
##
## Create lexact function
lexact <- function(n, mean, sd, lowerbound, upperbound, items = 1, seed) {
  min <- lowerbound * items
  max <- upperbound * items
  mean <- mean * items
  target_sd <- sd * items

  ## idiot check
  if (mean <= min || mean >= max) {
    stop("ERROR: mean is out of range")
  }
  if (target_sd >= (max - min) * 0.6) {
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

  if (missing(seed)) {
  } else {
    set.seed(seed)
  }
  ## run the optimisation algorithm
  ## this can take some time
  my_vector <- DEoptim::DEoptim(opt_scale, lower, upper,
    control = DEoptim::DEoptim.control(
      itermax = itermax,
      trace = FALSE,
      parallelType = "parallel"
    ),
    fnMap = fnmap_f
  )

  my_best <- summary(my_vector)
  my_data <- my_best[["optim"]][["bestmem"]] / items
  row.names(my_data) <- NULL

  return(my_data)
}
