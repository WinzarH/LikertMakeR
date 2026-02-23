#' Correlation matrix from Cronbach's Alpha
#'
#' @name makeCorrAlpha
#'
#' @description Generate a Positive-Definite
#' Correlation Matrix for a target _Cronbach's alpha_.
#'
#' Constructs a correlation matrix with a specified number of items and
#' target _Cronbach's alpha_ using a constructive one-factor model.
#'
#' Such a correlation matrix can be applied to the [makeScales()]
#' function to generate synthetic data with the predefined alpha.
#'
#' The algorithm directly builds a positive-definite correlation matrix
#' by solving for item loadings that reproduce the desired average
#' inter-item correlation implied by _alpha_.
#' Unlike the earlier swap-based approach of this function,
#' this method guarantees positive definiteness without _post-hoc_ repair.
#'
#' @param items Integer. Number of items (>= 2).
#' @param alpha Numeric. Target Cronbach's alpha.
#' @param variance Numeric. Controls heterogeneity of item loadings.
#'   Larger values produce greater spread among inter-item correlations.
#'   Internally moderated if necessary to maintain feasibility.
#' @param precision Integer (0–3). Controls decimal-level reproducibility
#'   of alpha.
#'   \itemize{
#'     \item \code{0}: exact deterministic alpha.
#'     \item \code{1}: approximately one-decimal accuracy.
#'     \item \code{2}: approximately two-decimal accuracy.
#'     \item \code{3}: approximately three-decimal accuracy.
#'   }
#'   Internally, alpha is sampled with standard deviation
#'   \eqn{0.5 \times 10^{-precision}}.
#' @param sort_cors Deprecated. Retained for backward compatibility.
#'   Has no effect under the constructive generator.
#' @param diagnostics Logical. If \code{TRUE}, returns a list containing
#'   the matrix and diagnostic information.
#'
#' @details
#' The function computes the average inter-item correlation implied by the
#' requested alpha and solves for a one-factor loading structure that
#' reproduces this value. A small adaptive reduction in dispersion may be
#' applied when necessary to ensure a valid positive-definite solution.
#'
#' The constructive generator assumes a single common factor structure,
#' consistent with typical psychometric scale construction.
#'
#' When \code{precision > 0}, the target alpha is sampled around the
#' requested value to approximate decimal-level reporting accuracy.
#'
#' @return
#' If \code{diagnostics = FALSE}, a positive-definite correlation matrix.
#' If \code{diagnostics = TRUE}, a list containing:
#' \itemize{
#'   \item \code{R}: the correlation matrix
#'   \item \code{diagnostics}: list including achieved alpha,
#'         minimum eigenvalue, and internal variance used
#' }
#'
#'
#' @importFrom stats rnorm
#' @importFrom stats uniroot
#'
#' @return If 'diagnostics = FALSE', a k x k correlation matrix.
#'  If 'diagnostics = TRUE', a list with components:
#'  \describe{
#'    \item{R}{k x k correlation matrix}
#'    \item{diagnostics}{list of summary statistics}
#'  }
#'
#' @examples
#'
#' # define parameters
#' items <- 4
#' alpha <- 0.85
#' variance <- 0.5
#'
#' # apply function
#' set.seed(42)
#' cor_matrix <- makeCorrAlpha(
#'   items = items,
#'   alpha = alpha,
#'   variance = variance
#' )
#'
#' # test function output
#' print(cor_matrix)
#' alpha(cor_matrix)
#' eigenvalues(cor_matrix, 1)
#'
#' # higher alpha, more items
#' cor_matrix2 <- makeCorrAlpha(
#'   items = 8,
#'   alpha = 0.95
#' )
#'
#' # test output
#' cor_matrix2 |> round(2)
#' alpha(cor_matrix2) |> round(3)
#' eigenvalues(cor_matrix2, 1) |> round(3)
#'
#'
#' # large random variation around alpha
#' set.seed(42)
#' cor_matrix3 <- makeCorrAlpha(
#'   items = 6,
#'   alpha = 0.85,
#'   precision = 3
#' )
#'
#' # test output
#' cor_matrix3 |> round(2)
#' alpha(cor_matrix3) |> round(3)
#' eigenvalues(cor_matrix3, 1) |> round(3)
#'
#'
#' # with diagnostics
#' cor_matrix4 <- makeCorrAlpha(
#'   items = 4,
#'   alpha = 0.80,
#'   diagnostics = TRUE
#' )
#'
#' # test output
#' cor_matrix4
#'
#' @export
makeCorrAlpha <- function(items,
                          alpha,
                          variance = 0.5,
                          precision = 0,
                          sort_cors = FALSE,
                          diagnostics = FALSE) {
  k <- items
  if (k < 2) stop("items must be >= 2")

  # -------------------------------
  # Base target mean correlation
  # -------------------------------
  target_mean_r <- alpha / (k - alpha * (k - 1))

  if (target_mean_r <= 0) {
    stop("Target alpha implies non-positive mean correlation.")
  }

  # -------------------------------
  # Precision control (decimal accuracy of alpha)
  # -------------------------------

  precision <- max(0, min(3, precision))

  # Standard deviation for alpha sampling
  alpha_sd <- 0.5 * 10^(-precision)

  alpha_sd <- if (precision == 0) 0 else 0.5 * 10^(-precision)
  alpha_target_effective <- rnorm(1, mean = alpha, sd = alpha_sd)

  # Ensure alpha remains in (0, 1)
  alpha_target_effective <- min(max(alpha_target_effective, 0.001), 0.999)

  # Convert to target mean correlation
  target_mean_r <- alpha_target_effective /
    (k - alpha_target_effective * (k - 1))

  ## reporting accuracy
  tolerance <- 0.005
  min_eigen_threshold <- 1e-5


  # variation in correlations
  base_internal_variance <- variance^3
  internal_variance <- base_internal_variance

  best_result <- NULL
  shrink_used <- FALSE

  # -------------------------------
  # Constructive generator
  # -------------------------------

  for (shrink_level in 1:6) {
    for (attempt in 1:3) {
      z <- rnorm(k)
      z <- z - mean(z)
      z <- z / sd(z)
      z <- z * internal_variance

      a_min <- max(-1 - z)
      a_max <- min(1 - z)

      if (a_min >= a_max) next

      lower <- max(0, a_min) # positive-manifold assumption
      upper <- a_max

      mean_r_given_a <- function(a) {
        lambda <- a + z
        if (any(abs(lambda) >= 1)) {
          return(Inf)
        }
        R_tmp <- outer(lambda, lambda)
        mean(R_tmp[lower.tri(R_tmp)])
      }

      f <- function(a) mean_r_given_a(a) - target_mean_r

      if (f(lower) * f(upper) > 0) next

      a_sol <- tryCatch(
        uniroot(f, interval = c(lower, upper))$root,
        error = function(e) NULL
      )

      if (is.null(a_sol)) next

      lambda <- a_sol + z
      if (any(abs(lambda) >= 1)) next

      psi <- 1 - lambda^2
      R <- outer(lambda, lambda) + diag(psi)

      eigvals <- eigen(R, symmetric = TRUE, only.values = TRUE)$values
      min_eig <- min(eigvals)

      avg_r <- mean(R[lower.tri(R)])
      alpha_achieved <- (k * avg_r) / (1 + (k - 1) * avg_r)
      alpha_diff <- alpha_achieved - alpha_target_effective

      if (!is.na(min_eig) &&
        min_eig > min_eigen_threshold &&
        abs(alpha_diff) <= tolerance) {
        best_result <- list(
          R = R,
          alpha_achieved = alpha_achieved,
          min_eigen = min_eig,
          internal_variance = internal_variance
        )

        break
      }
    }

    if (!is.null(best_result)) break

    internal_variance <- internal_variance * 0.85
    shrink_used <- TRUE
  }

  if (is.null(best_result)) {
    stop("Unable to construct feasible correlation matrix for these parameters.")
  }

  cor_matrix <- best_result$R

  # -------------------------------
  # Deprecate sort_cors
  # -------------------------------
  if (sort_cors) {
    warning("sort_cors is deprecated and has no effect in the constructive generator.")
  }

  item_names <- sprintf("item%02d", seq_len(k))
  rownames(cor_matrix) <- colnames(cor_matrix) <- item_names

  if (shrink_used) {
    warning("Requested variance was reduced internally to ensure feasibility.")
  }

  message(paste0("Achieved alpha = ", best_result$alpha_achieved |> round(3)))

  if (!diagnostics) {
    return(cor_matrix)
  } else {
    return(list(
      R = cor_matrix,
      diagnostics = list(
        items = items,
        alpha_input = alpha,
        alpha_target_effective = alpha_target_effective,
        alpha_achieved = best_result$alpha_achieved,
        average_r = mean(cor_matrix[lower.tri(cor_matrix)]),
        min_eigenvalue = best_result$min_eigen,
        variance_input = variance,
        internal_variance_used = best_result$internal_variance,
        precision = precision
      )
    ))
  }
}
