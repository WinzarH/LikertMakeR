#' Calculate Cronbach's Alpha from a correlation matrix or dataframe
#' @name alpha
#' @description `alpha()` calculates Cronbach's Alpha from a given
#'   correlation matrix or a given dataframe.
#'
#' @param cormatrix (real) a square symmetrical matrix with values
#'   ranging from -1 to +1 and '1' in the diagonal
#' @param data (real) a dataframe or matrix
#'
#' @return a single value
#'
#' @seealso \code{\link{alpha_sensitivity}}, \code{\link{reliability}}
#'
#'
#' @examples
#'
#' ## Sample data frame
#' df <- data.frame(
#'   V1  =  c(4, 2, 4, 3, 2, 2, 2, 1),
#'   V2  =  c(4, 1, 3, 4, 4, 3, 2, 3),
#'   V3  =  c(4, 1, 3, 5, 4, 1, 4, 2),
#'   V4  =  c(4, 3, 4, 5, 3, 3, 3, 3)
#' )
#'
#' ## example correlation matrix
#' corMat <- matrix(
#'   c(
#'     1.00, 0.35, 0.45, 0.70,
#'     0.35, 1.00, 0.60, 0.55,
#'     0.45, 0.60, 1.00, 0.65,
#'     0.70, 0.55, 0.65, 1.00
#'   ),
#'   nrow = 4, ncol = 4
#' )
#'
#' ## apply function examples
#'
#' alpha(cormatrix = corMat)
#'
#' alpha(, df)
#'
#' alpha(corMat, df)
#'
#' @export
#'
alpha <- function(cormatrix = NULL, data = NULL) {
  ## input integrity checks
  if (is.null(cormatrix) && is.null(data)) {
    stop(
      "Provide either a correlation matrix or a data argument.",
      call. = FALSE
    )
  } else {
    if (is.null(cormatrix)) {
      cormatrix <- cor(data)
    } else {
      if (!is.null(cormatrix) && !is.null(data)) {
        message("Alert: \nBoth cormatrix and data present.
                \nUsing cormatrix by default.")
      }
    }
  }
  # Catch common user mistake: alpha(df) instead of alpha(, df)
  if (!is.null(cormatrix) && is.null(data)) {
    if (is.data.frame(cormatrix) || is.matrix(cormatrix)) {
      # Check if it's NOT a valid correlation matrix
      is_square <- is.matrix(cormatrix) && nrow(cormatrix) == ncol(cormatrix)
      diag_is_one <- is_square && all(diag(cormatrix) == 1)
      if (!is_square || !diag_is_one) {
        stop(
          "You supplied a dataset as the first argument.\n",
          "Use: alpha(, data = your_data)",
          call. = FALSE
        )
      }
    }
  }
  ## END input integrity checks

  # Calculate Cronbach's Alpha from the correlation matrix
  # find the mean of upper (or lower) triangle
  mean_r <- mean(cormatrix[upper.tri(cormatrix)])

  k <- ncol(cormatrix)
  # calculate alpha
  cronbach_alpha <- (k * mean_r) / (1 + (k - 1) * mean_r)

  return(cronbach_alpha)
}
