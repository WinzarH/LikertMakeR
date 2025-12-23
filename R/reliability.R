#' Estimate scale reliability for Likert and rating-scale data
#'
#' Computes internal consistency reliability estimates for a single-factor
#' scale, including Cronbach’s alpha, McDonald’s omega (total), and optional
#' ordinal (polychoric-based) variants. Confidence intervals may be obtained
#' via nonparametric bootstrap.
#'
#' The function is designed for Likert-type and rating-scale data and
#' prioritises transparent diagnostics when ordinal reliability estimates
#' are not feasible due to sparse response categories.
#'
#' @details
#' Cronbach’s alpha and McDonald’s omega are computed from Pearson correlations.
#' When \code{include = "polychoric"}, ordinal reliability estimates are computed
#' using polychoric correlations and correspond to Zumbo’s alpha and ordinal omega.
#'
#' Ordinal reliability estimates are skipped if response categories are sparse
#' or if polychoric estimation fails. Diagnostics explaining these decisions
#' are stored in the returned object and may be inspected using
#' \code{\link{ordinal_diagnostics}}.
#'
#' This function assumes a single common factor and is not intended for
#' multidimensional or structural equation modelling contexts.
#'
#'
#' @return
#' A tibble with one row per reliability coefficient and columns:
#' \itemize{
#'   \item \code{coef_name}: Name of the reliability coefficient.
#'   \item \code{estimate}: Point estimate.
#'   \item \code{ci_lower}, \code{ci_upper}: Confidence interval bounds
#'     (only present when \code{ci = TRUE}).
#'   \item \code{notes}: Methodological notes describing how the estimate
#'     was obtained.
#' }
#'
#' The returned object has class \code{"likert_reliability"} and includes
#' additional attributes containing diagnostics and bootstrap information.
#'
#' @seealso
#' \code{\link{ordinal_diagnostics}}
#'
#' @examples
#'
#' ## create dataset
#' my_cor <- LikertMakeR::makeCorrAlpha(
#'   items = 4,
#'   alpha = 0.80
#' )
#'
#' my_data <- LikertMakeR::makeScales(
#'   n = 64,
#'   means = c(2.75, 3.00, 3.25, 3.50),
#'   sds = c(1.25, 1.50, 1.30, 1.25),
#'   lowerbound = rep(1, 4),
#'   upperbound = rep(5, 4),
#'   cormatrix = my_cor
#' )
#'
#' ## run function
#' reliability(my_data)
#'
#' reliability(
#'   my_data,
#'   include = c("lambda6", "polychoric")
#' )
#'
#' \donttest{
#' ## slower (not run on CRAN checks)
#' reliability(
#'   my_data,
#'   include = "polychoric",
#'   ci = TRUE,
#'   n_boot = 200
#' )
#' }
#'
#' @param data A data frame or matrix containing item responses.
#'   Each column represents one item; rows represent respondents.
#'
#' @param include Character vector specifying which additional estimates
#'   to compute. Possible values are:
#'   \itemize{
#'     \item \code{"none"} (default): Pearson-based alpha and omega only.
#'     \item \code{"lambda6"}: Include Guttman’s lambda-6 (requires package \pkg{psych}).
#'     \item \code{"polychoric"}: Include ordinal (polychoric-based) alpha and omega.
#'   }
#'   Multiple options may be supplied.
#'
#' @param ci Logical; if \code{TRUE}, confidence intervals are computed using
#'   nonparametric bootstrap. Default is \code{FALSE}.
#'
#' @param ci_level Confidence level for bootstrap intervals.
#'   Default is \code{0.95}.
#'
#' @param n_boot Number of bootstrap resamples used when \code{ci = TRUE}.
#'   Default is \code{1000}.
#'
#' @param na_method Method for handling missing values. Either
#'   \code{"pairwise"} (default) or \code{"listwise"}.
#'
#' @param min_count Minimum observed frequency per response category required
#'   to attempt polychoric correlations. Ordinal reliability estimates are
#'   skipped if this condition is violated. Default is \code{2}.
#'
#' @param digits Number of decimal places used when printing estimates.
#'   Default is \code{3}.
#'
#' @param verbose Logical; if \code{TRUE}, warnings and progress indicators
#'   are displayed. Default is \code{TRUE}.
#'
#' @export
reliability <- function(
  data,
  include = "none",
  ci = FALSE,
  ci_level = 0.95,
  n_boot = 1000,
  na_method = c("pairwise", "listwise"),
  min_count = 2,
  digits = 3,
  verbose = TRUE
) {
  na_method <- match.arg(na_method)

  include <- match.arg(
    include,
    choices = c("none", "lambda6", "polychoric"),
    several.ok = TRUE
  )

  show_pb <- FALSE
  pb <- NULL

  if (length(include) > 1 && "none" %in% include) include <- setdiff(include, "none")

  do_lambda6 <- "lambda6" %in% include
  do_polychor <- "polychoric" %in% include

  X <- as.data.frame(data)

  if (ncol(X) < 2) stop("data must contain at least 2 items (columns).")

  if (na_method == "listwise") X <- stats::na.omit(X)

  n <- nrow(X)
  k <- ncol(X)
  if (n < 3) stop("Not enough observations to compute reliability.")

  # ------------------ helpers ------------------

  get_R_pearson <- function(Xdf) stats::cor(Xdf, use = "pairwise.complete.obs")

  .ordinal_diagnostics_df <- function(Xdf) {
    Xo <- as.data.frame(lapply(Xdf, function(col) droplevels(ordered(col))))
    tabs <- lapply(Xo, function(z) table(z, useNA = "no"))

    data.frame(
      item = names(tabs),
      n_cat_observed = vapply(tabs, length, integer(1)),
      min_count = vapply(tabs, function(tt) min(as.integer(tt)), integer(1)),
      max_count = vapply(tabs, function(tt) max(as.integer(tt)), integer(1)),
      stringsAsFactors = FALSE
    )
  }

  .format_sparse_items <- function(Xdf, min_count_point = 2, max_items = 6) {
    Xo <- as.data.frame(lapply(Xdf, function(col) droplevels(ordered(col))))
    tabs <- lapply(Xo, function(z) table(z, useNA = "no"))

    sparse <- lapply(names(tabs), function(nm) {
      tt <- tabs[[nm]]
      bad_levels <- names(tt)[as.integer(tt) < min_count_point]
      if (length(bad_levels) == 0) {
        return(NULL)
      }

      counts <- as.integer(tt[bad_levels])
      ord <- order(counts)
      bad_levels <- bad_levels[ord]
      counts <- counts[ord]
      take <- seq_len(min(2, length(bad_levels)))

      paste0(nm, " (", paste0(bad_levels[take], "=", counts[take], collapse = ", "), ")")
    })

    sparse <- Filter(Negate(is.null), sparse)
    if (length(sparse) == 0) {
      return(NULL)
    }

    if (length(sparse) > max_items) sparse <- c(sparse[1:max_items], "...")
    paste(sparse, collapse = "; ")
  }

  get_R_polychoric <- function(Xdf, min_count_point = 2, verbose = TRUE) {
    Xo <- as.data.frame(lapply(Xdf, function(col) droplevels(ordered(col))))
    diag_ord <- .ordinal_diagnostics_df(Xo)

    if (any(diag_ord$n_cat_observed < 2)) {
      bad <- diag_ord$item[diag_ord$n_cat_observed < 2]
      if (verbose) {
        warning(
          "Ordinal reliability skipped: item(s) with <2 observed categories: ",
          paste(bad, collapse = ", "),
          call. = FALSE
        )
      }
      return(NULL)
    }

    if (any(diag_ord$min_count < min_count_point)) {
      details <- .format_sparse_items(Xo, min_count_point = min_count_point)
      if (verbose) {
        warning(
          "Ordinal reliability skipped: sparse categories detected (min_count < ",
          min_count_point, "). ",
          if (!is.null(details)) paste0("Examples: ", details, ". ") else "",
          "Consider increasing n, collapsing categories, or using Pearson-based reliability.",
          call. = FALSE
        )
      }
      return(NULL)
    }

    if (!requireNamespace("psych", quietly = TRUE) &&
      !requireNamespace("polycor", quietly = TRUE)) {
      if (verbose) {
        warning(
          "Ordinal reliability skipped: need optional package 'psych' (preferred) or 'polycor' for polychoric correlations.",
          call. = FALSE
        )
      }
      return(NULL)
    }

    if (requireNamespace("psych", quietly = TRUE)) {
      out <- tryCatch(
        suppressMessages(suppressWarnings(psych::polychoric(Xo, global = FALSE))),
        error = function(e) e
      )

      if (!inherits(out, "error")) {
        return(out$rho)
      }

      if (verbose) {
        warning(
          "Ordinal reliability skipped: psych::polychoric() failed (",
          out$message,
          "). This is usually caused by sparse/extreme response distributions.",
          call. = FALSE
        )
      }
      return(NULL)
    }

    if (requireNamespace("polycor", quietly = TRUE)) {
      out2 <- tryCatch(
        suppressMessages(suppressWarnings(polycor::hetcor(Xo, ML = TRUE))),
        error = function(e) e
      )
      if (!inherits(out2, "error")) {
        return(out2$correlations)
      }

      if (verbose) {
        warning(
          "Ordinal reliability skipped: polycor::hetcor() failed (",
          out2$message,
          ").",
          call. = FALSE
        )
      }
      return(NULL)
    }

    NULL
  }

  alpha_from_R <- function(Rmat) {
    k <- ncol(Rmat)
    (k / (k - 1)) * (1 - (sum(diag(Rmat)) / sum(Rmat)))
  }

  omega_from_R <- function(Rmat) {
    eig <- eigen(Rmat, symmetric = TRUE)
    loadings <- sqrt(max(eig$values[1], 0)) * eig$vectors[, 1]
    if (sum(loadings) < 0) loadings <- -loadings
    uni <- 1 - loadings^2
    sum(loadings)^2 / (sum(loadings)^2 + sum(uni))
  }

  # ------------------ Pearson estimates ------------------

  R <- get_R_pearson(X)
  alpha_est <- alpha_from_R(R)
  omega_est <- omega_from_R(R)

  lambda6_est <- NA_real_
  if (do_lambda6) {
    if (!requireNamespace("psych", quietly = TRUE)) {
      if (verbose) warning("include='lambda6' requires the suggested package 'psych'.", call. = FALSE)
    } else {
      suppressWarnings({
        lambda6_est <- psych::alpha(X)$total[["G6(smc)"]]
      })
    }
  }


  # ------------------ Ordinal estimates + diagnostics ------------------

  diag_ord <- NULL
  ordinal_alpha_est <- NA_real_
  ordinal_omega_est <- NA_real_

  ordinal_ci_ok <- FALSE

  if (do_polychor) {
    diag_ord <- .ordinal_diagnostics_df(X)
    ordinal_ci_ok <- all(diag_ord$min_count >= min_count)

    R_poly <- get_R_polychoric(X, min_count_point = min_count, verbose = verbose)
    if (!is.null(R_poly)) {
      ordinal_alpha_est <- alpha_from_R(R_poly)
      ordinal_omega_est <- omega_from_R(R_poly)
    }
  }

  # ------------------ Bootstrap CI init ------------------

  ci_alpha <- ci_omega <- ci_lambda6 <- c(NA_real_, NA_real_)
  ci_ord_alpha <- ci_ord_omega <- c(NA_real_, NA_real_)

  ord_fail <- 0L
  ord_attempts <- 0L
  ord_success <- NA_integer_

  # ------------------ CI bootstrap ------

  if (isTRUE(ci)) {
    probs <- c((1 - ci_level) / 2, 1 - (1 - ci_level) / 2)

    # Preallocate bootstrap matrix
    boot_mat <- matrix(NA_real_, nrow = 5, ncol = n_boot)
    rownames(boot_mat) <- c(
      "alpha", "omega", "lambda6",
      "ordinal_alpha", "ordinal_omega"
    )

    show_pb <- isTRUE(verbose) && interactive()

    if (show_pb) {
      pb <- utils::txtProgressBar(min = 0, max = n_boot, style = 3)
      on.exit(try(close(pb), silent = TRUE), add = TRUE)
    }

    for (b in seq_len(n_boot)) {
      idx <- sample.int(n, replace = TRUE)
      Xb <- X[idx, , drop = FALSE]

      # Pearson
      Rb <- get_R_pearson(Xb)
      a <- alpha_from_R(Rb)
      o <- omega_from_R(Rb)

      # lambda6
      l6 <- NA_real_
      if (!is.na(lambda6_est) && do_lambda6 && requireNamespace("psych", quietly = TRUE)) {
        l6 <- psych::alpha(Xb)$total[["G6(smc)"]]
      }

      # Ordinal
      oa <- oo <- NA_real_

      if (do_polychor && isTRUE(ci) && isTRUE(ordinal_ci_ok)) {
        ord_attempts <- ord_attempts + 1L
        poly_try <- tryCatch(
          {
            Rpb <- get_R_polychoric(
              Xb,
              min_count_point = min_count,
              verbose = FALSE
            )
            if (is.null(Rpb)) stop("polychoric unavailable")
            c(
              oa = alpha_from_R(Rpb),
              oo = omega_from_R(Rpb)
            )
          },
          error = function(e) {
            ord_fail <- ord_fail + 1L
            c(oa = NA_real_, oo = NA_real_)
          }
        )

        oa <- unname(as.numeric(poly_try["oa"]))
        oo <- unname(as.numeric(poly_try["oo"]))
      }

      boot_mat[, b] <- c(a, o, l6, oa, oo)

      if (show_pb && (b %% 5 == 0 || b == n_boot)) {
        utils::setTxtProgressBar(pb, b)
      }
    }


    # Success counts
    ord_success_alpha <- sum(!is.na(boot_mat["ordinal_alpha", ]))
    ord_success_omega <- sum(!is.na(boot_mat["ordinal_omega", ]))
    ord_success <- min(ord_success_alpha, ord_success_omega)
    ord_ci_ok <- (do_polychor && isTRUE(ordinal_ci_ok) && isTRUE(ci) && is.finite(ord_success) && ord_success > 0L)


    # Pearson CIs
    ci_alpha <- stats::quantile(boot_mat["alpha", ], probs = probs, na.rm = TRUE)
    ci_omega <- stats::quantile(boot_mat["omega", ], probs = probs, na.rm = TRUE)

    if (!all(is.na(boot_mat["lambda6", ]))) {
      ci_lambda6 <- stats::quantile(
        boot_mat["lambda6", ],
        probs = probs,
        na.rm = TRUE
      )
    }

    # Ordinal CIs (only if feasible)
    if (ord_ci_ok) {
      ci_ord_alpha <- stats::quantile(
        boot_mat["ordinal_alpha", ],
        probs = probs,
        na.rm = TRUE
      )
      ci_ord_omega <- stats::quantile(
        boot_mat["ordinal_omega", ],
        probs = probs,
        na.rm = TRUE
      )
    }
  }


  # ------------------ Output table + notes ------------------

  out <- tibble::tibble(
    coef_name = c("alpha", "omega_total"),
    estimate = c(alpha_est, omega_est),
    ci_lower = c(ci_alpha[1], ci_omega[1]),
    ci_upper = c(ci_alpha[2], ci_omega[2]),
    n_items = k,
    n_obs = n,
    notes = c(
      "Pearson correlations",
      "1-factor eigen omega"
    )
  )

  if (do_lambda6 && !is.na(lambda6_est)) {
    out <- dplyr::bind_rows(
      out,
      tibble::tibble(
        coef_name = "lambda6",
        estimate  = lambda6_est,
        ci_lower  = ci_lambda6[1],
        ci_upper  = ci_lambda6[2],
        n_items   = k,
        n_obs     = n,
        notes     = "psych::alpha()"
      )
    )
  }


  if (do_polychor) {
    note_ord <- if (is.na(ordinal_alpha_est)) {
      paste0("Ordinal skipped (see diagnostics)")
    } else {
      "Polychoric correlations"
    }

    note_ci <- if (is.na(ordinal_alpha_est)) {
      if (isTRUE(ci)) "Ordinal CIs not computed (ordinal estimate unavailable)" else "Ordinal CIs not requested"
    } else if (isTRUE(ci)) {
      if (!isTRUE(ordinal_ci_ok)) {
        paste0("Ordinal CIs skipped: sparse categories (min_count < ", min_count, ")")
      } else if (ord_attempts > 0L && ord_fail > 0L) {
        paste0("CI bootstrap failures: ", ord_fail, "/", ord_attempts, " draws")
      } else {
        "Ordinal CIs via bootstrap"
      }
    } else {
      "Ordinal CIs not requested"
    }

    out <- dplyr::bind_rows(
      out,
      tibble::tibble(
        coef_name = c("ordinal_alpha", "ordinal_omega_total"),
        estimate  = c(ordinal_alpha_est, ordinal_omega_est),
        ci_lower  = c(ci_ord_alpha[1], ci_ord_omega[1]),
        ci_upper  = c(ci_ord_alpha[2], ci_ord_omega[2]),
        n_items   = k,
        n_obs     = n,
        notes     = c(note_ord, paste(note_ord, "|", note_ci))
      )
    )
  }

  out$estimate <- round(out$estimate, digits)
  if ("ci_lower" %in% names(out)) out$ci_lower <- round(out$ci_lower, digits)
  if ("ci_upper" %in% names(out)) out$ci_upper <- round(out$ci_upper, digits)

  if (!isTRUE(ci)) {
    out <- dplyr::select(out, -dplyr::any_of(c("ci_lower", "ci_upper")))
  }

  class(out) <- c("likert_reliability", class(out))
  attr(out, "include") <- include
  attr(out, "ci") <- ci
  attr(out, "ci_level") <- ci_level
  attr(out, "n_boot") <- n_boot
  attr(out, "min_count") <- min_count

  if (do_polychor) {
    attr(out, "ordinal_diagnostics") <- diag_ord
    attr(out, "ordinal_ci_ok") <- ordinal_ci_ok
    attr(out, "ordinal_boot_failures") <- ord_fail
    attr(out, "ordinal_boot_attempts") <- ord_attempts
  }

  if (verbose && do_polychor && isTRUE(ci) && !isTRUE(ordinal_ci_ok)) {
    warning(
      "Ordinal CIs were skipped due to sparse categories (min_count < ", min_count, "). ",
      "Use ordinal_diagnostics() on the returned object to inspect the cause.",
      call. = FALSE
    )
  }

  out
}
#'
#' Print method for reliability objects
#'
#' @keywords internal
#' @param x An object returned by [reliability()].
#' @param ... Unused.
#' @export
print.likert_reliability <- function(x, ...) {
  print(as.data.frame(x), row.names = FALSE)

  inc <- attr(x, "include")
  if (!is.null(inc) && "polychoric" %in% inc) {
    diag_ord <- attr(x, "ordinal_diagnostics")
    if (!is.null(diag_ord)) {
      minc <- attr(x, "min_count")
      if (is.null(minc) || !is.numeric(minc) || length(minc) != 1) minc <- 2
      sparse <- diag_ord[diag_ord$min_count < minc, , drop = FALSE]

      if (nrow(sparse) > 0) {
        cat("\nOrdinal diagnostics (sparse categories detected):\n")
        print(sparse, row.names = FALSE)
        cat("\n")
      }
    }
  }

  invisible(x)
}
#'
#' Extract ordinal diagnostics from a reliability() result
#'
#' @param x An object returned by [reliability()].
#' @return A data.frame describing observed response categories and sparsity checks,
#'   or NULL if no diagnostics are available.
#' @export
ordinal_diagnostics <- function(x) {
  if (!inherits(x, "likert_reliability")) {
    stop("ordinal_diagnostics() expects an object returned by reliability().", call. = FALSE)
  }

  inc <- attr(x, "include")
  diag <- attr(x, "ordinal_diagnostics")

  # If user didn't request polychoric, just return NULL quietly
  if (is.null(inc) || !"polychoric" %in% inc) {
    return(NULL)
  }

  if (is.null(diag)) {
    warning("No ordinal diagnostics available in this object.", call. = FALSE)
    return(NULL)
  }

  diag
}
#'
#'
