#' Generate scale items from a summated scale, with desired Cronbach's Alpha
#'
#' @name makeItemsScale
#'
#' @description `makeItemsScale()` generates a random dataframe
#'  of scale items based on a predefined summated scale
#'  (such as created by the [lfast()] function),
#'  and a desired _Cronbach's Alpha_.
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
#' @param summated logical. If TRUE (default), `scale` is assumed to be a
#' summated scale. If FALSE, the input is treated as a mean scale and will
#' be multiplied by `items` internally.
#' @param progress logical. If TRUE (default is `interactive()`), a progress
#' bar is displayed during optimisation.
#' Set to FALSE for slightly faster execution.
#'
#'
#' @details
#'
#' ## alpha
#'
#' `makeItemsScale()` takes each value of a vector of Likert scales and
#' produces a row of 'k' values that average the given scale value, and
#' then rearranges the item values within each row,
#' attempting to give a dataframe of Likert-scale items that produce a
#' predefined _Cronbach's Alpha_.
#'
#' Default value for target alpha is '0.8'.
#'
#' More extreme values for the 'variance' parameter may reduce the chances
#' of achieving the desired Alpha. So you may need to experiment a little.
#'
#' Candidate item combinations are sampled based on their dispersion,
#' favouring moderate variability. Final item properties emerge through
#' optimisation to satisfy reliability constraints.
#'
#' @importFrom gtools combinations
#' @importFrom stats quantile runif sd var
#' @importFrom utils combn setTxtProgressBar txtProgressBar
#' @importFrom matrixStats colVars
#'
#' @return a dataframe with 'items' columns and 'length(scale)' rows
#'
#' @examples
#'
#' summatedScale <- c(16, 11, 14, 7, 10, 13, 16, 13, 12, 14, 8, 11, 8, 18,  8, 13)
#'
#' newItems <- makeItemsScale(
#'   scale = summatedScale,
#'   lowerbound = 1, upperbound = 5,
#'   items = 4
#' )
#'
#'
#' @export
#'
makeItemsScale <- function(
  scale,
  lowerbound,
  upperbound,
  items,
  alpha = 0.80,
  summated = TRUE,
  progress = TRUE
) {
  ###
  ##  makeCombinations produces a dataframe of all combinations of item values
  ###

  makeCombinations <- function(lowerbound, upperbound, items) {
    mycombinations <- gtools::combinations(
      v = c(lowerbound:upperbound),
      r = items,
      n = length(c(lowerbound:upperbound)),
      repeats.allowed = TRUE
    )

    return(mycombinations)
  } # END makeCombinations function

  ###
  ## makeVector extracts candidate rows for given rowSums (scale value)
  ###
  makeVector <- function(targetSum, items) {
    shortdat <- combos_by_sum[[as.character(targetSum)]]

    if (is.null(shortdat) || nrow(shortdat) == 0) {
      stop(paste0("No candidate partition found for sum = ", targetSum))
    }

    idx <- sample.int(nrow(shortdat), size = 1)

    vec <- shortdat[idx, 1:items]

    return(as.numeric(vec))
  } # END makeVector function


  ## tune weights

  w_balance <- 0.05
  expected_mean <- mean(scale) / items

  ## score_items attempts to find penalty values so that
  ## column means are similar for the new dataset
  score_items <- function(dat, target_alpha, w_balance) {

    k <- ncol(dat)

    item_vars <- matrixStats::colVars(dat)

    rs <- .rowSums(dat, nrow(dat), ncol(dat))
    mean_rs <- mean(rs)
    total_var <- sum((rs - mean_rs)^2) / (length(rs) - 1)

    if (!is.finite(total_var) || total_var <= 0) {
      alpha_val <- 0
    } else {
      alpha_val <- (k / (k - 1)) * (1 - sum(item_vars) / total_var)
    }

    alpha_err <- abs(alpha_val - target_alpha)

    col_means <- .colSums(dat, nrow(dat), ncol(dat)) / nrow(dat)
    balance_penalty <- mean((col_means - expected_mean)^2)

    score <- alpha_err^2 +
      w_balance * balance_penalty * (1 + alpha_err)

    list(
      score = score,
      alpha = alpha_val
    )
  } ## END score_items function


  ###
  ##  rearrangeRowValues attempts to move column values
  ##  in each row to achieve desired Cronbach's Alpha
  ###
  rearrangeRowValues <- function(progress = progress) {
    # Initialize variables for best alpha and corresponding dataframe

    # Target alpha value
    target_alpha <- alpha
    alpha_tolerance <- 0.00125

    current_items <- mydat
    current_eval <- score_items(current_items, target_alpha, w_balance)
    current_score <- current_eval$score

    best_items <- current_items
    best_score <- current_score
    best_alpha <- current_eval$alpha

    min_iter <- max(32, items^2)
    max_iter <- items^2 * n

    iter <- 0

    if (progress) {
      pb <- txtProgressBar(min = 0, max = max_iter, style = 3)
    }

    pairs <- combn(ncol(current_items), 2, simplify = FALSE)

    while (iter < max_iter) {
      iter <- iter + 1

      # update_every <- max(10, floor(max_iter / 100))
      # if (progress && (iter %% update_every == 0 || iter == max_iter)) {
      #   setTxtProgressBar(pb, iter)
      # }


      if (progress) {
        setTxtProgressBar(pb, iter)
      }

      ## add temeprature cooling
      T0 <- 0.001
      T <- T0 * (1 - iter / max_iter)
      T <- max(T, 1e-6)

      # Loop through each pair of columns j and k

      # pairs <- combn(ncol(current_items), 2, simplify = FALSE)

      pairs_subset <- sample(pairs, size = min(2 * items, length(pairs)))
      row_ids <- sample.int(nrow(current_items), size = min(5 * items, nrow(current_items)))

      for (pair in pairs_subset) {
        j <- pair[1]
        k <- pair[2]

        # Skip if j == k, (no need to swap a column with itself)
        if (j == k) next

        # Loop through each row and swap columns j and k in that row
        # for (i in 1:nrow(current_items)) {

        for (i in row_ids) {
          temp_items <- current_items

          u <- runif(1)

          if (u < 0.18) {
            ## safe ±1 redistribution within row (sum-preserving)
            row <- temp_items[i, ]

            j1 <- j
            j2 <- k

            if (runif(1) < 0.5) {
              if (row[j1] < upperbound && row[j2] > lowerbound) {
                row[j1] <- row[j1] + 1
                row[j2] <- row[j2] - 1
                temp_items[i, ] <- row
              }
            } else {
              # j1 -1, j2 +1
              if (row[j1] > lowerbound && row[j2] < upperbound) {
                row[j1] <- row[j1] - 1
                row[j2] <- row[j2] + 1
                temp_items[i, ] <- row
              }
            }
          } else if (u < 0.40) {
            i2 <- sample(setdiff(1:nrow(current_items), i), 1)

            row_i <- as.numeric(temp_items[i, ])
            row_i2 <- as.numeric(temp_items[i2, ])

            # check sum compatibility
            if ((row_i[j] + row_i[k]) == (row_i2[j] + row_i2[k])) {
              new_i <- row_i
              new_i2 <- row_i2

              new_i[j] <- row_i2[j]
              new_i2[j] <- row_i[j]

              new_i[k] <- row_i2[k]
              new_i2[k] <- row_i[k]

              temp_items[i, ] <- new_i
              temp_items[i2, ] <- new_i2
            }
          } else {
            # within-row swap (~60%)
            temp <- temp_items[i, j]
            temp_items[i, j] <- temp_items[i, k]
            temp_items[i, k] <- temp
          }

          new_eval <- score_items_cpp(temp_items, target_alpha, w_balance, expected_mean)

          delta <- new_eval$score - current_score

          ## temperature

          # enforce constraint BEFORE accepting
          valid <- (sum(temp_items[i, ]) == scale[i])

          if (valid) {
            if (delta < 0 || runif(1) < exp(-delta / T)) {
              current_items <- temp_items
              current_score <- new_eval$score
            }
          } else {
            stop(paste(
              "Invalid move detected:",
              "i =", i,
              "j =", j,
              "k =", k,
              "u =", round(u, 3)
            ))
          }

          if (current_score < best_score) {
            best_items <- current_items
            best_score <- current_score
            best_alpha <- new_eval$alpha
          }

          # Stop if alpha is within tolerance
          if (iter > min_iter && abs(best_alpha - target_alpha) <= alpha_tolerance) {
            if (progress) close(pb)

            message(paste0("iterations=", iter))

            return(best_items |> as.data.frame())
          }
        }
      }
      # }
    }


    if (progress) close(pb)

    return(best_items |> as.data.frame())
  } ## END rearrangeRowValues function


  ###
  ## Functions done.. Now we run some calculations!
  ###

  candidates <- makeCombinations(
    lowerbound = lowerbound,
    upperbound = upperbound,
    items = items
  )

  # --- precompute combinations by sum ---

  candidates_df <- as.data.frame(candidates)

  candidates_df$sums <- rowSums(candidates_df)

  # compute sd
  candidates_df$sds <- apply(candidates_df[, 1:items], 1, sd)

  # split by sum
  combos_by_sum <- split(candidates_df, candidates_df$sums)

  if (!summated) {
    scale <- scale * items
  }

  scale <- as.numeric(scale)

  message(paste0("generate ", length(scale), " rows"))

  n <- length(scale)
  mydat <- matrix(NA_real_, nrow = n, ncol = items)

  for (i in seq_len(n)) {
    mydat[i, ] <- makeVector(scale[i], items)
  }

  perm <- sample(1:ncol(mydat))
  mydat <- mydat[, perm]

  colnames(mydat) <- paste0("X", seq_len(ncol(mydat)))

  message(paste0("rearrange ", items, " values within each of ", length(scale), " rows"))

  optimised_dat <- rearrangeRowValues(progress = progress)

  best_alpha <- LikertMakeR::alpha(data = optimised_dat) |> round(4)

  message(paste0("Complete!"))

  message(paste0("desired Cronbach's alpha = ", alpha, " (achieved alpha = ", best_alpha, ")"))

  return(optimised_dat)
}
