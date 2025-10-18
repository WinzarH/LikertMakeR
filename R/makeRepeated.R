#' @title Reproduce Repeated-Measures Data from ANOVA Summary Statistics
#'
#' @description
#' Constructs a synthetic dataset and inter-timepoint correlation matrix
#' from a repeated-measures ANOVA result, based on reported means, standard
#' deviations, and an F-statistic. This is useful when only summary statistics
#' are available from published studies.
#'
#' @details
#' This function estimates the average correlation between repeated measures
#' by matching the reported F-statistic, under one of three assumed
#' correlation structures:
#'
#' - `"cs"` (*Compound Symmetry*): The Default. Assumes all timepoints are
#' equally correlated. Common in standard RM-ANOVA settings.
#' - `"ar1"` (*First-Order Autoregressive*): Assumes correlations decay
#' exponentially with time lag.
#' - `"toeplitz"` (*Linearly Decreasing*): Assumes correlation declines
#' linearly with time lag - a middle ground between `"cs"` and `"ar1"`.
#'
#' The function then generates a data frame of synthetic item-scale ratings
#' using [lfast], and adjusts them to match the estimated correlation
#' structure using [lcor].
#'
#' Set `return_corr_only = TRUE` to extract only the estimated
#' correlation matrix.
#'
#' @param n Integer. Sample size used in the original study.
#' @param k Integer. Number of repeated measures (timepoints).
#' @param means Numeric vector of length `k`.
#' Mean values reported for each timepoint.
#' @param sds Numeric vector of length `k`.
#' Standard deviations reported for each timepoint.
#' @param f_stat Numeric. The reported repeated-measures ANOVA
#' F-statistic for the within-subjects factor.
#' @param df_between Degrees of freedom between conditions (default: `k - 1`.
#' @param df_within Degrees of freedom within-subjects
#' (default: `(n - 1) * (k - 1)`).
#' @param structure Character. Correlation structure to assume:
#' `"cs"`, `"ar1"`, or `"toeplitz"` (default = `"cs"`).
#' @param names Character vector of length `k`. Variable names for each
#' timepoint (default: `"time_1"` to `"time_k"`).
#' @param items Integer. Number of items used to generate each scale score
#' (passed to [lfast]).
#' @param lowerbound, Integer. Lower bounds for Likert-type response
#' scales (default: 1).
#' @param upperbound, Integer. upper bounds for Likert-type response
#' scales (default: 5).
#' @param return_corr_only Logical. If `TRUE`, return only the
#' estimated correlation matrix.
#' @param diagnostics Logical. If `TRUE`, include diagnostic summaries
#' such as feasible F-statistic range and effect sizes.
#' @param ... Reserved for future use.
#'
#' @return A named list with components:
#'
#' \describe{
#'   \item{`data`}{A data frame of simulated repeated-measures responses
#'     (unless `return_corr_only = TRUE`).}
#'   \item{`correlation_matrix`}{The estimated inter-timepoint correlation matrix.}
#'   \item{`structure`}{The correlation structure assumed.}
#'   \item{`achieved_f`}{The F-statistic produced by the estimated `rho` value
#'     (if `diagnostics = TRUE`).}
#'   \item{`feasible_f_range`}{Minimum and maximum achievable F-values under the
#'     chosen structure (shown if diagnostics are requested).}
#'   \item{`recommended_f`}{Conservative, moderate, and strong F-statistic
#'     suggestions for similar designs.}
#'   \item{`effect_size_raw`}{Unstandardised effect size across timepoints.}
#'   \item{`effect_size_standardised`}{Effect size standardised by average variance.}
#' }
#'
#' @examples
#'
#' set.seed(42)
#'
#' out1 <- makeRepeated(
#'   n = 64,
#'   k = 3,
#'   means = c(3.1, 3.5, 3.9),
#'   sds = c(1.0, 1.1, 1.0),
#'   items = 4,
#'   f_stat = 4.87,
#'   structure = "cs",
#'   diagnostics = FALSE
#' )
#'
#' head(out1$data)
#' out1$correlation_matrix
#'
#' out2 <- makeRepeated(
#'   n = 32, k = 4,
#'   means = c(2.75, 3.5, 4.0, 4.4),
#'   sds = c(0.8, 1.0, 1.2, 1.0),
#'   f_stat = 16,
#'   structure = "ar1",
#'   items = 5,
#'   lowerbound = 1, upperbound = 7,
#'   return_corr_only = FALSE,
#'   diagnostics = TRUE
#' )
#'
#' print(out2)
#'
#'
#' out3 <- makeRepeated(
#'   n = 64, k = 4,
#'   means = c(2.0, 2.25, 2.75, 3.0),
#'   sds = c(0.8, 0.9, 1.0, 0.9),
#'   items = 4,
#'   f_stat = 24,
#'   # structure = "toeplitz",
#'   diagnostics = TRUE
#' )
#'
#' str(out3)
#'
#' @seealso \code{\link{lfast}}, \code{\link{lcor}}
#'
#' @importFrom stats median optimize
#'
#' @export

