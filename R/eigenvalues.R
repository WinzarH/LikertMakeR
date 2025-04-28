#' calculate eigenvalues of a correlation matrix with optional scree plot
#'
#' @name eigenvalues
#' @description \code{eigenvalues()} calculate eigenvalues of a correlation
#'  matrix and optionally produces a scree plot.
#'
#' @param cormatrix (real, matrix) a correlation matrix
#' @param scree (logical) default = `FALSE`. If `TRUE` (or `1`), then
#'  \code{eigenvalues()} produces a scree plot to illustrate the eigenvalues
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
  matrix_name <- deparse(substitute(cormatrix))
  e_vals <- eigen(cormatrix)$values
  # generate scree plot
  if (scree == TRUE) {
    par(mar = c(2.5, 4, 2, 1)) # (bottom, left, top, right)
    # Set up x as the index
    x <- seq_along(e_vals) # x = 1, 2, 3, ..., length(e_vals)
    plot(x, e_vals,
      pch = 19, col = "black", cex = 1.0,
      xlab = "",
      ylab = "Eigenvalues",
      xaxt = "n", # suppress default x-axis
      ylim = c(min(0, min(e_vals)), max(e_vals)),
      main = paste0("Scree Plot: ", matrix_name),
      cex.main = 1, col.main = "black",
      type = "b"
    )
    # integer x-axis
    axis(1, at = x)
    # line plot
    abline(h = c(0, 1), col = "steelblue", lty = 2)
    # Highlight eigenvalues that are below zero
    rect(
      xleft = 0.8, xright = length(e_vals) * 1.1,
      ytop = 0, ybottom = min(0, min(e_vals) * 1.25),
      col = "#FFC0CB56", border = NA
    )
  }
  if (min(e_vals) >= 0) {
    cat(matrix_name, " is positive-definite\n\n")
  } else {
    cat(matrix_name, " is NOT positive-definite\n\n")
  }
  # cat("Eigenvalues:\n", e_vals, "\n")
  return(e_vals)
} ## end eigenvalues function
