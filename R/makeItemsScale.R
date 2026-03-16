#' Generate item-level Likert responses from a summated scale, with desired Cronbach's Alpha
#'
#' @name makeItemsScale
#'
#' @description `makeItemsScale()` generates a random dataframe
#'  of scale items based on a predefined summated scale
#'
#' @param scale (int) a vector or dataframe of the summated rating scale.
#' Should range from \eqn{lowerbound \times items} to
#'  \eqn{upperbound \times items}
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
#' @param summated (logical) If TRUE, the scale is treated as a summed
#' score (e.g., 4-20 for four 5-point items).
#' If FALSE, it is treated as an averaged score
#'  (e.g., 1-5 in 0.25 increments). Default = TRUE.
#'
#'
#' @details
#' The `makeItemsScale()` function reconstructs individual Likert-style item
#' responses from a vector of scale scores while approximating a desired
#' Cronbach's alpha.
#'
#' The algorithm works in three stages. First, all possible combinations of
#' item responses within the specified bounds are generated. For each candidate
#' combination, the dispersion of item values is calculated and used as a proxy
#' for the similarity between items. Combinations with low dispersion represent
#' more homogeneous item responses and therefore imply stronger inter-item
#' correlations.
#'
#' Second, the requested Cronbach's alpha is converted to the corresponding
#' average inter-item correlation using the identity
#'
#' \deqn{\bar r = \alpha / (k - \alpha (k-1))}
#'
#' where \eqn{k} is the number of items. Candidate item combinations are then
#' ranked according to how closely their dispersion matches the similarity
#' implied by this target correlation.
#'
#' Third, for each scale score in the input vector, the algorithm selects the
#' candidate combination whose item values sum to the required scale value and
#' whose dispersion best matches the target correlation structure. The selected
#' values are randomly permuted across item positions, and a final optimisation
#' step rearranges item values within rows to improve the overall correlation
#' structure while preserving each row sum.
#'
#' This approach produces datasets whose observed Cronbach's alpha closely
#' matches the requested value while respecting the discrete nature of Likert
#' response scales and the constraint that item values must sum to the supplied
#' scale scores.
#'
#' Extremely high reliability values may be difficult to achieve when the
#' number of items is very small or when the response scale has few categories.
#' In such cases the discreteness of the response scale places an upper bound
#' on the achievable inter-item correlation.
#'
#'
#' @importFrom dplyr filter arrange slice select all_of pull slice_sample
#' @importFrom rlang .data
#' @importFrom matrixStats rowSds
#'
#' @return a dataframe with 'items' columns and 'length(scale)' rows
#'
#'
#' @examples
#'
#' ## define parameters
#' k <- 4
#' lower <- 1
#' upper <- 5
#'
#' ## scale properties
#' n <- 64
#' mean <- 3.0
#' sd <- 0.85
#'
#' ## create scale
#' set.seed(42)
#' meanScale <- lfast(
#'   n = n, mean = mean, sd = sd,
#'   lowerbound = lower, upperbound = upper,
#'   items = k
#' )
#'
#' ## create new items
#' newItems1 <- makeItemsScale(
#'   scale = meanScale,
#'   lowerbound = lower, upperbound = upper,
#'   items = k, summated = FALSE
#' )
#'
#' ### test new items
#' # str(newItems1)
#' # alpha(data = newItems1) |> round(2)
#'
#' summatedScale <- meanScale * k
#'
#' newItems2 <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = lower, upperbound = upper,
#'   items = k
#' )
#'
#' @export
makeItemsScale <- function(
  scale,
  lowerbound,
  upperbound,
  items,
  alpha = 0.80,
  summated = TRUE
) {
  ###
  ##  makeCombinations produces a dataframe of all combinations of item values
  ###

  makeCombinations <- function(lowerbound, upperbound, items) {

    vals <- lowerbound:upperbound

    grids <- expand.grid(rep(list(vals), items))

    # keep only non-decreasing rows
    combos <- grids[
      apply(grids, 1, function(x) all(diff(x) >= 0)),
    ]

    as.matrix(combos)

  }


  # makeCombinations <- function(lowerbound, upperbound, items) {
  #   mycombinations <- combinations(
  #     v = c(lowerbound:upperbound),
  #     r = items,
  #     n = length(c(lowerbound:upperbound)),
  #     repeats.allowed = TRUE
  #   )
  #   return(mycombinations)
  # }

  ###
  ##  makeVector selects a row of item values rowsums equal to a
  ##  desired summated value, and with a variance quantile consistent
  ##  with desired alpha
  ###

  makeVector <- function(targetSum, items) {
    shortdat <- cand_split[[as.character(targetSum)]]

    # guard against missing partitions
    if (is.null(shortdat) || nrow(shortdat) == 0) {
      stop(paste0("No candidate partition found for sum = ", targetSum))
    }

    # random selection among precomputed best rows
    vec <- shortdat[sample.int(nrow(shortdat), 1), ]

    return(as.numeric(vec))
  }

  ###
  ##  rearrangeRowValues attempts to move column values
  ##  in each row to achieve desired Cronbach's Alpha
  ###
  rearrangeRowValues <- function() {
    # Initialize variables for best alpha and corresponding dataframe
    best_alpha <- alpha(data = mydat)
    best_newItems <- mydat

    # Target alpha value
    target_alpha <- alpha
    alpha_tolerance <- 0.00125 # Define tolerance for acceptable alpha

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

            # Stop if alpha is within tolerance
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

  cand <- as.data.frame(candidates)

  # precompute statistics once
  cand$sum <- rowSums(cand)
  # cand$sd <- apply(cand[, 1:items], 1, sd)
  cand$sd <- matrixStats::rowSds(as.matrix(cand[, 1:items]))

  # map dispersion to similarity proxy
  sd_max <- max(cand$sd)
  cand$r_proxy <- 1 - cand$sd / sd_max

  # target correlation implied by alpha
  target_r <- alpha / (items - alpha * (items - 1))

  # score partitions by closeness to target correlation
  cand$score <- abs(cand$r_proxy - target_r)

  # split candidates by row sum
  cand_split <- split(cand, cand$sum)

  # keep only best rows for each sum (precompute once)
  cand_split <- lapply(cand_split, function(df) {

    min_score <- min(df$score)

    best <- df[df$score == min_score, seq_len(items), drop = FALSE]

    as.matrix(best)

  })


  if (!summated) {
    scale <- scale * items
  }

  scale <- as.data.frame(scale) # if scale is submitted as a vector

  min_possible <- lowerbound * items
  max_possible <- upperbound * items

  if (any(scale < min_possible | scale > max_possible, na.rm = TRUE)) {
    stop(
      paste0(
        "Scale values incompatible with item bounds.\n",
        "Expected scale range: ", min_possible, "-", max_possible, " (with 'summated=TRUE') .\n",
        "Check 'summated =' option and lower/upper bounds."
      )
    )
  }


  mydat <- matrix(NA_real_, nrow = nrow(scale), ncol = items)

  for (i in seq_len(nrow(scale))) {
    vRow <- sample(makeVector(scale[i, 1], items))
    mydat[i, ] <- vRow
  }

  mydat <- as.data.frame(mydat)


  message(paste0("rearrange ", items, " values within each of ", nrow(scale), " rows"))

  optimised_dat <- rearrangeRowValues()

  best_alpha <- alpha(data = optimised_dat) |> round(4)

  message(paste0("Complete!"))

  message(paste0("desired Cronbach's alpha = ", alpha, " (achieved alpha = ", best_alpha, ")"))

  return(optimised_dat)
}
