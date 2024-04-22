#' Calculate Cronbach's Alpha from a correlation matrix or dataframe
#' @name alpha
#' @description \code{alpha()} calculate Cronbach's Alpha from a given
#'   correlation matrix or a given dataframe.
#'
#' @param cormatrix (real) a square symmetrical matrix with values
#'   ranging from -1 to +1 and '1' in the diagonal
#' @param data (real) a dataframe or matrix
#'
#' @return a single value
#' @export alpha
#'
#' @examples
#'
#' ## Sample data frame
#' df <- data.frame(
#' V1  =  c(4, 2, 4, 3, 2, 2, 2, 1),
#' V2  =  c(4, 1, 3, 4, 4, 3, 2, 3),
#' V3  =  c(4, 1, 3, 5, 4, 1, 4, 2),
#' V4  =  c(4, 3, 4, 5, 3, 3, 3, 3)
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
alpha <- function(cormatrix = NULL, data = NULL) {
  ## input integrity checks
  if (is.null(cormatrix) && is.null(data)) {
    message("Error: Please input either a correlation matrix or a data file")
    return(NULL)
  } else {
    if (is.null(cormatrix)) {
      cormatrix <- cor(data)
    } else {
      if (!is.null(cormatrix) && !is.null(data)) {
        message("Alert: \nBoth cormatrix and data present.
                \nUsing cormatrix by default.")
      }
    }
  } ## END input integrity checks

  # Calculate Cronbach's Alpha from the correlation matrix
  # find the mean of upper (or lower) triangle
  mean_r <- mean(cormatrix[upper.tri(cormatrix)])

  k <- ncol(cormatrix)
  # calculate alpha
  cronbachAlpha <- (k * mean_r) / (1 + (k - 1) * mean_r)

  return(cronbachAlpha)
}
