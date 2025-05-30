% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makePaired.R
\name{makePaired}
\alias{makePaired}
\title{Synthesise a dataset from paired-sample t-test summary statistics}
\usage{
makePaired(
  n,
  means,
  sds,
  t_value,
  lowerbound,
  upperbound,
  items = 1,
  precision = 0
)
}
\arguments{
\item{n}{(positive, integer) sample size}

\item{means}{(real) 1:2 vector of target means for two before/after measures}

\item{sds}{(real) 1:2 vector of target standard deviations}

\item{t_value}{(real) desired paired t-statistic}

\item{lowerbound}{(integer) lower bound (e.g. '1' for a 1-5 rating scale)}

\item{upperbound}{(integer) upper bound (e.g. '5' for a 1-5 rating scale)}

\item{items}{(positive, integer) number of items in the rating scale.
Default = 1}

\item{precision}{(positive, real) relaxes the level of accuracy required.
Default = 0}
}
\value{
a dataframe approximating user-specified conditions.
}
\description{
\code{makePaired()} generates a dataset from
paired-sample t-test summary statistics.

\code{makePaired()} generates correlated values so the data replicate
rating scales taken, for example, in a before and after experimental design.

The function is effectively a wrapper function for
\code{lfast()} and \code{lcor()} with the addition of a
t-statistic from which the between-column correlation is inferred.

Paired t-tests apply to observations that are associated with each other.
For example: the same people before and after a treatment;
the same people rating two different objects; ratings by husband & wife;
\emph{etc.}

The t-test for paired data is given by:
\itemize{
\item t = mean(D) / (sd(D) / sqrt(n))
}

where:
\itemize{
\item D = differences in values,
\item mean(D) = mean of the differences,
\item sd(D) = standard deviation of the differences, where
\itemize{
\item sd(D)^2 = sd(X_before)^2 + sd(X_after)^2 - 2 * cov(X_before, X_after)
}
}

A paired-sample t-test thus requires an estimate of the covariance between
the two sets of observations.
\code{makePaired()} rearranges these formulae so that the covariance is
inferred from the t-statistic.
}
\note{
Larger sample sizes usually result in higher t-statistics,
and correspondingly small p-values.

Small sample sizes with relatively large standard deviations and
relatively high t-statistics can result in impossible correlation values.

Similarly, large sample sizes with low t-statistics can result in
impossible correlations. That is, a correlation outside of the -1:+1 range.

If this happens, the function will fail with an \emph{ERROR} message.
The user should review the input parameters and insert more realistic values.
}
\examples{

n <- 20
pair_m <- c(2.5, 3.0)
pair_s <- c(1.0, 1.5)
lower <- 1
upper <- 5
k <- 6
t <- -2.5

pairedDat <- makePaired(
  n = n, means = pair_m, sds = pair_s,
  t_value = t,
  lowerbound = lower, upperbound = upper, items = k
)

str(pairedDat)
cor(pairedDat) |> round(2)

t.test(pairedDat$X1, pairedDat$X2, paired = TRUE)

}
