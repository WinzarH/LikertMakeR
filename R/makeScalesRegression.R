#' Generate regression data from summary statistics
#'
#' @name
#' makeScalesRegression
#'
#' @title
#' Generate Data from Multiple-Regression Summary Statistics
#'
#' @description
#' Generates synthetic rating-scale data that replicates reported regression
#' results. This function is useful for reproducing analyses from published
#' research where only summary statistics (standardised regression
#' coefficients and R-squared) are reported.
#'
#' @importFrom stats as.formula coef lm model.frame
#' @importFrom Matrix nearPD
#'
#' @details
#' The function can operate in two modes:
#'
#' **Mode 1: With IV correlation matrix provided**
#'
#' When \code{iv_cormatrix} is provided, the function uses the given
#' correlation structure among independent variables and calculates the
#' implied IV-DV correlations from the regression coefficients.
#'
#' **Mode 2: With optimisation (IV correlation matrix not provided)**
#'
#' When \code{iv_cormatrix = NULL}, the function optimises to find a plausible
#' correlation structure among independent variables that matches the reported
#' regression statistics.
#' Initial correlations are sampled using Fisher's z-transformation to ensure
#' proper distribution, then iteratively adjusted to match the target
#' R-squared.
#'
#' The function generates Likert-scale data (not individual items)
#' using \code{lfast()} for each variable with specified moments, then
#' correlates them using \code{lcor()}.
#' Generated data is verified by running a regression and comparing achieved
#' statistics with targets.
#'
#' @param n Integer. Sample size
#' @param beta_std Numeric vector of standardised regression coefficients
#'   (length k)
#' @param r_squared Numeric. R-squared from regression (-1 to 1)
#' @param iv_cormatrix k x k correlation matrix of independent variables.
#'   If missing (NULL), will be optimised.
#' @param iv_cor_mean Numeric. Mean correlation among IVs when optimising
#'  (ignored if iv_cormatrix provided). Default = 0.3
#' @param iv_cor_variance Numeric. Variance of correlations when optimising
#'  (ignored if iv_cormatrix provided). Default = 0.01
#' @param iv_cor_range Numeric vector of length 2.
#'  Min and max constraints on correlations when optimising.
#'  Default = c(-0.7, 0.7)
#' @param iv_means Numeric vector of means for IVs (length k)
#' @param iv_sds Numeric vector of standard deviations for IVs (length k)
#' @param dv_mean Numeric. Mean of dependent variable
#' @param dv_sd Numeric. Standard deviation of dependent variable
#' @param lowerbound_iv Numeric vector of lower bounds for each IV scale
#'   (or single value for all)
#' @param upperbound_iv Numeric vector of upper bounds for each IV scale
#'   (or single value for all)
#' @param lowerbound_dv Numeric. Lower bound for DV scale
#' @param upperbound_dv Numeric. Upper bound for DV scale
#' @param items_iv Integer vector of number of items per IV scale
#'   (or single value for all). Default = 1
#' @param items_dv Integer. Number of items in DV scale. Default = 1
#' @param var_names Character vector of variable names
#'   (length k+1: IVs then DV)
#' @param tolerance Numeric. Acceptable deviation from target R-squared
#'   (default 0.005)
#'
#' @return A list containing:
#'   \item{data}{Generated dataframe with k IVs and 1 DV}
#'   \item{target_stats}{List of target statistics provided}
#'   \item{achieved_stats}{List of achieved statistics from generated data}
#'   \item{diagnostics}{Comparison of target vs achieved}
#'   \item{iv_dv_cors}{Calculated correlations between IVs and DV}
#'   \item{full_cormatrix}{The complete (k+1) x (k+1) correlation matrix used}
#'   \item{optimisation_info}{If IV correlations were optimised,
#'         details about the optimisation}
#'
#'
#' @examples
#'
#' # Example 1: With provided IV correlation matrix
#' set.seed(123)
#' iv_corr <- matrix(c(1.0, 0.3, 0.3, 1.0), nrow = 2)
#'
#' result1 <- makeScalesRegression(
#'   n = 64,
#'   beta_std = c(0.4, 0.3),
#'   r_squared = 0.35,
#'   iv_cormatrix = iv_corr,
#'   iv_means = c(3.0, 3.5),
#'   iv_sds = c(1.0, 0.9),
#'   dv_mean = 3.8,
#'   dv_sd = 1.1,
#'   lowerbound_iv = 1,
#'   upperbound_iv = 5,
#'   lowerbound_dv = 1,
#'   upperbound_dv = 5,
#'   items_iv = 4,
#'   items_dv = 4,
#'   var_names = c("Attitude", "Intention", "Behaviour")
#' )
#'
#' print(result1)
#' head(result1$data)
#'
#'
#' # Example 2: With optimisation (no IV correlation matrix)
#' set.seed(456)
#' result2 <- makeScalesRegression(
#'   n = 128,
#'   beta_std = c(0.3, 0.25, 0.2),
#'   r_squared = 0.40,
#'   iv_cormatrix = NULL, # Will be optimised
#'   iv_cor_mean = 0.3,
#'   iv_cor_variance = 0.02,
#'   iv_means = c(3.0, 3.2, 2.8),
#'   iv_sds = c(1.0, 0.9, 1.1),
#'   dv_mean = 3.5,
#'   dv_sd = 1.0,
#'   lowerbound_iv = 1,
#'   upperbound_iv = 5,
#'   lowerbound_dv = 1,
#'   upperbound_dv = 5,
#'   items_iv = 4,
#'   items_dv = 5
#' )
#'
#' # View optimised correlation matrix
#' print(result2$target_stats$iv_cormatrix)
#' print(result2$optimisation_info)
#'
#'
#' @seealso
#' \code{\link{lfast}} for generating individual rating-scale vectors with exact moments.
#'
#' \code{\link{lcor}} for rearranging values to achieve target correlations.
#'
#' \code{\link{makeCorrAlpha}} for generating correlation matrices from Cronbach's Alpha.
#'
#'
#' @export
makeScalesRegression <- function(
    n,
    beta_std,
    r_squared,
    iv_cormatrix = NULL,
    iv_cor_mean = 0.3,
    iv_cor_variance = 0.01,
    iv_cor_range = c(-0.7, 0.7),
    iv_means,
    iv_sds,
    dv_mean,
    dv_sd,
    lowerbound_iv,
    upperbound_iv,
    lowerbound_dv,
    upperbound_dv,
    items_iv = 1,
    items_dv = 1,
    var_names = NULL,
    tolerance = 0.005) {
  # Input validation
  k <- length(beta_std) # number of IVs

  # Check if IV correlation matrix needs to be optimised
  optimisation_used <- is.null(iv_cormatrix)
  optimisation_info <- NULL

  if (optimisation_used) {
    message("IV correlation matrix not provided.
            \nOptimising to find plausible structure...")

    opt_result <- optimise_iv_cormatrix(
      k = k,
      beta_std = beta_std,
      r_squared = r_squared,
      iv_cor_mean = iv_cor_mean,
      iv_cor_variance = iv_cor_variance,
      iv_cor_range = iv_cor_range,
      tolerance = tolerance
    )

    iv_cormatrix <- opt_result$cormatrix
    optimisation_info <- list(
      converged = opt_result$converged,
      iterations = opt_result$iterations,
      achieved_r_squared_in_optimisation = opt_result$achieved_r_squared,
      iv_cor_mean_used = iv_cor_mean,
      iv_cor_variance_used = iv_cor_variance,
      iv_cor_range_used = iv_cor_range
    )

    message(sprintf(
      "Optimisation %s after %d iterations
      \n(R-sq target: %.4f, achieved in optimisation: %.4f)",
      ifelse(opt_result$converged, "converged", "completed"),
      opt_result$iterations,
      r_squared,
      opt_result$achieved_r_squared
    ))
  }

  if (nrow(iv_cormatrix) != k || ncol(iv_cormatrix) != k) {
    stop("iv_cormatrix dimensions must match number of IVs
         \n(length of beta_std)")
  }

  if (length(iv_means) != k || length(iv_sds) != k) {
    stop("iv_means and iv_sds must have same length as beta_std")
  }

  if (r_squared < 0 || r_squared > 1) {
    stop("r_squared must be between 0 and 1")
  }

  # Recycle single values to vectors if needed
  if (length(lowerbound_iv) == 1) lowerbound_iv <- rep(lowerbound_iv, k)
  if (length(upperbound_iv) == 1) upperbound_iv <- rep(upperbound_iv, k)
  if (length(items_iv) == 1) items_iv <- rep(items_iv, k)

  # Generate variable names if not provided
  if (is.null(var_names)) {
    var_names <- c(paste0("IV", 1:k), "DV")
  } else if (length(var_names) != k + 1) {
    stop("var_names must have length k+1 (IVs plus DV)")
  }

  # STEP 1: Calculate IV-DV correlations
  # r_XY = R_XX %*% beta_std
  iv_dv_cors <- as.vector(iv_cormatrix %*% beta_std)
  names(iv_dv_cors) <- var_names[1:k]

  # STEP 2: Verify consistency with R-squared
  predicted_r_squared <- sum(beta_std * iv_dv_cors)

  r_squared_diff <- abs(predicted_r_squared - r_squared)

  if (r_squared_diff > tolerance) {
    warning(
      sprintf(
        "Predicted R-squared (%.4f) differs from target (%.4f) by %.4f,
        which exceeds tolerance (%.4f).
        \nInput statistics may be inconsistent.",
        predicted_r_squared, r_squared, r_squared_diff, tolerance
      )
    )
  }

  # STEP 3: Construct full correlation matrix
  full_cormatrix <- matrix(1, nrow = k + 1, ncol = k + 1)
  full_cormatrix[1:k, 1:k] <- iv_cormatrix # IV correlations
  full_cormatrix[1:k, k + 1] <- iv_dv_cors # IV-DV correlations
  full_cormatrix[k + 1, 1:k] <- iv_dv_cors # DV-IV correlations (symmetric)

  rownames(full_cormatrix) <- colnames(full_cormatrix) <- var_names

  # Check if correlation matrix is positive definite
  eigenvals <- eigen(full_cormatrix, only.values = TRUE)$values
  if (any(eigenvals < -1e-8)) {
    warning("Resulting correlation matrix is not positive definite.
            \nGeneration may fail or produce unexpected results.")
  }

  # STEP 4: Generate data using lfast() per variable, then lcor() to correlate
  # Combine all parameters
  all_means <- c(iv_means, dv_mean)
  all_sds <- c(iv_sds, dv_sd)
  all_lowerbound <- c(lowerbound_iv, lowerbound_dv)
  all_upperbound <- c(upperbound_iv, upperbound_dv)
  all_items <- c(items_iv, items_dv)

  # Generate each variable independently with lfast()
  generated_data <- matrix(NA, nrow = n, ncol = k + 1)
  for (i in 1:(k + 1)) {
    generated_data[, i] <- lfast(
      n = n,
      mean = all_means[i],
      sd = all_sds[i],
      lowerbound = all_lowerbound[i],
      upperbound = all_upperbound[i],
      items = all_items[i]
    )
  }

  # Convert to data frame and add column names BEFORE lcor()
  generated_data <- as.data.frame(generated_data)
  colnames(generated_data) <- var_names

  # Correlate the variables using lcor()
  generated_data <- lcor(generated_data, full_cormatrix)

  # Ensure it's still a data frame after lcor() (lcor might return matrix)
  generated_data <- as.data.frame(generated_data)
  colnames(generated_data) <- var_names # Reapply names if lost

  # STEP 5: Verify - run regression on generated data
  formula_str <- paste(var_names[k + 1], "~", paste(var_names[1:k], collapse = " + "))
  reg_model <- lm(as.formula(formula_str), data = as.data.frame(generated_data))

  achieved_beta_std <- std_beta(reg_model)
  achieved_r_squared <- summary(reg_model)$r.squared
  achieved_cors <- cor(generated_data)

  # Calculate achieved IV-DV correlations
  achieved_iv_dv_cors <- achieved_cors[1:k, k + 1]
  names(achieved_iv_dv_cors) <- var_names[1:k]

  # STEP 6: Compile diagnostics
  target_stats <- list(
    beta_std = beta_std,
    r_squared = r_squared,
    iv_dv_cors = iv_dv_cors,
    iv_means = iv_means,
    iv_sds = iv_sds,
    dv_mean = dv_mean,
    dv_sd = dv_sd,
    iv_cormatrix = iv_cormatrix
  )

  achieved_stats <- list(
    beta_std = achieved_beta_std,
    r_squared = achieved_r_squared,
    iv_dv_cors = achieved_iv_dv_cors,
    iv_means = colMeans(generated_data[, 1:k]),
    iv_sds = apply(generated_data[, 1:k], 2, sd),
    dv_mean = mean(generated_data[, k + 1]),
    dv_sd = sd(generated_data[, k + 1]),
    full_cormatrix = achieved_cors
  )

  # Create diagnostics comparison table
  diagnostics <- data.frame(
    Statistic = c(
      paste0("Beta_", var_names[1:k]),
      "R_squared",
      paste0("r_", var_names[1:k], "_DV"),
      paste0("Mean_", var_names),
      paste0("SD_", var_names)
    ),
    Target = c(
      beta_std,
      r_squared,
      iv_dv_cors,
      all_means,
      all_sds
    ),
    Achieved = c(
      achieved_beta_std,
      achieved_r_squared,
      achieved_iv_dv_cors,
      c(achieved_stats$iv_means, achieved_stats$dv_mean),
      c(achieved_stats$iv_sds, achieved_stats$dv_sd)
    )
  )

  diagnostics$Difference <- diagnostics$Achieved - diagnostics$Target
  diagnostics$Pct_Error <- (diagnostics$Difference / diagnostics$Target) * 100

  # Return results
  result <- list(
    data = as.data.frame(generated_data),
    target_stats = target_stats,
    achieved_stats = achieved_stats,
    diagnostics = diagnostics,
    iv_dv_cors = iv_dv_cors,
    full_cormatrix = full_cormatrix,
    optimisation_info = optimisation_info,
    call = match.call()
  )

  class(result) <- c("makeScalesRegression", "list")

  return(result)
}

#' Print method for makeScalesRegression objects
#'
#' @param x An object of class "makeScalesRegression"
#' @param ... Additional arguments (currently unused)
#'
print.makeScalesRegression <- function(x, ...) {
  cat("Regression Data Generation Results\n")
  cat("===================================\n\n")
  cat("Sample size:", nrow(x$data), "\n")
  cat("Number of IVs:", ncol(x$data) - 1, "\n")

  # Show optimisation info if used
  if (!is.null(x$optimisation_info)) {
    cat("\nIV Correlation Matrix: OPTIMISED\n")
    cat(sprintf("  Converged: %s\n", x$optimisation_info$converged))
    cat(sprintf("  Iterations: %d\n", x$optimisation_info$iterations))
    cat(sprintf("  Target mean correlation: %.3f\n", x$optimisation_info$iv_cor_mean_used))
    cat(sprintf("  Correlation variance: %.4f\n", x$optimisation_info$iv_cor_variance_used))
  } else {
    cat("\nIV Correlation Matrix: PROVIDED\n")
  }

  cat("\nKey Statistics:\n")
  cat("---------------\n")
  cat(sprintf("Target R-squared:   %.4f\n", x$target_stats$r_squared))
  cat(sprintf("Achieved R-squared: %.4f\n", x$achieved_stats$r_squared))
  cat(sprintf(
    "Difference:         %.4f\n\n",
    x$achieved_stats$r_squared - x$target_stats$r_squared
  ))

  cat("Regression Coefficients (Standardised):\n")
  # Get IV names from the data column names (exclude DV which is last)
  iv_names <- colnames(x$data)[1:(ncol(x$data) - 1)]
  beta_comparison <- data.frame(
    Variable = iv_names,
    Target = round(x$target_stats$beta_std, 4),
    Achieved = round(x$achieved_stats$beta_std, 4),
    Diff = round(x$achieved_stats$beta_std - x$target_stats$beta_std, 4)
  )
  print(beta_comparison, row.names = FALSE)

  cat("\nFor full diagnostics, see $diagnostics\n")
  cat("For generated data, see $data\n")
  if (!is.null(x$optimisation_info)) {
    cat("For IV correlation matrix used, see $target_stats$iv_cormatrix\n")
  }

  invisible(x)
}

## Helper functions

# Helper function to calculate standardised betas
std_beta <- function(model) {
  b <- coef(model)[-1] # unstandardised coefficients (exclude intercept)
  sx <- apply(model.frame(model)[, -1], 2, sd) # SD of predictors
  sy <- sd(model.frame(model)[, 1]) # SD of outcome
  return(b * sx / sy) # standardise: st-beta = beta * (SD_x / SD_y)
}

# Helper function to generate IV correlation matrix via optimisation
optimise_iv_cormatrix <- function(k, beta_std, r_squared,
                                  iv_cor_mean, iv_cor_variance,
                                  iv_cor_range, tolerance) {
  # Fisher's z-transformation functions
  # Transforms correlation [-1, +1] to unbounded z-score
  log_transform <- function(x) {
    log((1 + x) / (1 - x))
  }

  # Inverse Fisher's z-transformation
  # Transforms z-score back to correlation [-1, +1]
  exp_transform <- function(y) {
    (exp(y) - 1) / (exp(y) + 1)
  }

  # Generate initial correlation matrix using Fisher's z-transformation
  # Sample in transformed space, then convert back to correlation space
  z_mean <- log_transform(iv_cor_mean)
  init_z <- rnorm(k * (k - 1) / 2, mean = z_mean, sd = sqrt(iv_cor_variance))
  init_cors <- exp_transform(init_z)

  # Constrain to range as safety check
  init_cors <- pmax(iv_cor_range[1], pmin(iv_cor_range[2], init_cors))

  # Build symmetric correlation matrix
  cor_matrix <- diag(k)
  cor_matrix[lower.tri(cor_matrix)] <- init_cors
  cor_matrix[upper.tri(cor_matrix)] <- t(cor_matrix)[upper.tri(cor_matrix)]

  # Ensure positive definite using nearPD if needed
  if (any(eigen(cor_matrix, only.values = TRUE)$values <= 0)) {
    cor_matrix <- as.matrix(Matrix::nearPD(cor_matrix, corr = TRUE)$mat)
  }

  # Calculate implied R-sq from this correlation matrix
  calc_r_squared <- function(cor_mat) {
    iv_dv_cors <- as.vector(cor_mat %*% beta_std)
    return(sum(beta_std * iv_dv_cors))
  }

  current_r_squared <- calc_r_squared(cor_matrix)

  # If already close enough, return
  if (abs(current_r_squared - r_squared) <= tolerance) {
    return(list(
      cormatrix = cor_matrix,
      achieved_r_squared = current_r_squared,
      iterations = 0,
      converged = TRUE
    ))
  }

  # Optimisation: adjust correlations to match target R-sq
  # Strategy: scale all correlations by a factor to adjust R-sq

  max_iterations <- 100
  best_matrix <- cor_matrix
  best_diff <- abs(current_r_squared - r_squared)

  for (iter in 1:max_iterations) {
    # Calculate scaling factor needed
    # If current R-sq is too low, increase correlations;
    # if too high, decrease
    if (current_r_squared < r_squared) {
      scale_factor <- 1.1 # Increase correlations
    } else {
      scale_factor <- 0.9 # Decrease correlations
    }

    # Scale off-diagonal elements
    new_matrix <- cor_matrix
    for (i in 1:(k - 1)) {
      for (j in (i + 1):k) {
        new_val <- cor_matrix[i, j] * scale_factor
        # Constrain to range
        new_val <- max(iv_cor_range[1], min(iv_cor_range[2], new_val))
        new_matrix[i, j] <- new_val
        new_matrix[j, i] <- new_val
      }
    }

    # Ensure positive definite
    if (any(eigen(new_matrix, only.values = TRUE)$values <= 0)) {
      new_matrix <- as.matrix(Matrix::nearPD(new_matrix, corr = TRUE)$mat)
    }

    # Calculate new R-sq
    new_r_squared <- calc_r_squared(new_matrix)
    new_diff <- abs(new_r_squared - r_squared)

    # Check if improved
    if (new_diff < best_diff) {
      best_matrix <- new_matrix
      best_diff <- new_diff
      cor_matrix <- new_matrix
      current_r_squared <- new_r_squared

      # Check convergence
      if (best_diff <= tolerance) {
        return(list(
          cormatrix = best_matrix,
          achieved_r_squared = current_r_squared,
          iterations = iter,
          converged = TRUE
        ))
      }
    } else {
      # If not improving, try smaller adjustments
      scale_factor <- ifelse(current_r_squared < r_squared, 1.05, 0.95)
    }
  }

  # Return best solution found, even if not converged
  warning(sprintf(
    "Optimisation did not fully converge.
    \nBest R-sq achieved: %.4f (target: %.4f, diff: %.4f)",
    calc_r_squared(best_matrix), r_squared, best_diff
  ))

  return(list(
    cormatrix = best_matrix,
    achieved_r_squared = calc_r_squared(best_matrix),
    iterations = max_iterations,
    converged = FALSE
  ))
}
