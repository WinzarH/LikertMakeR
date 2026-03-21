#' Correlation matrix from Cronbach's Alpha
#'
#'
#' Generate a Positive-Definite
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
#' Unlike earlier versions of this function, this method guarantees positive
#' definiteness by construction, without _post-hoc_ repair.
#'
#' @param items Integer. Number of items (>= 2).
#' @param alpha Numeric. Target Cronbach's alpha (0 < alpha < 1).
#' @param variance Numeric. Controls heterogeneity of item loadings in the
#'   underlying one-factor model.
#'
#'   Larger values produce greater dispersion among item loadings, which
#'   results in a wider spread of inter-item correlations while preserving
#'   the requested Cronbach's alpha.
#'
#'   Typical guidance:
#'   \itemize{
#'     \item \code{0.05} — near-parallel items (very similar correlations)
#'     \item \code{0.10} — modest heterogeneity (default)
#'     \item \code{0.15} — strong heterogeneity
#'     \item \code{0.20} — very strong heterogeneity
#'     \item \code{> 0.25} — extreme dispersion; internal shrinkage may occur
#'   }
#'
#'   For most applied psychometric scales (k < 20), values between
#'   \code{0.05} and \code{0.15} produce realistic correlation structures.
#'   Values above \code{0.30} are automatically reduced to \code{0.30} to
#'   satisfy algorithm constraints.
#'
#' @param alpha_noise Numeric. Controls random variation in the target
#'   Cronbach's alpha before the correlation matrix is constructed.
#'
#'   When \code{alpha_noise = 0} (default), the requested alpha is
#'   reproduced deterministically (subject to numerical tolerance).
#'
#'   When \code{alpha_noise > 0}, a small amount of random variation is
#'   added to the requested alpha prior to constructing the matrix. This
#'   can be useful in teaching or simulation settings where slightly
#'   different reliability values are desired across repeated runs.
#'
#'   Internally, noise is added on the Fisher \emph{z}-transformed scale
#'   to ensure the resulting alpha remains within valid bounds (0, 1).
#'
#'   Typical guidance:
#'   \itemize{
#'     \item \code{0.00} — deterministic alpha (default)
#'     \item \code{0.02} — very small variation
#'     \item \code{0.05} — moderate variation
#'     \item \code{0.10} — substantial variation (caution)
#'   }
#'
#'   Larger values increase the spread of achieved alpha across runs.
#'
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
#'
#' @importFrom stats rnorm sd uniroot
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
#' @examples
#'
#' # Example 1
#' # define parameters
#' items <- 4
#' alpha <- 0.85
#'
#' # apply function
#' set.seed(42)
#' cor_matrix <- makeCorrAlpha(
#'   items = items,
#'   alpha = alpha
#' )
#'
#' # test function output
#' print(cor_matrix) |> round(3)
#' alpha(cor_matrix)
#' eigenvalues(cor_matrix, 1)
#'
#' # Example 2
#' # higher alpha, more items, more variability
#' cor_matrix2 <- makeCorrAlpha(
#'   items = 8,
#'   alpha = 0.95,
#'   variance = 0.10
#' )
#'
#' # test output
#' cor_matrix2 |> round(2)
#' alpha(cor_matrix2) |> round(3)
#' eigenvalues(cor_matrix2, 1) |> round(3)
#'
#' # Example 3
#' # large random variation around alpha
#' cor_matrix3 <- makeCorrAlpha(
#'   items = 6,
#'   alpha = 0.85,
#'   alpha_noise = 0.10
#' )
#'
#' # test output
#' cor_matrix3 |> round(2)
#' alpha(cor_matrix3) |> round(3)
#' eigenvalues(cor_matrix3, 1) |> round(3)
#'
#' # Example 4
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
                          variance = 0.10,
                          alpha_noise = 0,
                          diagnostics = FALSE) {
  k <- items
  if (k < 2) stop("items must be >= 2")

  # -------------------------------
  # Base target mean correlation
  # -------------------------------
  if (!is.numeric(alpha) || length(alpha) != 1 || alpha <= 0 || alpha >= 1) {
    stop("`alpha` must be a single value between 0 and 1.", call. = FALSE)
  }

  target_mean_r <- alpha / (k - alpha * (k - 1))

  if (target_mean_r <= 0) {
    stop("Target alpha implies non-positive mean correlation.")
  }


  # -------------------------------
  # add noise around alpha if wanted
  # -------------------------------

  if (alpha_noise > 0) {
    z_alpha <- atanh(alpha)
    z_alpha_star <- rnorm(1, mean = z_alpha, sd = alpha_noise)
    alpha_target_effective <- tanh(z_alpha_star)
    alpha_target_effective <- max(min(alpha_target_effective, 0.999), 0.001)
  } else {
    alpha_target_effective <- alpha
  }

  target_mean_r <- alpha_target_effective /
    (k - alpha_target_effective * (k - 1))

  ## reporting accuracy
  tolerance <- 0.005
  min_eigen_threshold <- 1e-5


  # variation in correlations

  ## existing code may have old variance level - warn once and continue
  if (variance > 0.30) {
    warning(
      "`variance` cannot exceed 0.30 for the current algorithm; values above this are truncated.",
      call. = FALSE
    )
    variance <- 0.30
  }

  internal_variance <- variance

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

  item_names <- sprintf("item%02d", seq_len(k))
  rownames(cor_matrix) <- colnames(cor_matrix) <- item_names

  if (shrink_used) {
    warning("Requested variance was reduced internally to ensure feasibility.")
  }

  # message(paste0("Achieved alpha = ", best_result$alpha_achieved |> round(3)))

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
        alpha_noise = alpha_noise
      )
    ))
  }
}
