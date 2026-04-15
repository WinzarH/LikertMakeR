#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
List score_items_cpp(NumericMatrix dat,
                     double target_alpha,
                     double w_balance,
                     double expected_mean) {

  int n = dat.nrow();
  int k = dat.ncol();

  NumericVector col_sums(k);
  NumericVector col_sumsq(k);
  NumericVector row_sums(n);

  // --- Compute sums ---
  for (int j = 0; j < k; j++) {
    double sum = 0.0;
    double sumsq = 0.0;

    for (int i = 0; i < n; i++) {
      double val = dat(i, j);
      sum += val;
      sumsq += val * val;
    }

    col_sums[j] = sum;
    col_sumsq[j] = sumsq;
  }

  // --- Column means and variances ---
  NumericVector col_vars(k);
  NumericVector col_means(k);

  for (int j = 0; j < k; j++) {
    double mean = col_sums[j] / n;
    col_means[j] = mean;

    double var = (col_sumsq[j] - n * mean * mean) / (n - 1);
    col_vars[j] = var;
  }

  // --- Row sums ---
  for (int i = 0; i < n; i++) {
    double sum = 0.0;
    for (int j = 0; j < k; j++) {
      sum += dat(i, j);
    }
    row_sums[i] = sum;
  }

  // --- Total variance ---
  double mean_rs = 0.0;
  for (int i = 0; i < n; i++) {
    mean_rs += row_sums[i];
  }
  mean_rs /= n;

  double total_var = 0.0;
  for (int i = 0; i < n; i++) {
    double diff = row_sums[i] - mean_rs;
    total_var += diff * diff;
  }
  total_var /= (n - 1);

  double alpha_val;

  if (!R_finite(total_var) || total_var <= 0) {
    alpha_val = 0.0;
  } else {
    double sum_vars = 0.0;
    for (int j = 0; j < k; j++) sum_vars += col_vars[j];

    alpha_val = ((double)k / (k - 1)) * (1.0 - sum_vars / total_var);
  }

  // --- Score ---
  double alpha_err = std::abs(alpha_val - target_alpha);

  double balance_penalty = 0.0;
  for (int j = 0; j < k; j++) {
    double diff = col_means[j] - expected_mean;
    balance_penalty += diff * diff;
  }
  balance_penalty /= k;

  double score = alpha_err * alpha_err +
    w_balance * balance_penalty * (1.0 + alpha_err);

  return List::create(
    Named("score") = score,
    Named("alpha") = alpha_val
  );
}
