#' eigenvalues
#'
#' #' calculate eigenvalues of a correlation matrix with optional scree plot
#' @name eigenvalues
#' @description \code{eigenvalues()} calculate eigenvalues of a correlation
#'  matrix and optionally produces a scree plot.
#'
#' @param cormatrix (real, matrix) a correlation matrix
#' @param scree (logical) default = `FALSE`. If `TRUE` (or `1`), then
#'  \code{eigenvalues()} produces a scree plot to illustrate the eigenvalues
#'
#' @importFrom graphics abline
#'
#' @return a vector of eigenvalues
#' @return report on positive-definite status of cormatrix
#' @export eigenvalues
#'
#' @examples
#'
#' ## define parameters
#'
#' correlationMatrix <- matrix(
#'   c(
#'     1.00, 0.25, 0.35, 0.40,
#'     0.25, 1.00, 0.70, 0.75,
#'     0.35, 0.70, 1.00, 0.80,
#'     0.40, 0.75, 0.80, 1.00
#'   ),
#'   nrow = 4, ncol = 4
#' )
#'
#' ## apply function
#'
#' evals <- eigenvalues(cormatrix = correlationMatrix)
#' evals <- eigenvalues(correlationMatrix, 1)
#'
eigenvalues <- function(cormatrix, scree = FALSE) {
  e_vals <- eigen(cormatrix)$values
  if (scree == TRUE) {
    plot(e_vals,
      pch = 19, col = "black", cex = 1.5, ylab = "Eigenvalues",
      ylim = c(0, max(e_vals)),
      main = paste0("Scree Plot: ", deparse(substitute(cormatrix))),
      col.main = "black", type = "b"
    )
    abline(h = 1, col = "blue", lty = 2)
  }
  if (min(e_vals) >= 0) {
    cat(deparse(substitute(cormatrix)), " is positive-definite\n\n")
  } else {
    cat(deparse(substitute(cormatrix)), " is NOT positive-definite\n\n")
  }
  cat("Eigenvalues:\n", e_vals, "\n")
  return(e_vals)
} ## end eigenvalues function
