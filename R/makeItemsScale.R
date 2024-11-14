#' scale items from a summated scale and desired Cronbach's Alpha
#'
#' @name makeItemsScale
#'
#' @description \code{makeItemsScale()} generates a random dataframe
#'  of scale items based on a predefined summated scale
#'  (such as created by the \code{lfast()} function),
#'  and a desired _Cronbach's Alpha_.
#'
#'  scale, lowerbound, upperbound, items, alpha, variance
#'
#' @param scale (int) a vector or dataframe of the summated rating scale.
#' Should range from ('lowerbound' * 'items') to ('upperbound' * 'items')
#' @param lowerbound (int) lower bound of the scale item
#' (example: '1' in a '1' to '5' rating)
#' @param upperbound (int) upper bound of the scale item
#' (example: '5' in a '1' to '5' rating)
#' @param items (positive, int) k, or number of columns to generate
#' @param alpha (posiitve, real) desired _Cronbach's Alpha_ for the
#' new dataframe of items.
#' Default = '0.8'.
#'
#' See `@details` for further information on the `alpha` parameter
#'
#' @param variance (positive, real) the quantile from which to select
#' items that give given summated scores.
#' Must lie between '0' and '1'.
#' Default = '0.5'.
#'
#' See `@details` for further information on the `variance` parameter
#'
#'
#' @details
#'
#' ## alpha
#'
#' \code{makeItemsScale()} rearranges the item values within each row,
#' attempting to give a dataframe of Likert-scale items that produce a
#' predefined _Cronbach's Alpha_.
#'
#' Default value for target alpha is '0.8'.
#'
#' More extreme values for the 'variance' parameter may reduce the chances
#' of achieving the desired Alpha. So you may need to experiment a little.
#'
#' ## variance
#'
#' There may be many ways to find a combination of integers that sum to a
#' specific value, and these combinations have different levels of variance:
#'
#'   * low-variance: '3 + 4 = 7'
#'   * high-variance: '1 + 6 = 7'
#'
#' The 'variance' parameter defines guidelines for the amount of variance
#' among item values that your new dataframe should have.
#'
#' For example, consider a summated value of '9' on which we apply
#' the \code{makeItemsScale()} function to generate three items.
#' With zero variance (variance parameter = '0'), then we see all items with
#' the same value, the mean of '3'.
#' With variance = '1', then we see all items with values
#' that give the maximum variance among those items.
#'
#'   | variance | v1 | v2 | v3 | sum |
#'   |----------|----|----|----|-----|
#'   | 0.0      | 3  | 3  | 3  | 9   |
#'   | 0.2      | 3  | 3  | 3  | 9   |
#'   | 0.4      | 2  | 3  | 4  | 9   |
#'   | 0.6      | 1  | 4  | 4  | 9   |
#'   | 0.8      | 2  | 2  | 5  | 9   |
#'   | 1.0      | 1  | 3  | 5  | 9   |
#'
#'
#' Similarly, the same mean value applied to six items with
#'  \code{makeItemsScale()} gives the following combinations at
#'  different values of the 'variance' parameter.
#'
#'   | variance | v1 | v2 | v3 | v4 | v5 | v6 | sum |
#'   |----------|----|----|----|----|----|----|-----|
#'   | 0.0      | 3  | 3  | 3  | 3  | 3  | 3  | 18  |
#'   | 0.2      | 1  | 3  | 3  | 3  | 4  | 4  | 18  |
#'   | 0.4      | 1  | 2  | 3  | 4  | 4  | 4  | 18  |
#'   | 0.6      | 1  | 1  | 4  | 4  | 4  | 4  | 18  |
#'   | 0.8      | 1  | 1  | 3  | 4  | 4  | 5  | 18  |
#'   | 1.0      | 1  | 1  | 1  | 5  | 5  | 5  | 18  |
#'
#' And a mean value of '3.5' gives the following combinations.
#'
#'   | variance | v1 | v2 | v3 | v4 | v5 | v6 | sum |
#'   |----------|----|----|----|----|----|----|-----|
#'   | 0.0      |  3 |  3 |  3 |  4 |  4 |  4 |  21 |
#'   | 0.2      |  3 |  3 |  3 |  3 |  4 |  5 |  21 |
#'   | 0.4      |  2 |  2 |  4 |  4 |  4 |  5 |  21 |
#'   | 0.6      |  1 |  3 |  4 |  4 |  4 |  5 |  21 |
#'   | 0.8      |  1 |  2 |  4 |  4 |  5 |  5 |  21 |
#'   | 1.0      |  1 |  1 |  4 |  5 |  5 |  5 |  21 |
#'
#'  The default value for 'variance' is '0.5' which gives a reasonable
#'  range of item values.
#'  But if you want 'responses' that are more consistent then choose
#'  a lower variance value.
#'
#'
#' @importFrom gtools combinations permute
#' @importFrom dplyr filter arrange slice select all_of pull slice_sample
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
#' str(newItems)
#' alpha(data = newItems) |> round(2)
#'
#' ## create items with lower Alpha and lower variance but same summated scale
#' newItems <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items,
#'   alpha = 0.7,
#'   variance = 0.3
#' )
#' str(newItems)
#' alpha(data = newItems) |> round(2)
#'
#' ## create items with higher Alpha but same summated scale
#' newItems <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items,
#'   alpha = 0.9,
#'   variance = 0.5
#' )
#' str(newItems)
#' alpha(data = newItems) |> round(2)
#'
#'
#' ## very low variance usually gives higher Cronbach's Alpha
#' mydat_20 <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items, alpha = 0.8, variance = 0.20
#' )
#'
#' str(mydat_20)
#'
#' moments <- data.frame(
#'   means = apply(mydat_20, MARGIN = 2, FUN = mean) |> round(3),
#'   sds = apply(mydat_20, MARGIN = 2, FUN = sd) |> round(3)
#' ) |> t()
#'
#' moments
#'
#' cor(mydat_20) |> round(2)
#' alpha(data = mydat_20) |> round(2)
#'
#'
#' ## default alpha (0.8) and default variance (0.5)
#' mydat_50 <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items
#' )
#'
#' str(mydat_50)
#'
#' moments <- data.frame(
#'   means = apply(mydat_50, MARGIN = 2, FUN = mean) |> round(3),
#'   sds = apply(mydat_50, MARGIN = 2, FUN = sd) |> round(3)
#' ) |> t()
#'
#' moments
#'
#' cor(mydat_50) |> round(2)
#' alpha(data = mydat_50) |> round(2)
#'
#'
#' mydat_80 <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items, variance = 0.80
#' )
#'
#' str(mydat_80)
#'
#' moments <- data.frame(
#'   means = apply(mydat_80, MARGIN = 2, FUN = mean) |> round(3),
#'   sds = apply(mydat_80, MARGIN = 2, FUN = sd) |> round(3)
#' ) |> t()
#'
#' moments
#'
#' cor(mydat_80) |> round(2)
#' alpha(data = mydat_80) |> round(2)
#'
makeItemsScale <- function(scale, lowerbound, upperbound, items, alpha = 0.80, variance = 0.5) {
  ###
  ##  makeCombinations produces a dataframe of all combinations of item values
  ###
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
    # sums <- apply(mycombinations, MARGIN = 1, FUN = sum)
    # mycombinations <- cbind(mycombinations, sums) |> data.frame()

    return(mycombinations)
  }

  ###
  ##  makeVector selects a row of item values rowsums equal to a
  ##  desired summated value, and at the desired variance quantile
  ###
  makeVector <- function(mycombinations, targetSum, items) {
    sums <- apply(mycombinations, MARGIN = 1, FUN = sum)
    mycombinations <- cbind(mycombinations, sums) |> data.frame()
    shortdat <- filter(mycombinations, mycombinations$sums == targetSum)
    sds <- apply(shortdat[, 1:items], MARGIN = 1, FUN = sd) |> round(2)
    shortdat <- cbind(shortdat, sds)
    shortdat <- shortdat |> arrange(sds)
    sliceRow <- ifelse(nrow(shortdat) > 1,
      as.integer(quantile(c(1:nrow(shortdat)), probs = variance)),
      1
    )

    # extract the value for "sd" at the quantile row
    target_sd <- shortdat |>
      # arrange(sds) |>
      slice(sliceRow) |>
      pull(sds)

    vec <- shortdat |>
      # arrange(sds) |>
      filter(sds == target_sd) |>
      slice_sample(n = 1) |>
      subset(select = -c(sums, sds))

    return(vec)
  }

  ###
  ##  rearrangeRowValues attempts to move column values
  ##  in each row to achieve desired Cronbach's Alpha
  ###
  rearrangeRowValues <- function() {
    # Initialize variables to track the best alpha and corresponding dataframe
    best_alpha <- alpha(data = mydat)
    best_newItems <- mydat

    # Target alpha value
    target_alpha <- alpha
    alpha_tolerance <- 0.0025 # Define tolerance for acceptable alpha

    # Boolean flag to control loop continuation
    improvement_found <- TRUE

    while (improvement_found) {
      # Reset the flag at the start of each iteration
      improvement_found <- FALSE

      # Loop through each pair of columns j and k
      for (j in 1:ncol(best_newItems)) {
        for (k in 1:ncol(best_newItems)) {
          # Skip if j == k, (no need to swap a column with itself)
          if (j == k) next

          # Loop through each row and swap columns j and k in that row
          for (i in 1:nrow(best_newItems)) {
            # Skip if the values are equal (no need for redundant swap)
            if (best_newItems[i, j] == best_newItems[i, k]) next
            # print(paste0("j=",j,", k=",k,", i=",i))
            # Make a copy of best_newItems to work with
            temp_items <- best_newItems
            # Swap the values in row i, columns j and k
            temp <- temp_items[i, j]
            temp_items[i, j] <- temp_items[i, k]
            temp_items[i, k] <- temp

            # Calculate the new Cronbach's alpha
            new_alpha <- alpha(data = temp_items)

            # Check if this new alpha is closer to the target value
            if (abs(new_alpha - target_alpha) < abs(best_alpha - target_alpha)) {
              best_alpha <- new_alpha
              best_newItems <- temp_items
              improvement_found <- TRUE
            }

            # Stop if alpha is within the acceptable tolerance
            if (abs(best_alpha - target_alpha) <= alpha_tolerance) {
              improvement_found <- FALSE
              break
            }
          }
          if (!improvement_found) break
        }
        if (!improvement_found) break
      }
    }
    return(best_newItems |> as.data.frame())
  }

  ###
  ## Functions done.. Now we run some calculations!
  ###

  candidates <- makeCombinations(
    lowerbound = lowerbound,
    upperbound = upperbound,
    items = items
  )

  scale <- as.data.frame(scale) # if case scale is submitted as a vector
  mydat <- data.frame(NULL)

  for (i in 1:nrow(scale)) {
    vRow <- makeVector(candidates, scale[i, ], items) |>
    # vRow <- makeVector(candidates, scale[i], items) |>
      permute()
    mydat <- rbind(mydat, vRow)
  }

  mydat <- mydat |>
    select(order(colnames(mydat)))

  for (i in 1:nrow(mydat)) {
    mydat[i, ] <- mydat[i, ] |> permute()
  }

  optimised_dat <- rearrangeRowValues()

  return(optimised_dat)
}
