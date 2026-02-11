#' Dataframe of correlated scales from different dataframes of scale items
#'
#' @name correlateScales
#'
#' @description `correlateScales()` creates a dataframe of
#' scale items representing correlated constructs,
#' as one might find in a completed questionnaire.
#'
#' @details Correlated rating-scale items generally are summed or
#' averaged to create a measure of an "unobservable", or "latent", construct.
#' `correlateScales()` takes several such dataframes of rating-scale
#' items and rearranges their rows so that the scales are correlated according
#' to a predefined correlation matrix. Univariate statistics for each dataframe
#' of rating-scale items do not change,
#' but their correlations with rating-scale items in other dataframes do.
#'
#' @param dataframes  a list of 'k' dataframes to be rearranged and combined
#' @param scalecors target correlation matrix - should be a symmetric
#' \eqn{k \times k} positive-semi-definite matrix,
#' where 'k' is the number of dataframes
#'
#' @importFrom dplyr bind_cols
#'
#' @return Returns a dataframe whose columns are taken from the starter
#' dataframes and whose summated values are correlated according to a
#' user-specified correlation matrix
#'
#' @examples
#'
#' ## three attitudes and a behavioural intention
#' n <- 32
#' lower <- 1
#' upper <- 5
#'
#' ### attitude #1
#' cor_1 <- makeCorrAlpha(items = 4, alpha = 0.90)
#' means_1 <- c(2.5, 2.5, 3.0, 3.5)
#' sds_1 <- c(0.9, 1.0, 0.9, 1.0)
#'
#' Att_1 <- makeScales(
#'   n = n, means = means_1, sds = sds_1,
#'   lowerbound = rep(lower, 4), upperbound = rep(upper, 4),
#'   items = 4,
#'   cormatrix = cor_1
#' )
#'
#'
#' ### attitude #2
#' cor_2 <- makeCorrAlpha(items = 5, alpha = 0.85)
#' means_2 <- c(2.5, 2.5, 3.0, 3.0, 3.5)
#' sds_2 <- c(1.0, 1.0, 0.9, 1.0, 1.5)
#'
#' Att_2 <- makeScales(
#'   n = n, means = means_2, sds = sds_2,
#'   lowerbound = rep(lower, 5), upperbound = rep(upper, 5),
#'   items = 5,
#'   cormatrix = cor_2
#' )
#'
#'
#' ### attitude #3
#' cor_3 <- makeCorrAlpha(items = 6, alpha = 0.75)
#' means_3 <- c(2.5, 2.5, 3.0, 3.0, 3.5, 3.5)
#' sds_3 <- c(1.0, 1.5, 1.0, 1.5, 1.0, 1.5)
#'
#' Att_3 <- makeScales(
#'   n = n, means = means_3, sds = sds_3,
#'   lowerbound = rep(lower, 6), upperbound = rep(upper, 6),
#'   items = 6,
#'   cormatrix = cor_3
#' )
#'
#'
#' ### behavioural intention
#' intent <- lfast(n, mean = 3.0, sd = 3, lowerbound = 0, upperbound = 10) |>
#'   data.frame()
#' names(intent) <- "int"
#'
#'
#' ### target scale correlation matrix
#' scale_cors <- matrix(
#'   c(
#'     1.0, 0.6, 0.5, 0.3,
#'     0.6, 1.0, 0.4, 0.2,
#'     0.5, 0.4, 1.0, 0.1,
#'     0.3, 0.2, 0.1, 1.0
#'   ),
#'   nrow = 4
#' )
#'
#' data_frames <- list("A1" = Att_1, "A2" = Att_2, "A3" = Att_3, "Int" = intent)
#'
#'
#' ### apply the function
#' my_correlated_scales <- correlateScales(
#'   dataframes = data_frames,
#'   scalecors = scale_cors
#' )
#' head(my_correlated_scales)
#'
#' @export correlateScales
#'
correlateScales <- function(dataframes, scalecors) {
  ###
  ##   BEGIN helper functions
  ###

  ## Function finding matching sums values and linking rows
  ## Use lookup table for faster matching
  findMatchingRows <- function(sums_vector, df, df_row_sums) {
    n <- nrow(df)
    used_rows <- rep(FALSE, n)

    # Create a lookup table (list) grouped by sum values
    # This avoids repeated searching through the entire vector
    sum_lookup <- split(seq_len(n), df_row_sums)

    # Pre-allocate results matrix for speed (faster than growing dataframe)
    results_matrix <- matrix(nrow = 0, ncol = ncol(df))
    colnames(results_matrix) <- colnames(df)

    for (i in seq_along(sums_vector)) {
      row_sum <- sums_vector[i]

      # Get all rows with this sum value via hash table lookup
      candidate_indices <- sum_lookup[[as.character(row_sum)]]

      if (!is.null(candidate_indices) && length(candidate_indices) > 0) {
        # Find first unused candidate from the small set of candidates
        available <- candidate_indices[!used_rows[candidate_indices]]

        if (length(available) > 0) {
          first_match <- available[1]
          # Add row to results (matrix rbind is faster than dataframe rbind)
          results_matrix <- rbind(results_matrix, df[first_match, , drop = FALSE])
          used_rows[first_match] <- TRUE
        }
      }
    } ## END sums_vector loop

    # Convert matrix back to dataframe
    results_df <- as.data.frame(results_matrix)
    colnames(results_df) <- colnames(df)

    return(results_df)
  } ## END findMatchingRows function


  ## Function to rename columns for their dataframe
  rename_columns <- function(data_list) {
    for (var_name in names(data_list)) {
      new_col_names <- paste(var_name, 1:ncol(data_list[[var_name]]),
        sep = "_"
      )
      colnames(data_list[[var_name]]) <- new_col_names
    }
    return(data_list)
  }

  ## Function to check if all dataframes have the same number of rows
  all_same_rows <- function(data_list) {
    # number of rows from each dataframe
    row_counts <- sapply(data_list, nrow)
    # Check if all values in row_counts are the same
    all_equal <- all(row_counts == row_counts[1])
    return(all_equal)
  } ## END same-row-numbers function

  ## Function to check that all objects are dataframes
  convert_to_df <- function(lst) {
    for (i in seq_along(lst)) {
      if (!is.data.frame(lst[[i]])) {
        warning(paste("Converting object at index ", i, " to a dataframe."))
        lst[[i]] <- data.frame(lst[[i]])
      }
    }
    return(lst)
  } ## END numeric-to-df function

  ## Function to check for valid correlation matrix
  is_valid_correlation_matrix <- function(mat) {
    # Check if the matrix is square
    if (nrow(mat) != ncol(mat)) {
      return(FALSE)
    }

    # Check diagonal elements are all 1
    if (!all(diag(mat) == 1)) {
      return(FALSE)
    }

    # Check all values are between -1 and 1
    if (any(mat < -1 | mat > 1)) {
      return(FALSE)
    }

    # Check the matrix is symmetric
    if (!identical(mat, t(mat))) {
      return(FALSE)
    }

    return(TRUE)
  }

  ###
  ##   END helper functions
  ###


  ###
  ## data integrity checks
  ###
  dataframes <- convert_to_df(dataframes)

  if (all_same_rows(dataframes) == FALSE) {
    stop("Dataframes must have equal number or rows")
  }

  factor_list <- rename_columns(dataframes)

  if (is_valid_correlation_matrix(scalecors) == FALSE) {
    stop("Correlation matrix is not square, symmetrical, or valid values")
  }

  if (min(eigenvalues(scalecors)) < 0) {
    stop("Correlation matrix is not Positive Definite, so not feasible")
  }

  ## END integrity checks


  ## Vectorize row sum calculation using lapply
  ## calculate row sums of the dataframes
  factor_sums <- lapply(factor_list, function(df) {
    rowSums(df)
  })

  ## reorder the sums according  target correlations
  ordered_sums <- lcor(factor_sums, scalecors)

  ## Vectorize row matching using Map (parallel lapply)
  ## allocate dataframe rows to corresponding sum values
  factor <- Map(
    findMatchingRows,
    sums_vector = asplit(ordered_sums, 2), # Split matrix by columns (MARGIN = 2)
    df = factor_list,
    df_row_sums = factor_sums
  )

  ## bring all columns together into one dataframe
  new_df <- dplyr::bind_cols(factor)

  if (!is.null(new_df) && nrow(new_df) > 0) {
    message("New dataframe successfully created")
  }

  return(new_df)
}
