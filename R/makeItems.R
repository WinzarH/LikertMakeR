#' Synthetic rating-scale data with given
#'  first and second moments and a predefined correlation matrix
#'
#' @name makeItems
#'
#' @description \code{makeItems()} generates a dataframe of random discrete
#'  values so the data replicate a rating scale,
#'  and are correlated close to a predefined correlation matrix.
#'
#'  \code{makeItems()} is wrapper function for:
#'
#'   * \code{lfast()}, generates a dataframe that best fits the desired
#'    moments, and
#'   * \code{lcor()}, which rearranges values in each column of the dataframe
#'    so they closely match the desired correlation matrix.
#'
#' @param n (positive, int) sample-size - number of observations
#' @param means (real) target means: a vector of length k
#'  of mean values for each scale item
#' @param sds (positive, real) target standard deviations: a vector of length k
#'  of standard deviation values for each scale item
#' @param lowerbound (positive, int) a vector of length k
#'  (same as rows & columns of correlation matrix) of values for lower bound
#'  of each scale item (e.g. '1' for a 1-5 rating scale)
#' @param upperbound (positive, int) a vector of length k
#'  (same as rows & columns of correlation matrix) of values for upper bound
#'  of each scale item (e.g. '5' for a 1-5 rating scale)
#' @param cormatrix (real, matrix) the target correlation matrix:
#'  a square symmetric positive-semi-definite matrix of values ranging
#'  between -1 and +1, and '1' in the diagonal.
#'
#' @return a dataframe of rating-scale values
#'
#' @export makeItems
#'
#' @examples
#'
#' ## define parameters
#'
#' n <- 16
#' dfMeans <- c(2.5, 3.0, 3.0, 3.5)
#' dfSds <- c(1.0, 1.0, 1.5, 0.75)
#' lowerbound <- rep(1, 4)
#' upperbound <- rep(5, 4)
#'
#' corMat <- matrix(
#'   c(
#'     1.00, 0.30, 0.40, 0.60,
#'     0.30, 1.00, 0.50, 0.70,
#'     0.40, 0.50, 1.00, 0.80,
#'     0.60, 0.70, 0.80, 1.00
#'   ),
#'   nrow = 4, ncol = 4
#' )
#'
#' ## apply function
#'
#' df <- makeItems(
#'   n = n, means = dfMeans, sds = dfSds,
#'   lowerbound = lowerbound, upperbound = upperbound, cormatrix = corMat
#' )
#'
#' ## test function
#'
#' str(df)
#'
#' # means
#' apply(df, 2, mean) |> round(3)
#'
#' # standard deviations
#' apply(df, 2, sd) |> round(3)
#'
#' # correlations
#' cor(df) |> round(3)
#'
makeItems <- function(n, means, sds, lowerbound, upperbound, cormatrix) {
  ####
  ###  input parameters integrity checks
  ####

  ## round correlation values to sensible values
  cormatrix <- cormatrix |> round(5)

  { ## BEGIN input parameters integrity
    if (length(upperbound) != length(lowerbound) ||
      length(upperbound) != ncol(cormatrix) ||
      length(lowerbound) != ncol(cormatrix) ||
      ncol(cormatrix) != nrow(cormatrix) ||
      length(means) != nrow(cormatrix) ||
      length(sds) != nrow(cormatrix)
    ) {
      message("ERROR:\nParameters have unequal length & dimensions
              \nlowerbound, upperbound, means, sds must all be vectors of equal length (k) \nand cormatrix must be of k dimensions")
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
    # cat(paste0("Variable ", i))
    cat("Variable ", i)
    df[, i] <- lfast(n, means[i], sds[i], lowerbound[i], upperbound[i])
  }

  cat(paste0("\nArranging data to match correlations\n"))
  new_df <- lcor(df, cormatrix)

  if (exists("new_df")) {
    cat(paste0("\nSuccessfully generated correlated variables\n"))
  }

  return(new_df)
} ### END make_items function
