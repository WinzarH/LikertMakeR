#' scale items from a summated scale
#'
#' @name makeItemsScale
#'
#' @description \code{makeItemsScale()} generates a random dataframe
#'  of scale items based on a predefined summated scale,
#'  such as created by the \code{lfast()} function.
#'
#'  scale, lowerbound, upperbound, items
#'
#' @param scale (int) a vector or dataframe of the summated rating scale.
#' Should range from ('lowerbound' * 'items') to ('upperbound' * 'items')
#' @param lowerbound (int) lower bound of the scale item
#' (example: '1' in a '1' to '5' rating)
#' @param upperbound (int) upper bound of the scale item
#' (example: '5' in a '1' to '5' rating)
#' @param items (positive, int) k, or number of columns to generate
#' @param variance (positive, real) standard deviation of values sampled
#' from a normally-distributed log transformation. Default = '0.5'.
#'
#' A value of '0' makes all values in the correlation matrix the same,
#' equal to the mean correlation needed to produce the desired _Alpha_.
#' A value of '2', or more, risks producing a matrix that is not positive-
#' definite, so not feasible.
#'
#' @importFrom gtools combinations permute
#' @importFrom dplyr filter arrange slice select all_of
#' @importFrom stats sd quantile
#'
#' @return a dataframe with 'items' columns and 'length(scale)' rows
#'
#' @export makeItemsScale
#'
#' @examples
#'
#' ## define parameters
#' items <- 4
#' lowerbound <- 1
#' upperbound <- 5
#'
#' ## scale properties
#' n <- 64
#' mean <- 3.5
#' sd <- 1.00
#'
#' ## create scale
#' set.seed(42)
#' meanScale <- lfast(
#'   n = n, mean = mean, sd = sd,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items
#' )
#' summatedScale <- meanScale * items
#'
#' ## create items
#' newItems <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items
#' )
#' head(newItems)
#'
#' ##
#' ## Testing Lowest value to Highest value of a scale
#' ##
#' lowerbound <- 1
#' upperbound <- 5
#' items <- 6
#'
#' # lowest to highest values
#' myvalues <- c((lowerbound * items):(upperbound * items))
#'
#' ## Low variance usually gives higher Cronbach's Alpha
#' mydat_20 <- makeItemsScale(
#'   scale = myvalues,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items, variance = 0.20
#' )
#'
#' mydat_20
#'
#' moments <- data.frame(
#'   means = apply(mydat_20, MARGIN = 2, FUN = mean) |> round(3),
#'   sds = apply(mydat_20, MARGIN = 2, FUN = sd) |> round(3)
#' ) |> t()
#'
#' moments
#'
#' cor(mydat_20) |> round(2)
#' alpha(mydat_20) > round(2)
#'
#'
#' ## default variance
#' mydat_50 <- makeItemsScale(
#'   scale = myvalues,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items, variance = 0.50
#' )
#'
#' mydat_50
#'
#' moments <- data.frame(
#'   means = apply(mydat_50, MARGIN = 2, FUN = mean) |> round(3),
#'   sds = apply(mydat_50, MARGIN = 2, FUN = sd) |> round(3)
#' ) |> t()
#'
#' moments
#'
#' cor(mydat_50) |> round(2)
#' alpha(mydat_50) > round(2)
#'
#'
#' ## higher variance usually gives lower Cronbach's Alpha
#' mydat_80 <- makeItemsScale(
#'   scale = myvalues,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items, variance = 0.80
#' )
#'
#' mydat_80
#'
#' moments <- data.frame(
#'   means = apply(mydat_80, MARGIN = 2, FUN = mean) |> round(3),
#'   sds = apply(mydat_80, MARGIN = 2, FUN = sd) |> round(3)
#' ) |> t()
#'
#' moments
#'
#' cor(mydat_80) |> round(2)
#' alpha(mydat_80) > round(2)
#'
#'

makeItemsScale <- function(scale, lowerbound, upperbound, items, variance = 0.5) {
  ## idiot checks
  # if (min(scale) < lowerbound || max(scale) > upperbound) {
  #   stop("ERROR: Scale and Bounds are out of range")
  # }

  makeCombinations <- function(lowerbound, upperbound, items) {
    # combinations(n, r, v = 1:n, set = TRUE, repeats.allowed = FALSE)
    # n:  Size of the source vector
    # r:  Size of the target vectors
    # v:  Source vector. Defaults to 1:n
    # set: Logical flag indicating whether duplicates should be removed
    #      from the source vector v. Defaults to TRUE.
    # repeats.allowed:  Logical flag indicating whether the constructed
    #      vectors may include duplicated values. Defaults to FALSE.

    mycombinations <- combinations(
      v = c(lowerbound:upperbound),
      r = items,
      n = length(c(lowerbound:upperbound)),
      repeats.allowed = TRUE
    )
    sums <- apply(mycombinations, MARGIN = 1, FUN = sum)
    mycombinations <- cbind(mycombinations, sums) |> data.frame()
  }

  makeVector <- function(mycombinations, targetSum, items) {
    shortdat <- filter(mycombinations, mycombinations$sums == targetSum)
    sds <- apply(shortdat[, 1:items], MARGIN = 1, FUN = sd)
    shortdat <- cbind(shortdat, sds)

    sliceRow <- ifelse(nrow(shortdat) > 1,
      as.integer(quantile(c(1:nrow(shortdat)), probs = variance)),
      1
    )

    vec <- shortdat |>
      arrange(sds) |>
      slice(sliceRow) |>
      select(all_of(1:items))

    return(vec)
  }

  candidates <- makeCombinations(
    lowerbound = lowerbound,
    upperbound = upperbound,
    items = items
  )

  mydat <- data.frame(NULL)

  for (i in 1:length(scale)) {
    vRow <- makeVector(candidates, scale[i], items) |>
      permute()
    mydat <- rbind(mydat, vRow)
  }

  mydat <- mydat |>
    select(order(colnames(mydat)))

  for (i in 1:nrow(mydat)) {
    mydat[i, ] <- mydat[i, ] |> permute()
  }

  return(mydat)
}
