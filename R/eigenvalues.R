#' calculate eigenvalues of a correlation matrix with optional scree plot
#'
#' @name eigenvalues
#' @description `eigenvalues()` calculates eigenvalues of a correlation
#'  matrix and optionally produces a scree plot.
#'
#' @param cormatrix (real, matrix) a correlation matrix
#' @param scree (logical) default = `FALSE`. If `TRUE` (or `1`), then
#'  `eigenvalues()` produces a scree plot to illustrate the eigenvalues
#'
#' @importFrom graphics abline rect
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
      pch = 19, col = "black", cex = 1.0,
      ylab = "Eigenvalues",
      ylim = c(min(0, min(e_vals)), max(e_vals)),
      main = paste0("Scree Plot: ", deparse(substitute(cormatrix))),
      cex.main = 1, col.main = "black",
      type = "b"
    )
    abline(h = c(0, 1), col = "skyblue", lty = 2)
    rect(
      xleft = 0.8, xright = length(e_vals) * 1.1,
      ytop = 0, ybottom = min(0, min(e_vals) * 1.25),
      col = "#FFC0CB56", border = NA
    )
  }
  if (min(e_vals) >= 0) {
    cat(deparse(substitute(cormatrix)), " is positive-definite\n\n")
  } else {
    cat(deparse(substitute(cormatrix)), " is NOT positive-definite\n\n")
  }

  return(e_vals)
} ## end eigenvalues function
