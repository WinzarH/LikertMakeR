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
#' # Job Satisfaction (JS)
#' # Organizational Commitment (OC)
#' # Perceived Supervisor Support (PSS)
#' # Work Engagement (WE)
#' # Turnover Intention (TI) (reverse-related to others).
#'
#' ### define parameters
#'
#' n <- 128
#' dfMeans <- c(3.8, 3.6, 3.7, 3.9, 2.2)
#' dfSds <- c(0.7, 0.8, 0.7, 0.6, 0.9)
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
#'   ),
#'   nrow = 5, ncol = 5
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
#' @export
makeScales <- function(n, means, sds,
                       lowerbound = 1, upperbound = 5,
                       items = 1, cormatrix) {

  ####
  ### Basic scalar checks
  ####

  if (!is.numeric(n) || length(n) != 1L || !is.finite(n) || n <= 0 || n != as.integer(n)) {
    stop("'n' must be a single positive integer.")
  }
  n <- as.integer(n)

  ####
  ### Correlation matrix checks
  ####

  if (!is.matrix(cormatrix) || !is.numeric(cormatrix)) {
    stop("'cormatrix' must be a numeric matrix.")
  }
  if (nrow(cormatrix) != ncol(cormatrix)) {
    stop("'cormatrix' must be a square matrix.")
  }

  # Round correlation values to sensible values
  cormatrix <- round(cormatrix, 5L)

  k <- ncol(cormatrix)

  # Symmetry
  if (!isTRUE(all.equal(cormatrix, t(cormatrix), tolerance = 1e-8))) {
    stop("'cormatrix' must be symmetric.")
  }

  # Diagonal close to 1
  if (!all(abs(diag(cormatrix) - 1) < 1e-8)) {
    stop("The diagonal of 'cormatrix' must all be 1.")
  }

  # Values in [-1, 1]
  if (any(cormatrix < -1 - 1e-8 | cormatrix > 1 + 1e-8)) {
    stop("All entries of 'cormatrix' must lie in the interval [-1, 1].")
  }

  # Positive semi-definite check
  check_PD_matrix <- function() {
    eigvals <- eigen(cormatrix, symmetric = TRUE, only.values = TRUE)$values
    if (min(eigvals) < -1e-8) {
      stop(
        "cormatrix is not Positive Semi-Definite.\n",
        "Requested correlations are not possible."
      )
    }
  }
  check_PD_matrix()

  ####
  ### Naming of variables
  ####

  if (is.null(rownames(cormatrix)) || is.null(colnames(cormatrix))) {
    scale_names <- paste0("V", seq_len(k))
    rownames(cormatrix) <- scale_names
    colnames(cormatrix) <- scale_names
  } else {
    if (!identical(rownames(cormatrix), colnames(cormatrix))) {
      warning("Row and column names of 'cormatrix' do not match.",
              "\nUsing rownames for both.")
      scale_names <- rownames(cormatrix)
      colnames(cormatrix) <- scale_names
    } else {
      scale_names <- rownames(cormatrix)
    }
  }

  ####
  ### Vector checks for means and sds
  ####

  if (!is.numeric(means) || length(means) != k || any(!is.finite(means))) {
    stop("'means' must be a numeric vector of length ", k,
         " with all finite values.")
  }

  if (!is.numeric(sds) || length(sds) != k || any(!is.finite(sds)) || any(sds <= 0)) {
    stop("'sds' must be a numeric vector of positive, ",
         "finite values of length ", k, ".")
  }

  ####
  ### Recycle bounds and items, then do integrity checks
  ####

  # Recycle single values to vectors if needed
  if (length(lowerbound) == 1L) lowerbound <- rep(lowerbound, k)
  if (length(upperbound) == 1L) upperbound <- rep(upperbound, k)
  if (length(items)      == 1L) items      <- rep(items,      k)

  parameter_integrity <- function() {

    # lengths
    if (length(lowerbound) != k || length(upperbound) != k ||
        length(items)      != k) {
      stop(
        "Parameters have unequal length and dimensions.",
        "\nlowerbound, upperbound, items must each have length k = ", k,
        ", and 'means' and 'sds' must also have length k."
      )
    }

    # types and finiteness
    if (!is.numeric(lowerbound) || any(!is.finite(lowerbound))) {
      stop("'lowerbound' must be a numeric vector of finite values.")
    }
    if (!is.numeric(upperbound) || any(!is.finite(upperbound))) {
      stop("'upperbound' must be a numeric vector of finite values.")
    }
    if (!is.numeric(items) || any(!is.finite(items))) {
      stop("'items' must be a numeric vector of finite values.")
    }

    # bounds order
    if (any(lowerbound >= upperbound)) {
      stop("All 'lowerbound' values must be strictly less than the ",
      "corresponding 'upperbound' values.")
    }

    # items as positive integers
    if (any(items <= 0) || any(items != as.integer(items))) {
      stop("'items' must contain positive integers (number of items per scale).")
    }
  }

  parameter_integrity()

  # Coerce items to integer now that they are validated
  items <- as.integer(items)

  # Optional: warn if means are outside bounds (but don't stop)
  if (any(means < lowerbound | means > upperbound)) {
    stop("Some 'means' are outside their corresponding",
         " [lowerbound, upperbound] ranges.")
  }

  ####
  ### Data generation
  ####

  # Initialize the dataframe
  df <- as.data.frame(matrix(NA_real_, nrow = n, ncol = k))

  for (i in seq_len(k)) {
    cat("Variable ", i, ": ", scale_names[i], " - ")
    df[, i] <- lfast(
      n          = n,
      mean       = means[i],
      sd         = sds[i],
      lowerbound = lowerbound[i],
      upperbound = upperbound[i],
      items      = items[i]
    )
  }

  cat("\nArranging data to match correlations\n")
  new_df <- lcor(df, cormatrix)

  # if (!is.matrix(new_df) && !is.data.frame(new_df)) {
  #   stop("'lcor()' did not return an object that can be converted to a data.frame.")
  # }

  new_df <- as.data.frame(new_df)
  colnames(new_df) <- scale_names

  cat("\nSuccessfully generated correlated variables\n\n")

  return(new_df)
}
