#' Generate Inter-Item Correlation Matrix from Factor Loadings
#'
#' @description
#' Constructs an inter-item correlation matrix based on a user-supplied
#' matrix of standardised factor loadings and (optionally) a factor
#' correlation matrix.
#' The `makeCorrLoadings()` function does a surprisingly good job of
#' reproducing a target correlation matrix when all item-factor loadings
#' are present, as shown in the _makeCorrLoadings() validation article_.
#'
#' @seealso
#' - makeCorrLoadings() validation article:
#' <https://winzarh.github.io/LikertMakeR/articles/makeCorrLoadings_validate.html>
#' - Package website: <https://winzarh.github.io/LikertMakeR/>
#'
#' @param loadings Numeric matrix. A \eqn{k \times f} matrix of standardized
#' factor loadings \eqn{items \times factors}.
#' Row names and column names are used for diagnostics if present.
#' @param factorCor Optional \eqn{f \times f} matrix of factor
#' correlations (\eqn{\Phi}).
#' If NULL, assumes orthogonal factors.
#' @param uniquenesses Optional vector of length k. If NULL, calculated
#' as \eqn{1 - rowSums(loadings^2)}.
#' @param nearPD Logical.
#' If `TRUE`, attempts to coerce non–positive-definite matrices
#' using [Matrix::nearPD()].
#' @param diagnostics Logical.
#' If `TRUE`, returns diagnostics including McDonald's Omega and
#' item-level summaries.
#'
#' @return If diagnostics = FALSE, returns a correlation matrix (class: matrix).
#'         If diagnostics = TRUE, returns a list with:
#'         - R: correlation matrix
#'         - Omega: per-factor Omega or adjusted Omega
#'         - OmegaTotal: total Omega across all factors
#'         - Diagnostics: dataframe of communalities, uniquenesses, and primary factor
#'
#' @examples
#'
#' # --------------------------------------------------------
#' # Example 1: Basic use without diagnostics
#' # --------------------------------------------------------
#'
#' factorLoadings <- matrix(
#'   c(
#'     0.05, 0.20, 0.70,
#'     0.10, 0.05, 0.80,
#'     0.05, 0.15, 0.85,
#'     0.20, 0.85, 0.15,
#'     0.05, 0.85, 0.10,
#'     0.10, 0.90, 0.05,
#'     0.90, 0.15, 0.05,
#'     0.80, 0.10, 0.10
#'   ),
#'   nrow = 8, ncol = 3, byrow = TRUE
#' )
#'
#' rownames(factorLoadings) <- paste0("Q", 1:8)
#' colnames(factorLoadings) <- c("Factor1", "Factor2", "Factor3")
#'
#' factorCor <- matrix(
#'   c(
#'     1.0,  0.7, 0.6,
#'     0.7,  1.0, 0.4,
#'     0.6,  0.4, 1.0
#'   ),
#'   nrow = 3, byrow = TRUE
#' )
#'
#' itemCor <- makeCorrLoadings(factorLoadings, factorCor)
#' round(itemCor, 3)
#'
#' # --------------------------------------------------------
#' # Example 2: Diagnostics with factor correlations (Adjusted Omega)
#' # --------------------------------------------------------
#'
#' result_adj <- makeCorrLoadings(
#'   loadings = factorLoadings,
#'   factorCor = factorCor,
#'   diagnostics = TRUE
#' )
#'
#' # View outputs
#' round(result_adj$R, 3) # correlation matrix
#' round(result_adj$Omega, 3) # adjusted Omega
#' round(result_adj$OmegaTotal, 3) # total Omega
#' print(result_adj$Diagnostics) # communality and uniqueness per item
#'
#' # --------------------------------------------------------
#' # Example 3: Diagnostics assuming orthogonal factors (Per-Factor Omega)
#' # --------------------------------------------------------
#'
#' result_orth <- makeCorrLoadings(
#'   loadings = factorLoadings,
#'   diagnostics = TRUE
#' )
#'
#' round(result_orth$Omega, 3) # per-factor Omega
#' round(result_orth$OmegaTotal, 3) # total Omega
#' print(result_orth$Diagnostics)
#'
#' @importFrom stats cov2cor
#'
#' @export
makeCorrLoadings <- function(loadings,
                             factorCor = NULL,
                             uniquenesses = NULL,
                             nearPD = FALSE,
                             diagnostics = FALSE) {
  # Ensure loadings is a matrix
  if (!is.matrix(loadings)) {
    warning("loadings should be a matrix. Converting.")
    loadings <- as.matrix(loadings)
  }

  k <- nrow(loadings)
  f <- ncol(loadings)

  # Remove any non-finite loadings
  if (any(!is.finite(loadings))) {
    warning("Non-finite loadings detected. Setting them to 0.")
    loadings[!is.finite(loadings)] <- 0
  }

  # Default: assume orthogonal factors phi = I
  if (is.null(factorCor)) {
    factorCor <- diag(f)
  }

  # Validate factorCor
  if (!all(dim(factorCor) == c(f, f))) {
    stop("factorCor must be a square matrix with dimensions matching ncol(loadings).")
  }
  if (!isSymmetric(factorCor) || any(diag(factorCor) != 1)) {
    warning("factorCor should be a symmetric correlation matrix with 1s on the diagonal.")
  }

  # Apply nearPD if factorCor is not PD
  if (any(eigen(factorCor, only.values = TRUE)$values <= 0)) {
    msg <- "factorCor is not positive definite."
    if (nearPD) {
      warning(paste(msg, "Attempting to fix with nearPD()."))
      factorCor <- as.matrix(Matrix::nearPD(factorCor)$mat)
    } else {
      warning(msg)
    }
  }

  # Communalities = rowSums of squared loadings
  communalities <- rowSums(loadings^2)

  # Uniquenesses = 1 - communalities
  if (is.null(uniquenesses)) {
    uniquenesses <- 1 - communalities
  } else {
    if (length(uniquenesses) != k) {
      stop("uniquenesses must be a vector of length equal to nrow(loadings).")
    }
  }

  # Warn for unusual values
  tol <- 1e-8
  if (any(communalities > 1 + tol)) {
    warning("Some communalities exceed 1. Check your loadings.")
  }
  if (any(uniquenesses < 0 - tol)) {
    warning("Some uniquenesses are negative. Check your loadings.")
  }

  # Construct full covariance matrix
  Psi <- diag(uniquenesses, k)
  Sigma <- loadings %*% factorCor %*% t(loadings) + Psi
  R <- cov2cor(Sigma)

  # Symmetrize correlation matrix
  R[upper.tri(R)] <- t(R)[upper.tri(R)]

  # Coerce to PD if needed
  if (any(eigen(R, only.values = TRUE)$values <= 0)) {
    msg <- "Resulting correlation matrix is not positive definite."
    if (nearPD) {
      warning(paste(msg, "Applying nearPD()."))
      R <- as.matrix(Matrix::nearPD(R)$mat)
    } else {
      warning(paste(msg, "Check your inputs."))
    }
  }

  # Return early if no diagnostics requested
  if (!diagnostics) {
    return(R)
  }

  #### DIAGNOSTICS SECTION ####

  # Identify primary factor (based on max abs loading)
  primary <- apply(abs(loadings), 1, which.max)
  primary_factor <- colnames(loadings)[primary]

  diag_table <- data.frame(
    Item = rownames(loadings),
    Communality = communalities,
    Uniqueness = uniquenesses,
    PrimaryFactor = primary_factor,
    stringsAsFactors = FALSE
  )

  # Per-factor Omega (assuming orthogonal)
  omega_vec <- numeric(f)
  for (j in 1:f) {
    lambda_sq <- loadings[, j]^2
    omega_vec[j] <- sum(lambda_sq) / (sum(lambda_sq) + sum(uniquenesses))
  }
  names(omega_vec) <- colnames(loadings)

  # Omega Total: variance explained across all factors
  total_var_expl <- sum(diag(loadings %*% factorCor %*% t(loadings)))
  total_var <- total_var_expl + sum(uniquenesses)
  omega_total <- total_var_expl / total_var

  # Adjusted Omega (accounts for factorCor)
  use_adjusted <- !is.null(factorCor) && !isTRUE(all.equal(factorCor, diag(f)))

  if (use_adjusted) {
    # Omega adjusted: reliability per factor incorporating \eqn{\Phi}
    omega_adj <- numeric(f)
    for (j in 1:f) {
      # Extract all loadings on factor j and their cross-factor effects
      lambda_j <- loadings[, j]
      phi_j <- factorCor[j, j] # = 1
      lambda_cross <- loadings %*% factorCor[, j]
      var_j <- sum(lambda_cross^2)
      omega_adj[j] <- var_j / (var_j + sum(uniquenesses))
    }
    names(omega_adj) <- colnames(loadings)

    message("Diagnostics returned with Adjusted Omega (accounting for factor correlations).")
    omega_out <- omega_adj
  } else {
    message("Diagnostics returned with Per-Factor Omega (assuming orthogonal factors).")
    omega_out <- omega_vec
  }

  return(list(
    R = R,
    Omega = omega_out,
    OmegaTotal = omega_total,
    Diagnostics = diag_table
  ))
}