makeRepeated <- function(n, k, means, sds,
                         f_stat,
                         df_between = k - 1,
                         df_within = (n - 1) * (k - 1),
                         structure = c("cs", "ar1", "toeplitz"),
                         names = paste0("time_", 1:k),
                         items = 1,
                         lowerbound = 1, upperbound = 5,
                         return_corr_only = FALSE,
                         diagnostics = FALSE,
                         ...) {
  # Input validation
  structure <- match.arg(structure)

  if (length(means) != k) {
    stop("Length of 'means' must equal k (number of time points)")
  }
  if (length(sds) != k) {
    stop("Length of 'sds' must equal k (number of time points)")
  }
  if (length(names) != k) {
    stop("Length of 'names' must equal k (number of time points)")
  }
  if (n <= 1 || k <= 1) {
    stop("Sample size (n) and number of time points (k) must be > 1")
  }
  if (f_stat <= 0) {
    stop("F-statistic must be positive")
  }

  #####
  ##  Helper functions
  ####

  ##
  ## estimate_rho() calculates mean correlation coefficient
  ##
  estimate_rho <- function(f_stat, df_between, df_within,
                           n, k, means, sds,
                           structure = c("cs", "ar1", "toeplitz"),
                           tolerance = 1e-6) {
    structure <- match.arg(structure)

    ## Create correlation matrix based on structure
    create_corr_matrix <- function(rho, structure, k) {
      R <- matrix(1, nrow = k, ncol = k)

      if (structure == "cs") {
        R[upper.tri(R) | lower.tri(R)] <- rho
      } else if (structure == "ar1") {
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              R[i, j] <- rho^abs(i - j)
            }
          }
        }
      } else if (structure == "toeplitz") {
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              # Improved linear decrease: ensure non-negative correlations
              distance <- abs(i - j)
              R[i, j] <- max(0, rho * (1 - distance / (k - 1)))
            }
          }
        }
      }
      return(R)
    }

    # Calculate expected F-statistic from correlation matrix
    calculate_expected_f <- function(rho, means, sds, n, k, structure) {
      R <- create_corr_matrix(rho, structure, k)

      # Check positive definiteness
      eigenvals <- eigen(R, only.values = TRUE)$values
      if (any(eigenvals <= tolerance)) {
        return(Inf)
      }

      grand_mean <- mean(means)
      SS_between <- n * sum((means - grand_mean)^2)

      # Average correlation calculation
      if (structure == "cs") {
        avg_corr <- rho
      } else if (structure == "ar1") {
        corr_sum <- 0
        count <- 0
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              corr_sum <- corr_sum + rho^abs(i - j)
              count <- count + 1
            }
          }
        }
        avg_corr <- corr_sum / count
      } else if (structure == "toeplitz") {
        corr_sum <- 0
        count <- 0
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              distance <- abs(i - j)
              corr_val <- max(0, rho * (1 - distance / (k - 1)))
              corr_sum <- corr_sum + corr_val
              count <- count + 1
            }
          }
        }
        avg_corr <- corr_sum / count
      }

      pooled_var <- mean(sds^2)
      SS_error <- (n - 1) * k * pooled_var * (1 - avg_corr)

      MS_between <- SS_between / df_between
      MS_error <- SS_error / df_within
      F_calc <- MS_between / MS_error

      return(F_calc)
    }

    # Objective function
    objective <- function(rho) {
      expected_f <- calculate_expected_f(rho, means, sds, n, k, structure)
      return((expected_f - f_stat)^2)
    }

    # Set bounds based on structure
    if (structure == "cs") {
      lower_bound <- max(-0.99, -1 / (k - 1) + 0.01)
      upper_bound <- 0.99
    } else if (structure == "ar1") {
      lower_bound <- -0.99
      upper_bound <- 0.99
    } else if (structure == "toeplitz") {
      # For improved Toeplitz, be more conservative to ensure positive definiteness
      lower_bound <- -0.8
      upper_bound <- 0.99
    }

    # Optimize
    result <- optimize(objective, interval = c(lower_bound, upper_bound))
    final_f <- calculate_expected_f(result$minimum, means, sds, n, k, structure)
    convergence_check <- abs(final_f - f_stat) / f_stat

    return(list(
      rho = result$minimum,
      convergence = convergence_check < 0.01,
      final_f_stat = final_f,
      target_f_stat = f_stat,
      objective_value = result$objective,
      structure = structure,
      correlation_matrix = create_corr_matrix(result$minimum, structure, k)
    ))
  } ## END estimate rho function

  ##
  ### Simplified diagnostic function
  ##
  diagnose_f_range <- function(n, k, means, sds,
                               structure = c("cs", "ar1", "toeplitz"),
                               rho_range = c(-0.8, 0.8), n_points = 20) {
    structure <- match.arg(structure)

    # Helper function to calculate expected F
    calculate_expected_f <- function(rho, means, sds, n, k, structure) {
      # Create correlation matrix
      R <- matrix(1, nrow = k, ncol = k)
      if (structure == "cs") {
        R[upper.tri(R) | lower.tri(R)] <- rho
      } else if (structure == "ar1") {
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              R[i, j] <- rho^abs(i - j)
            }
          }
        }
      } else if (structure == "toeplitz") {
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              distance <- abs(i - j)
              R[i, j] <- max(0, rho * (1 - distance / (k - 1)))
            }
          }
        }
      }

      # Check positive definiteness
      eigenvals <- eigen(R, only.values = TRUE)$values
      if (any(eigenvals <= 1e-6)) {
        return(NA)
      }

      grand_mean <- mean(means)
      SS_between <- n * sum((means - grand_mean)^2)

      # Average correlation calculation
      if (structure == "cs") {
        avg_corr <- rho
      } else if (structure == "ar1") {
        corr_sum <- 0
        count <- 0
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              corr_sum <- corr_sum + rho^abs(i - j)
              count <- count + 1
            }
          }
        }
        avg_corr <- corr_sum / count
      } else if (structure == "toeplitz") {
        corr_sum <- 0
        count <- 0
        for (i in 1:k) {
          for (j in 1:k) {
            if (i != j) {
              distance <- abs(i - j)
              corr_val <- max(0, rho * (1 - distance / (k - 1)))
              corr_sum <- corr_sum + corr_val
              count <- count + 1
            }
          }
        }
        avg_corr <- corr_sum / count
      }

      pooled_var <- mean(sds^2)
      df_between <- k - 1
      df_within <- (n - 1) * (k - 1)
      SS_error <- (n - 1) * k * pooled_var * (1 - avg_corr)

      MS_between <- SS_between / df_between
      MS_error <- SS_error / df_within
      F_calc <- MS_between / MS_error

      return(F_calc)
    }

    # Set reasonable bounds for rho based on structure
    if (structure == "cs") {
      lower_rho <- max(rho_range[1], -1 / (k - 1) + 0.01)
      upper_rho <- min(rho_range[2], 0.99)
    } else if (structure == "ar1") {
      lower_rho <- max(rho_range[1], -0.99)
      upper_rho <- min(rho_range[2], 0.99)
    } else if (structure == "toeplitz") {
      lower_rho <- max(rho_range[1], -0.8)
      upper_rho <- min(rho_range[2], 0.99)
    }

    # Generate sequence of rho values to test
    rho_seq <- seq(lower_rho, upper_rho, length.out = n_points)

    # Calculate F-statistics for each rho
    f_values <- sapply(rho_seq, function(rho) {
      calculate_expected_f(rho, means, sds, n, k, structure)
    })

    # Remove any NA values (from invalid correlation matrices)
    valid_idx <- !is.na(f_values)
    f_values <- f_values[valid_idx]

    # Calculate summary statistics
    f_min <- min(f_values, na.rm = TRUE)
    f_max <- max(f_values, na.rm = TRUE)
    f_median <- median(f_values, na.rm = TRUE)

    # Calculate effect sizes
    grand_mean <- mean(means)
    effect_size_raw <- sum((means - grand_mean)^2) / k
    effect_size_standardised <- effect_size_raw / mean(sds^2)

    # Create simplified results
    return(list(
      feasible_f_range = c(min = f_min, max = f_max),
      recommended_f = list(
        conservative = round((2 * f_min + f_median) / 3, 2),
        moderate = round(f_median, 2),
        strong = round((2 * f_max + f_median) / 3, 2)
      ),
      effect_size_raw = effect_size_raw,
      effect_size_standardised = effect_size_standardised
    ))
  } ## END diagnose_f_range() function

  ##
  ## Main function execution
  ##

  # Estimate correlation parameter
  rho_result <- estimate_rho(
    f_stat = f_stat,
    df_between = df_between,
    df_within = df_within,
    n = n,
    k = k,
    means = means,
    sds = sds,
    structure = structure
  )

  # Check convergence
  if (!rho_result$convergence) {
    warning("Optimization may not have converged. Check results carefully.")
  }

  # Get the correlation matrix
  R <- rho_result$correlation_matrix
  colnames(R) <- rownames(R) <- names

  # If user only wants the correlation matrix, return it
  if (return_corr_only) {
    result <- list(
      correlation_matrix = R,
      structure = structure
    )
    return(result)
  }

  # Generate data using LikertMakeR functions
  likert_data <- data.frame(matrix(nrow = n, ncol = k))
  colnames(likert_data) <- names

  # Generate each column separately with lfast()
  for (i in 1:k) {
    likert_data[, i] <- LikertMakeR::lfast(
      n = n,
      mean = means[i],
      sd = sds[i],
      items = items,
      lowerbound = lowerbound,
      upperbound = upperbound
    )
  }

  # Apply correlation structure to the generated data
  final_data <- LikertMakeR::lcor(data = likert_data, target = R)
  colnames(final_data) <- names

  # Prepare basic output (diagnostics = FALSE)
  result <- list(
    data = final_data,
    correlation_matrix = R,
    structure = structure
  )

  # Add diagnostics if requested (diagnostics = TRUE)
  if (diagnostics) {
    diag_result <- diagnose_f_range(
      n = n, k = k, means = means, sds = sds,
      structure = structure
    )

    result$feasible_f_range <- diag_result$feasible_f_range
    result$recommended_f <- diag_result$recommended_f
    result$achieved_f <- rho_result$final_f_stat
    result$effect_size_raw <- diag_result$effect_size_raw
    result$effect_size_standardised <- diag_result$effect_size_standardised
  }

  return(result)
}
