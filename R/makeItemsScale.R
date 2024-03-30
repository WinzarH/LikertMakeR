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
#'
#' @importFrom gtools combinations permute
#' @importFrom dplyr filter arrange slice select
#' @importFrom stats sd
#'
#' @return a dataframe with 'items' columns and 'length(scale)' rows
#'
#' @export makeItemsScale
#'
#' @examples
#'
#' # define parameters
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
#' meanScale <- lfast(n = n, mean = mean, sd = sd,
#'      lowerbound = lowerbound, upperbound = upperbound,
#'      items = items)
#' summatedScale <- meanScale * items
#'
#' ## create items
#' newItems <- makeItemsScale(scale = summatedScale,
#'      lowerbound = lowerbound, upperbound = upperbound,
#'      items = items)
#' head(newItems)
#'
#'
#'
#' lowerbound <- 1
#' upperbound <- 7
#' items <- 3
#'
#' myvalues <- c((lowerbound * items):(upperbound * items))
#'
#' mydata <- makeItemsScale(scale = myvalues,
#'      lowerbound = lowerbound, upperbound = upperbound,
#'      items = items)
#'
#' mydata
#'

makeItemsScale <- function(scale, lowerbound, upperbound, items) {
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
    sliceRow <- ifelse((nrow(shortdat) > 1 & min(shortdat$sds) == 0), 2, 1)
    vec <- shortdat |>
      arrange(sds) |>
      slice(sliceRow) |>
      # select(all_of(1:items)) |>
      select(1:items) |>
      permute()
    return(vec)
  }

  candidates <- makeCombinations(
    lowerbound = lowerbound,
    upperbound = upperbound,
    items = items
  )
  mydat <- data.frame(NULL)
  for (i in 1:length(scale)) {
    vRow <- makeVector(candidates, scale[i], items)
    mydat <- rbind(mydat, vRow)
  }

  return(mydat)
}

