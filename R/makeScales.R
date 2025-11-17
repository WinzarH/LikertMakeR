#' Synthesise rating-scale data with given first and second moments and a
#' predefined correlation matrix
#'
#' @name makeScales
#'
#' @description `makeScales()` generates a dataframe of random discrete
#'  values so the data replicate a rating scale,
#'  and are correlated close to a predefined correlation matrix.
#'
#'  `makeScales()` is wrapper function for:
#'
#'   * [lfast()], generates a dataframe that best fits the desired
#'    moments, and
#'   * [lcor()], which rearranges values in each column of the dataframe
#'    so they closely match the desired correlation matrix.
#'
#' @param n (positive, int) sample-size - number of observations
#' @param means (real) target means: a vector of length k
#'  of mean values for each scale item
#' @param sds (positive, real) target standard deviations: a vector of length k
#'  of standard deviation values for each scale item
#' @param lowerbound (positive, int) a vector of length k
#'  (same as rows & columns of correlation matrix) of values for lower bound
#'  of each scale item (e.g. '1' for a 1-5 rating scale). Default = 1.
#' @param upperbound (positive, int) a vector of length k
#'  (same as rows & columns of correlation matrix) of values for upper bound
#'  of each scale item (e.g. '5' for a 1-5 rating scale). Default = 5.
#' @param items (positive, int) a vector of length k of number of items in each scale. Default = 1.
#' @param cormatrix (real, matrix) the target correlation matrix:
#'  a square symmetric positive-semi-definite matrix of values ranging
#'  between -1 and +1, and '1' in the diagonal.
#'
#' @return a dataframe of rating-scale values
#'
#'
#' @examples
#'
#' ## Example 1: four correlated items (questions)
#'
#' ### define parameters
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
#' scale_names <- c("Q1", "Q2", "Q3", "Q4")
#' rownames(corMat) <- scale_names
#' colnames(corMat) <- scale_names
#'
#' ### apply function
#'
#' df1 <- makeScales(
#'   n = n, means = dfMeans, sds = dfSds,
#'   lowerbound = lowerbound, upperbound = upperbound, cormatrix = corMat
#' )
#'
#' ### test function
#'
#' str(df1)
#'
#' #### means
#' apply(df1, 2, mean) |> round(3)
#'
#' #### standard deviations
#' apply(df1, 2, sd) |> round(3)
#'
#' #### correlations
#' cor(df1) |> round(3)
#'
#'
#'
#' ## Example 2: five correlated Likert scales
#'
#' ### a study on employee engagement and organizational climate:
#'  # Job Satisfaction (JS)
#'  # Organizational Commitment (OC)
#'  # Perceived Supervisor Support (PSS)
#'  # Work Engagement (WE)
#'  # Turnover Intention (TI) (reverse-related to others).
#'
#' ### define parameters
#'
#' n <- 128
#' dfMeans <- c(3.8, 3.6, 3.7, 3.9, 2.2)
#' dfSds <-   c(0.7, 0.8, 0.7, 0.6, 0.9)
#' lowerbound <- rep(1, 5)
#' upperbound <- rep(5, 5)
#' items <- c(4, 4, 3, 3, 3)
#'
#' corMat <- matrix(
#'   c(
#'     1.00, 0.72, 0.58, 0.65, -0.55,
#'     0.72, 1.00, 0.54, 0.60, -0.60,
#'     0.58, 0.54, 1.00, 0.57, -0.45,
#'     0.65, 0.60, 0.57, 1.00, -0.50,
#'     -0.55, -0.60, -0.45, -0.50, 1.00
#'    ),
#'  nrow = 5, ncol = 5
#' )
#'
#' scale_names <- c("JS", "OC", "PSS", "WE", "TI")
#' rownames(corMat) <- scale_names
#' colnames(corMat) <- scale_names
#'
#' ### apply function
#'
#' df2 <- makeScales(
#'   n = n, means = dfMeans, sds = dfSds,
#'   lowerbound = lowerbound, upperbound = upperbound,
#'   items = items, cormatrix = corMat
#' )
#'
#' ### test function
#'
#' str(df2)
#'
#' #### means
#' apply(df2, 2, mean) |> round(3)
#'
#' #### standard deviations
#' apply(df2, 2, sd) |> round(3)
#'
#' #### correlations
#' cor(df2) |> round(3)
#'
#'
#'
#' @export
makeScales <- function(n, means, sds, lowerbound = 1, upperbound = 5, items = 1, cormatrix) {
  ####
  ###  input parameters integrity checks
  ####

  ## round correlation values to sensible values
  cormatrix <- cormatrix |> round(5)

  parameter_integrity <- function() { ## BEGIN input parameters integrity
    if (length(upperbound) != length(lowerbound) ||
      length(upperbound) != ncol(cormatrix) ||
      length(lowerbound) != ncol(cormatrix) ||
      ncol(cormatrix) != nrow(cormatrix) ||
      length(means) != nrow(cormatrix) ||
      length(sds) != nrow(cormatrix) ||
      length(items) != nrow(cormatrix)
    ) {
      message("ERROR:\nParameters have unequal length & dimensions
              \nlowerbound, upperbound, means, sds must be equal length (k)
              \nand cormatrix must be of k dimensions")
      return(NULL)
    }
  } ## END input parameters integrity

  ####
  check_PD_matrix <- function() { ## BEGIN check positive definite matrix
    if (min(eigen(cormatrix)$values) < 0) {
      stop("ERROR:\ncormatrix is not Positive Definite.
         \nRequested correlations are not possible \n")
      return(NULL)
    }
  } ## END check positive definite matrix


  check_PD_matrix

  k <- ncol(cormatrix)

  scale_names <- rownames(cormatrix)

  # Recycle single values to vectors if needed
  if (length(lowerbound) == 1) lowerbound <- rep(lowerbound, k)
  if (length(upperbound) == 1) upperbound <- rep(upperbound, k)
  if (length(items) == 1) items <- rep(items, k)

  parameter_integrity

  ## end integrity checks
  ####

  # Initialize the dataframe
  df <- as.data.frame(matrix(nrow = n, ncol = k))

  for (i in 1:k) {
    cat("Variable ", i)
    df[, i] <- lfast(n, means[i], sds[i], lowerbound[i], upperbound[i], items[i])
  }

  cat(paste0("\nArranging data to match correlations\n"))
  new_df <- lcor(df, cormatrix)

  if (exists("new_df")) {
    cat(paste0("\nSuccessfully generated correlated variables\n\n"))
  }

  colnames(new_df) <- scale_names

  return(new_df) |> as.data.frame()
} ### END make_scales function

