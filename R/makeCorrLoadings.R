#'
#'
#' @name makeCorrLoadings
#'
#' @description \code{makeCorrLoadings()} generates a correlation matrix of
#' inter-item correlations based on item factor loadings as might be seen in
#' _Exploratory Factor Analysis_ (**EFA**) or a _Structural Equation Model_
#' (**SEM**).
#'
#' Such a correlation matrix can be applied to the \code{makeItems()}
#' function to generate synthetic data with those predefined factor structures.
#'
#' @param factor_loadings (numeric matrix) **k** (items) by **f** (factors)
#'  matrix of **standardised** factor loadings. Item names and Factor names
#'  can be taken from the row_names (items) and the column_names (factors),
#'  if present.
#' @param factor_cor (numeric matrix) target mean,
#' between upper and lower bounds
#' @param diagnostics  (logical) Default = _FALSE_.
#' If _diagnostics = TRUE_, the function outputs a diagnostic table with:
#'  - Variance explained per item
#'  - Residual variance per item
#'  - Comments to alert extreme factor loadings
#'
#' @return a list including correlation matrix,
#' McDonald's Omega and summary statistics
#'
#' @importFrom Matrix nearPD
#'
#' @export makeCorrLoadings
#'
#' @examples
#'
#' ### Define factor loadings with item and factor names
#' fl_named <- matrix(
#'   c(0.05, 0.10, 0.60,
#'     0.10, 0.60, 0.05,
#'     0.70, 0.05, 0.05,
#'     0.80, 0.00, 0.00
#'     ),
#'     nrow = 4, ncol = 3, byrow = TRUE
#'                   )
#'  rownames(fl_named) <- c("Q1", "Q2", "Q3", "Q4")
#'  colnames(fl_named) <- c("Factor1", "Factor2", "Factor3")
#'
#' ### Define factor correlation matrix
#' factor_cor <- matrix(c(1.0, 0.6, 0.5,
#'                        0.6, 1.0, 0.4,
#'                        0.5, 0.4, 1.0),
#'                nrow = 3, byrow = TRUE)
#'
#' rownames(factor_cor) <- colnames(factor_cor) <- colnames(fl_named)
#'
#' # Run function with diagnostics enabled
#' result <- makeCorrLoadings(fl_named, factor_cor, diagnostics = TRUE)
#'
#' print(result)
#' item_correlations <- result$cor_matrix
#'
#' # Run without diagnostics and no factor-correlations (independent factors)
#' independent_factors_result <- makeCorrLoadings(fl_named)
#'
#' print(independent_factors_result)
#' if_item_cors <- independent_factors_result$cor_matrix
#'


