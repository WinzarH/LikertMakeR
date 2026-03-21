#' Sensitivity of Cronbach's alpha to scale design parameters
#'
#' Computes how Cronbach's alpha changes as a function of either
#' the average inter-item correlation (\eqn{\bar{r}}) or the number
#' of items (\eqn{k}), holding the other parameter constant.
#'
#' The function supports two modes:
#' \itemize{
#'   \item Empirical: derive \eqn{k} and \eqn{\bar{r}} from a dataset
#'   \item Theoretical: specify \eqn{k} and \eqn{\bar{r}} directly
#' }
#'
#' @param data A data frame or matrix of item responses. If provided,
#'   \eqn{k} and \eqn{\bar{r}} are computed from the data.
#'
#' @param k Number of items. Required if \code{data} is not supplied.
#'
#' @param r_bar Average inter-item correlation. Required if \code{data}
#'   is not supplied.
#'
#' @param vary Character string indicating which parameter to vary:
#'   \code{"r_bar"} (default) or \code{"k"}.
#'
#' @param k_range Numeric vector of item counts to evaluate when
#'   \code{vary = "k"}. Default is \code{2:20}.
#'
#' @param r_bar_range Numeric vector of average inter-item correlations
#'   to evaluate when \code{vary = "r_bar"}. Default is
#'   \code{seq(0.05, 0.9, by = 0.05)}.
#'
#' @param plot Logical; if \code{TRUE}, a base R plot is produced.
#'   Default is \code{TRUE}.
#'
#' @param digits Number of decimal places for rounding output.
#'   Default is \code{3}.
#'
#' @return A data frame with columns:
#' \itemize{
#'   \item \code{k}: number of items
#'   \item \code{r_bar}: average inter-item correlation
#'   \item \code{alpha}: Cronbach's alpha
#' }
#'
#' The returned object includes an attribute \code{"baseline"} containing
#' the reference \eqn{k} and \eqn{\bar{r}} values.
#'
#' @seealso \code{\link{alpha}}, \code{\link{reliability}}
#'
#' @examples
#' # Theoretical example
#'
#' \dontrun{
#' alpha_sensitivity(k = 6) # produces plot
#' }
#'
#' alpha_sensitivity(k = 6, r_bar = 0.4, plot = FALSE)
#'
#' # Vary number of items
#' alpha_sensitivity(k = 6, r_bar = 0.4, vary = "k", plot = FALSE)
#'
#' # Empirical example
#' df <- data.frame(
#'   V1 = c(1, 2, 3, 4, 5),
#'   V2 = c(3, 2, 4, 2, 5),
#'   V3 = c(2, 1, 5, 4, 3)
#' )
#'
#' \dontrun{
#' alpha_sensitivity(data = df) # produces plot
#' }
#'
#' alpha_sensitivity(df, vary = "r_bar", plot = FALSE)
#'
#' alpha_sensitivity(df, vary = "k", plot = FALSE)
#'
#' @export
alpha_sensitivity <- function(
  data = NULL,
  k = NULL,
  r_bar = NULL,
  vary = c("r_bar", "k"),
  k_range = NULL,
  r_bar_range = NULL,
  plot = TRUE,
  digits = 3
) {
  vary <- match.arg(vary)

  # ------------------ input validation ------------------
  if (!is.null(data)) {
    if (!is.null(k) || !is.null(r_bar)) {
      stop("Provide either 'data' OR ('k' and 'r_bar'), not both.",
        call. = FALSE
      )
    }

    X <- as.data.frame(data)

    if (ncol(X) < 2) {
      stop("data must contain at least 2 items (columns).",
        call. = FALSE
      )
    }

    R <- stats::cor(X, use = "pairwise.complete.obs")

    k <- ncol(R)
    r_bar <- mean(R[upper.tri(R)])
  } else {
    if (is.null(k)) {
      stop("Provide either 'data' or 'k'.",
        call. = FALSE
      )
    }

    # Default value for exploratory use
    if (is.null(r_bar)) {
      r_bar <- 0.3
    }

    if (!is.numeric(k) || length(k) != 1 || k < 2) {
      stop("'k' must be a single integer >= 2.",
        call. = FALSE
      )
    }

    if (!is.numeric(r_bar) || length(r_bar) != 1 || r_bar <= 0 || r_bar >= 1) {
      stop("'r_bar' must be a single value between 0 and 1.",
        call. = FALSE
      )
    }
  }

  # ------------------ defaults ------------------

  if (is.null(r_bar_range)) {
    r_bar_range <- seq(0.05, 0.9, by = 0.05)
  }

  if (is.null(k_range)) {
    k_range <- 2:20
  }

  # ------------------ computation ------------------

  if (vary == "r_bar") {
    alpha_vals <- (k * r_bar_range) / (1 + (k - 1) * r_bar_range)

    out <- data.frame(
      k = k,
      r_bar = r_bar_range,
      alpha = alpha_vals
    )
  } else {
    alpha_vals <- (k_range * r_bar) / (1 + (k_range - 1) * r_bar)

    out <- data.frame(
      k = k_range,
      r_bar = r_bar,
      alpha = alpha_vals
    )
  }

  # rounding
  out$alpha <- round(out$alpha, digits)
  out$r_bar <- round(out$r_bar, digits)

  # baseline attribute
  attr(out, "baseline") <- list(k = k, r_bar = r_bar)

  # ------------------ plotting ------------------

  if (isTRUE(plot)) {
    if (vary == "r_bar") {
      plot(
        out$r_bar, out$alpha,
        type = "l",
        xlab = "Average inter-item correlation (mean_r)",
        ylab = "Cronbach's alpha",
        main = paste0("Alpha sensitivity (k = ", k, ")")
      )

      abline(h = c(0.7, 0.8), lty = 2)
    } else {
      plot(
        out$k, out$alpha,
        type = "l",
        xlab = "Number of items (k)",
        ylab = "Cronbach's alpha",
        main = paste0("Alpha sensitivity (mean_r = ", round(r_bar, digits), ")")
      )

      abline(h = c(0.7, 0.8), lty = 2)
    }
  }

  return(out)
}
