#' makeItems
#'
#' Generate synthetic rating-scale data with predefined
#'  first and second moments and a predefined correlation matrix
#'
#' @name makeItems
#' @description \code{makeItems()} generates a dataframe of random discrete
#'  values from a (scaled Beta distribution) so the data replicate a rating
#'  scale, and are correlated close to a predefined correlation matrix.
#'  \code{makeItems()} is actually a combination of
#'
#'   * \code{lfast_R()}, which takes repeated samples selecting a vector that
#'    best fits the desired moments, and
#'   * \code{lcor_C()}, which rearranges values in each column of the dataframe
#'    so they closely match the desired correlation matrix.
#'
#' @param n (positive, int) number of observations to generate
#' @param lowerbound (positive, int) a vector of length k
#'  (same as rows & columns of correlation matrix) of values for lower bound
#'  of each scale item (e.g. '1' for a 1-5 rating scale)
#' @param upperbound (positive, int) a vector of length k
#'  (same as rows & columns of correlation matrix) of values for upper bound
#'  of each scale item (e.g. '5' for a 1-5 rating scale)
#' @param means (real) target means: a vector of length k
#'  of mean values for each scale item
#' @param sds (real) target standard deviations: a vector of length k
#'  of standard deviation values for each scale item
#' @param cormatrix (real, matrix) the target correlation matrix:
#'  a square symmetric matrix of values renging between -1 and +1,
#'  and '1' in the diagonal.
#'
#' @return a dataframe of rating-scale values
#' @export makeItems
#'
#' @examples
#'
#' ## define parameters
#'
#' n <- 16
#'
#' lowerbound <- rep(1, 4)
#'
#' upperbound <- rep(5, 4)
#'
#' corMat <- matrix(
#'   c(
#'     1.00, 0.25, 0.35, 0.40,
#'     0.25, 1.00, 0.70, 0.75,
#'     0.35, 0.70, 1.00, 0.80,
#'     0.40, 0.75, 0.80, 1.00
#'   ),
#'   nrow = 4, ncol = 4
#' )
#'
#' dfMeans <- c(2.5, 3.0, 3.0, 3.5)
#'
#' dfSds <- c(1.0, 1.0, 1.5, 0.75)
#'
#' ## apply function
#'
#' df <- makeItems(n = n, lowerbound = lowerbound, upperbound = upperbound,
#'       means = dfMeans, sds = dfSds, cormatrix = corMat)
#'
#' ## test function
#'
#' print(df)
#'
#' apply(df, 2, mean) |> round(3)
#'
#' apply(df, 2, sd) |> round(3)
#'
#' cor(df) |> round(3)
#'
#'
makeItems <- function(n, lowerbound, upperbound, means, sds, cormatrix) {
  ####
  ###  input parameters integrity checks
  ####
  { ## BEGIN input parameters integrity
    if (length(upperbound) != length(lowerbound) ||
      length(upperbound) != ncol(cormatrix) ||
      length(lowerbound) != ncol(cormatrix) ||
      ncol(cormatrix) != nrow(cormatrix) ||
      length(means) != nrow(cormatrix) ||
      length(sds) != nrow(cormatrix)
    ) {
      message("ERROR:\nParameters have unequal length & dimensions ")
      return(NULL)
    }
  } ## END input parameters integrity
  ####
  { ## BEGIN check positive definite matrix
    if (min(eigen(cormatrix)$values) < 0) {
      stop("ERROR:\ncormatrix is not Positive Definite.
         \nRequested correlations are not possible \n")
      return(NULL)
    }
  } ## END check positive definite matrix
  ## end integrity checks
  ####

  ###   combine lfast() and lcor()
  ####

  k <- ncol(cormatrix)

  # Initialize the dataframe
  df <- as.data.frame(matrix(nrow = n, ncol = k))

  for (i in 1:k) {
    df[, i] <- lfast_R(n, means[i], sds[i], lowerbound[i], upperbound[i])
  }

  new_df <- lcor_C(df, cormatrix)

  return(new_df)
} ### END make_items function