makeCorrLoadings <- function(factor_loadings, factor_cor = NULL, diagnostics = FALSE) {
  # Function to validate factor loadings and factor correlation matrix before use
  validateLoadings <- function(factor_loadings, factor_cor) {
    # Check that factor_loadings is a numeric matrix
    if (!is.matrix(factor_loadings) || !is.numeric(factor_loadings)) {
      stop(
        "Error: ",
        "factor_loadings must be a numeric matrix where ",
        "rows = items and columns = factors."
      )
    }

    # Get dimensions
    num_items <- nrow(factor_loadings)
    num_factors <- ncol(factor_loadings)

    # Ensure factor correlation matrix is square and matches  number of factors
    if (!is.null(factor_cor)) {
      if (!is.matrix(factor_cor) || !is.numeric(factor_cor)) {
        stop("Error: factor_cor must be a numeric square matrix.")
      }

      if (!all(dim(factor_cor) == c(num_factors, num_factors))) {
        stop(
          "Error: ",
          "factor_cor must be a square matrix with dimensions equal ",
          "to the number of factors."
        )
      }

      # Check if factor correlation matrix is positive definite
      if (any(eigen(factor_cor)$values <= 0)) {
        stop(
          "Error: ",
          "Provided factor correlation matrix is not positive definite!"
        )
      }
    }

    # Compute variance explained by factor loadings for each item
    variance_explained <- rowSums(factor_loadings^2)

    # Check for overloaded items (sum of squares > 1)
    overloaded_items <- which(variance_explained > 1)
    if (length(overloaded_items) > 0) {
      stop(paste(
        "Error: ",
        " The following items have factor loadings that exceed a total",
        " variance of 1, indicating an input error:",
        paste(overloaded_items, collapse = ", ")
      ))
    }

    # If everything is valid, return TRUE
    return(TRUE)
  }

  ## Function for calculating McDonald's Omega
  computeOmega <- function(factor_loadings, factor_cor = NULL) {
    num_factors <- ncol(factor_loadings)
    # Omega without factor correlation
    omega_values_independent <- numeric(num_factors)
    # Omega with factor correlation
    omega_values_adjusted <- numeric(num_factors)


    # Residual variance per item
    residual_variance <- 1 - rowSums(factor_loadings^2)

    for (j in 1:num_factors) {
      lambda_j <- matrix(factor_loadings[, j],
                         nrow = nrow(factor_loadings),
                         ncol = 1
      ) # Ensure matrix format

      # Standard (Independent) Omega
      omega_values_independent[j] <-
        sum(lambda_j^2) / (sum(lambda_j^2) + sum(residual_variance))

      # Adjusted Omega (Accounting for Inter-Factor Correlation)
      if (!is.null(factor_cor)) {
        # Extract factor-level loadings
        lambda_factors <- matrix(factor_loadings[j, ], nrow = 1)
        numerator <- lambda_factors %*% factor_cor %*% t(lambda_factors)
        denominator <- numerator + sum(residual_variance)
        omega_values_adjusted[j] <- numerator / denominator
      } else {
        # No adjustment if factors uncorrelated
        omega_values_adjusted[j] <- omega_values_independent[j]
      }
    }

    return(list(
      omega_independent = omega_values_independent,
      omega_adjusted = omega_values_adjusted
    ))
  }


  # Validate inputs first
  validation_result <- tryCatch(
    validateLoadings(factor_loadings, factor_cor),
    error = function(e) {
      message("Validation failed: ", e$message)
      return(FALSE)
    }
  )

  # Stop execution if validation fails
  if (!validation_result) {
    stop(
      "Error: Input validation failed. ",
      "Please check factor loadings and factor correlation matrix."
    )
  }

  # Number of items and factors
  num_items <- nrow(factor_loadings)
  num_factors <- ncol(factor_loadings)

  # Preserve row and column names (if available)
  item_names <- rownames(factor_loadings)
  column_names <- colnames(factor_loadings)


  # If no factor correlation matrix is provided, assume independent factors
  if (is.null(factor_cor)) {
    # Identity matrix (factors are uncorrelated)
    factor_cor <- diag(num_factors)
  }

  # Compute residual variances for each item
  variance_explained <- rowSums(factor_loadings^2)
  residual_variances <- 1 - variance_explained

  # Compute both versions of Omega
  omega_values <- computeOmega(factor_loadings, factor_cor)

  # Construct the raw correlation matrix: R = L Φ L'
  raw_correlation_matrix <- factor_loadings %*% factor_cor %*% t(factor_loadings)

  # Adjust diagonal elements to include residual variances
  diag(raw_correlation_matrix) <- diag(raw_correlation_matrix) + residual_variances

  # **Rescale the correlation matrix to force diagonals to 1**
  # Get square root of variances
  diag_sqrt <- sqrt(diag(raw_correlation_matrix))
  # Normalize
  correlation_matrix <- raw_correlation_matrix / (diag_sqrt %o% diag_sqrt)

  # If row names exist, apply them to the correlation matrix
  if (!is.null(item_names)) {
    rownames(correlation_matrix) <- item_names
    colnames(correlation_matrix) <- item_names
  }

  # Generate diagnostics if requested
  if (diagnostics) {
    diagnostics_table <- data.frame(
      Item = if (!is.null(item_names)) {
        item_names
      } else {
        paste0("Item", 1:num_items)
      },
      VarianceExplained = variance_explained,
      ResidualVariance = residual_variances,
      Comment = ifelse(variance_explained > 0.9, "High Loadings",
                       ifelse(variance_explained < 0.2, "Low Loadings", "OK")
      )
    )

    # Print diagnostics table
    # print(diagnostics_table)
  }

  # Return results as a list
  return(list(
    cor_matrix = correlation_matrix,
    residual_variances = residual_variances,
    variance_explained = variance_explained,
    factor_loadings = factor_loadings,
    factor_cor = factor_cor,
    omega_independent = omega_values$omega_independent, # Standard Omega
    omega_adjusted = omega_values$omega_adjusted, # Adjusted Omega
    item_names = item_names,
    column_names = column_names,
    diagnostics_table = if (diagnostics) {
      diagnostics_table
    } else {
      NULL
    } # Include diagnostics if requested
  )) # end return list
}  # end function
