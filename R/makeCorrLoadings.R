#' Correlation matrix from item factor loadings
#'
#' @name makeCorrLoadings
#'
#' @description \code{makeCorrLoadings()} generates a correlation matrix of
#' inter-item correlations based on item factor loadings as might be seen in
#' _Exploratory Factor Analysis_ (**EFA**) or a _Structural Equation Model_
#' (**SEM**).
#'
#' Such a correlation matrix can be applied to the \code{makeItems()}
#' function to generate synthetic data with those predefined factor structures.
#'
#' @param loadings (numeric matrix) **k** (items) by **f** (factors)
#'  matrix of **standardised** factor loadings. Item names and Factor names
#'  can be taken from the row_names (items) and the column_names (factors),
#'  if present.
#' @param factorCor (numeric matrix) **f** x **f** factor correlation matrix
#' @param uniquenesses (numeric vector) length **k** vector of uniquenesses.
#' If _NULL_, the default, compute from the calculated communalities.
#' @param nearPD (logical) If TRUE, project factorCor and the final
#' correlation matrix onto nearest Positive Definite matrix, if needed.
#'
#' @Note The _nearPD_ option applies the _Matrix::nearPD()_ function to force
#'  a non-positive-definite matrix to be positive-definite.
#' It should be used only when a matrix is "nearly" PD.
#' In most cases, a non-PD matrix that appears in the makeCorrLoadings()
#' function means that there is a problem with the input parameters.
#'
#' @return Correlation matrix of inter-item correlations
#'
#' @importFrom Matrix nearPD
#' @importFrom stats cov2cor
#'
#' @export makeCorrLoadings
#'
#' @examples
#'
#' # Example loadings
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
#' # row and column names
#' rownames(factorLoadings) <- c("Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7", "Q8")
#' colnames(factorLoadings) <- c("Factor1", "Factor2", "Factor3")
#'
#' # Factor correlation matrix
#' factorCor <- matrix(
#'   c(
#'     1.0,  0.7, 0.6,
#'     0.7,  1.0, 0.4,
#'     0.6,  0.4, 1.0
#'   ),
#'   nrow = 3, byrow = TRUE
#' )
#'
#' # Apply the function
#' itemCorrelations <- makeCorrLoadings(factorLoadings, factorCor)
#'
#' round(itemCorrelations, 3)
#'
makeCorrLoadings <- function(loadings,
                             factorCor = NULL,
                             uniquenesses = NULL,
                             nearPD = FALSE) {
  # loadings:    p x m matrix of factor loadings
  # factorCor:   m x m factor correlation matrix (Phi)
  # uniquenesses: length p vector of uniquenesses. If NULL, compute from 1 - rowSums(loadings^2)
  # nearPD:       logical. If TRUE, project factorCor and the final R onto nearest PD matrix if needed.


  p <- nrow(loadings)
  m <- ncol(loadings)

  # Convert any non-finite loadings to 0 and warn
  if (any(!is.finite(loadings))) {
    warning("Some loadings were non-finite (NA/NaN/Inf). Setting them to 0.")
    loadings[!is.finite(loadings)] <- 0
  }

  # Identity matrix for Phi implies orthogonal factors
  if (is.null(factorCor)) {
    factorCor <- diag(m)
  }

  if (!all(dim(factorCor) == c(m, m))) {
    stop("factorCor must be an m x m matrix, where m = ncol(loadings).")
  }

  # Check that factorCor is a valid correlation matrix (diagonal=1, symmetric)
  if (!isSymmetric(factorCor) || any(diag(factorCor) != 1)) {
    warning("factorCor should be a correlation matrix with 1s on the diagonal, and symmetrical.")
  }

  # Check for non-finite values
  if (any(!is.finite(factorCor))) {
    warning("factorCor contains non-finite values (NA/NaN/Inf). They may cause invalid results.")
  }

  # Check if factorCor is positive definite
  eigsPhi <- eigen(factorCor, only.values = TRUE)$values
  if (any(eigsPhi <= 0)) {
    msg <- "factorCor is not positive definite. Some eigenvalues are <= 0."
    if (nearPD) {
      warning(paste(msg, "Attempting to fix with nearPD()."))
      factorCor <- as.matrix(Matrix::nearPD(factorCor)$mat)
    } else {
      warning(msg)
    }
  }

  # Compute communalities
  communalities <- rowSums(loadings^2)

  # If uniqueness not supplied, compute from rowSums of loadings^2
  if (is.null(uniquenesses)) {
    uniquenesses <- 1 - communalities
  } else {
    if (length(uniquenesses) != p) {
      stop("Length of 'uniquenesses' must match the number of items (rows in loadings).")
    }
  }

  tol <- 1e-8
  if (any(communalities > 1 + tol)) {
    warning("Some item communalities exceed 1, indicating invalid loadings or non-standardized items.")
  }
  if (any(uniquenesses < 0 - tol)) {
    warning("Some uniquenesses are negative, indicating invalid loadings or non-standardized items.")
  }

  Psi <- diag(uniquenesses, nrow = p, ncol = p)

  # Sigma = Lambda * Phi * Lambda^T + Psi
  Sigma <- loadings %*% factorCor %*% t(loadings) + Psi

  # Convert to correlation matrix
  R <- cov2cor(Sigma)

  # Check if R is positive definite
  eigsR <- eigen(R, only.values = TRUE)$values
  if (any(eigsR <= 0)) {
    msgR <- "Implied correlation matrix is not positive definite."
    if (nearPD) {
      warning(paste(msgR, "Attempting to fix with nearPD()."))
      R <- as.matrix(Matrix::nearPD(R)$mat)
    } else {
      warning(paste(msgR, "Check your loadings, and factorCor."))
    }
  }

  return(R)
}
