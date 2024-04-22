#' Create a dataframe of correlated scales  from different dataframes of scale items
#'
#' @name correlateScales
#'
#' @description \code{correlateScales()} creates a dataframe of
#' scale items representing correlated constructs,
#' as one might find in a completed questionnaire.
#'
#' @details Correlated rating-scale items generally are summed or averaged to create a measure of an "unobservable", or "latent", construct.
#' \code{correlateScales()} takes several such dataframes of rating-scale
#' items and rearranges their rows so that the scales are correlated according
#' to a predefined correlation matrix. Univariate statistics for each dataframe
#' of rating-scale items do not change,
#' but their correlations with rating-scale items in other dataframes do.
#'
#' @param dataframes  a list of 'k' dataframes to be rearranged and combined
#' @param scalecors target correlation matrix - should be a symmetric
#' k*k positive-semi-definite matrix, where 'k' is the number of dataframes
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
#' Att_1 <- makeItems(n = n, means = means_1, sds = sds_1,
#' lowerbound = rep(lower, 4), upperbound = rep(upper, 4),
#' cormatrix = cor_1)
#'
#'
#'
#' ### attitude #2
#' cor_2 <- makeCorrAlpha(items = 5, alpha = 0.85)
#' means_2 <- c(2.5, 2.5, 3.0, 3.0, 3.5)
#' sds_2 <- c(1.0, 1.0, 0.9, 1.0, 1.5)
#'
#' Att_2 <- makeItems(n = n, means = means_2, sds = sds_2,
#' lowerbound = rep(lower, 5), upperbound = rep(upper, 5),
#' cormatrix = cor_2)
#'
#'
#'
#' ### attitude #3
#' cor_3 <- makeCorrAlpha(items = 6, alpha = 0.75)
#' means_3 <- c(2.5, 2.5, 3.0, 3.0, 3.5, 3.5)
#' sds_3 <- c(1.0, 1.5, 1.0, 1.5, 1.0, 1.5)
#'
#' Att_3 <- makeItems(n = n, means = means_3, sds = sds_3,
#' lowerbound = rep(lower, 6), upperbound = rep(upper, 6),
#' cormatrix = cor_3)
#'
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
  findMatchingRows <- function(sums_vector, df) {
    used_rows <- rep(FALSE, nrow(df)) # Track which rows have been used
    # Create an empty dataframe with the same structure plus one for the value
    results_df <- data.frame(matrix(ncol = ncol(df) + 1, nrow = 0))
    colnames(results_df) <- c(colnames(df), "sums")

    for (i in seq_along(sums_vector)) {
      row_sum <- sums_vector[i]
      # Find unused rows where the sum equals the current value
      row_indices <- which(apply(df, 1, sum) == row_sum & !used_rows)
      # Check if there are any unused matching rows left
      if (length(row_indices) > 0) {
        first_match <- row_indices[1] # Take the first available match
        new_row <- df[first_match, , drop = FALSE] # Extract the row
        # new_row$sums <- row_sum # Append the vector value to the row
        results_df <- rbind(results_df, new_row) ## Add row to results df
        used_rows[first_match] <- TRUE # Mark this row as used
      }
    } ## END sums_vector loop

    return(results_df)
  } ## END findMatchingRows function


  ## Function to rename columns for their dataframe
  rename_columns <- function(data_list) {
    # for (df_name in seq_along(data_list)) {
      for (var_name in names(data_list)) {
        new_col_names <- paste(var_name, 1:ncol(data_list[[var_name]]),
          sep = "_"
        )
        colnames(data_list[[var_name]]) <- new_col_names
      # }
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



  ## calculate row sums of the dataframes
  factor_sums <- vector("list", length(factor_list))
  for (s in 1:length(factor_list)) {
    factor_sums[[s]] <- apply(factor_list[[s]], 1, sum)
  }

  ## reorder the sums according  target correlations
  ordered_sums <- lcor(factor_sums, scalecors)

  ## allocate dataframe rows to corresponding sum values
  factor <- vector("list", length(factor_list))
  for (l in 1:length(factor_list)) {
    factor[[l]] <- findMatchingRows(ordered_sums[, l], factor_list[[l]])
  }

  ## bring all columns together into one dataframe
  new_df <- bind_cols(factor)

  if (!is.null(new_df) && nrow(new_df) > 0) {
    message("New dataframe successfully created")
  }


  return(new_df)
}
