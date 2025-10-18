#' Synthesise a dataset from paired-sample t-test summary statistics
#'
#' @name makePaired
#'
#' @description The function `makePaired()` generates a dataset from
#' paired-sample *t*-test summary statistics.
#'
#' `makePaired()` generates correlated values so the data replicate
#' rating scales taken, for example, in a before and after experimental design.
#'
#' The function is effectively a wrapper function for
#' `lfast()` and `lcor()` with the addition of a
#' t-statistic from which the between-column correlation is inferred.
#'
#' Paired *t*-tests apply to observations that are associated with each other.
#' For example: the same people before and after a treatment;
#' the same people rating two different objects; ratings by husband & wife;
#' _etc._
#'
#' The paired-samples *t*-test is defined as:
#'
#' \deqn{ t = \frac{\mathrm{mean}(D)}{\mathrm{sd}(D) / \sqrt{n}} }
#'
#' where:
#'
#' - \eqn{D} = differences in values
#' - \eqn{\mathrm{mean}(D)} = mean of the differences
#' - \eqn{\mathrm{sd}(D)} = standard deviation of the differences, where
#'
#' \deqn{ \mathrm{sd}(D)^2 = \mathrm{sd}(X_{\text{before}})^2 +
#'                           \mathrm{sd}(X_{\text{after}})^2 -
#'                           2\,\mathrm{cov}(X_{\text{before}},
#'                           X_{\text{after}}) }
#'
#' A paired-sample *t*-test thus requires an estimate of the covariance between
#' the two sets of observations.
#' `makePaired()` rearranges these formulae so that the covariance is
#' inferred from the t-statistic.
#'
#'
#' @param n (positive, integer) sample size
#' @param means (real) 1:2 vector of target means for two before/after measures
#' @param sds (real) 1:2 vector of target standard deviations
#' @param t_value (real) desired paired *t*-statistic
#' @param lowerbound (integer) lower bound (e.g. '1' for a 1-5 rating scale)
#' @param upperbound (integer) upper bound (e.g. '5' for a 1-5 rating scale)
#' @param items (positive, integer) number of items in the rating scale.
#' Default = 1
#' @param precision (positive, real) relaxes the level of accuracy required.
#' Default = 0
#'
#' @return a dataframe approximating user-specified conditions.
#'
#' @importFrom stats rbeta
#' @importFrom Rcpp sourceCpp
#'
#' @export makePaired
#'
#' @note
#'
#' Larger sample sizes usually result in higher t-statistics,
#' and correspondingly small p-values.
#'
#' Small sample sizes with relatively large standard deviations and
#' relatively high t-statistics can result in impossible correlation values.
#'
#' Similarly, large sample sizes with low *t*-statistics can result in
#' impossible correlations. That is, a correlation outside of the -1:+1 range.
#'
#' If this happens, the function will fail with an _ERROR_ message.
#' The user should review the input parameters and insert more realistic values.
#'
#' @examples
#'
#' n <- 20
#' pair_m <- c(2.5, 3.0)
#' pair_s <- c(1.0, 1.5)
#' lower <- 1
#' upper <- 5
#' k <- 6
#' t <- -2.5
#'
#' pairedDat <- makePaired(
#'   n = n, means = pair_m, sds = pair_s,
#'   t_value = t,
#'   lowerbound = lower, upperbound = upper, items = k
#' )
#'
#' str(pairedDat)
#' cor(pairedDat) |> round(2)
#'
#' t.test(pairedDat$X1, pairedDat$X2, paired = TRUE)
#'
makePaired <- function(n, means, sds, t_value,
                       lowerbound, upperbound,
                       items = 1, precision = 0) {
  ## means is a [1:2] vector with before:after mean values
  ## sds is a [1:2] vector with before:after standard deviation values

  mean_before <- means[1]
  mean_after <- means[2]
  sd_before <- sds[1]
  sd_after <- sds[2]


  ### calculate paired correlation from paired t-test information

  ## The logic:
  ##
  ## The t-statistic is directly related to sd(D):
  ## We know t = mean(D) / (sd(D) / sqrt(n))
  ## We have the t-statistic, the sample size (n), and the means for both
  ## before (mean(X_before)) and after (mean(X_after)), and thus, the mean(D).
  ##
  ## Therefore, we can solve for sd(D):
  ##
  ## sd(D) = mean(D) / (t / sqrt(n)) = mean(D) * sqrt(n) / t
  ##
  ## Now we use the sd(D) relationship:
  ##
  ## sd(D)^2 = sd(X_before)^2 + sd(X_after)^2 - 2 * cov(X_before, X_after)
  ##
  ## Solve for Covariance:
  ## Since we now have sd(D), sd(X_before), and sd(X_after),
  ## we can rearrange to find the cov(X_before, X_after):
  ##
  ## cov(X_before, X_after) = (sd(X_before)^2 + sd(X_after)^2 - sd(D)^2) / 2
  ##
  ## Finally, Calculate the Correlation:
  ## calculate the correlation from the covariance and standard deviations to :
  ##
  ## r = cov(X_before, X_after) / (sd(X_before) * sd(X_after))
  ##
  ## NOTES
  ## Small sample sizes with relatively large standard deviations and
  ## relatively high t-statistics can result in impossible correlation values.
  ## Similarly, large sample sizes with low t-statistics
  ## can result in impossible correlations.

  ## Begin paired covariance/correlation function
  calculate_paired_correlation <- function(n, mean_before, mean_after,
                                           sd_before, sd_after, t_statistic) {
    ## Error handling
    if (n <= 3) {
      stop("Sample size must be greater than 3 for a paired t-test.")
    }

    ## Calculate the mean of the differences
    mean_diff <- mean_before - mean_after

    ## Calculate the standard deviation of the differences
    sd_diff <- mean_diff / (t_statistic / sqrt(n))

    ## Check if sd_diff is complex
    if (is.complex(sd_diff)) {
      stop("Error calculating standard deviation of differences.
           \nCheck your t-statistic, means, and sample size.
           \nsd_diff is complex, likely indicating error in input variables")
    }

    ## Calculate the covariance
    covariance <- (sd_before^2 + sd_after^2 - sd_diff^2) / 2

    ## Calculate the correlation
    correlation <- covariance / (sd_before * sd_after)

    ## Validate correlation
    if (correlation > 1 || correlation < -1) {
      stop(paste0("Inputs are inconsistent. \nSmaller (larger) sample size
                  usually means lower (higher) t-value."))
    }

    return(correlation)
  } ## END paired covariance/correlation function


  t_c <- calculate_paired_correlation(
    n = n,
    mean_before = mean_before, mean_after = mean_after,
    sd_before = sd_before, sd_after = sd_after,
    t_statistic = t_value
  )

  ## define target correlation matrix for paired comparisons
  t_cor <- matrix(
    c(
      1, t_c,
      t_c, 1
    ),
    ncol = 2, nrow = 2
  )

  ## define initial data
  message(paste0("Initial data vectors"))
  startDat <- data.frame(
    x1 = lfast(
      n, mean_before, sd_before,
      lowerbound, upperbound,
      items, precision
    ),
    x2 = lfast(
      n, mean_after, sd_after,
      lowerbound, upperbound,
      items, precision
    )
  )

  message("Arranging values to conform with desired t-value")
  correlatedDat <- lcor(data = startDat, target = t_cor)
  message("Complete!")

  return(correlatedDat)
}
