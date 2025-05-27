// File: lcor_C_randomised.cpp
// Author: Hume Winzar
// Date: May 2025
// Purpose: Implements randomized row swaps within each column to approximate a target correlation matrix

#include <RcppArmadillo.h>
#include <algorithm>
#include <random>
// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

bool checkIntegrity(const mat& data, const NumericMatrix& target) {
  arma::uword n = target.nrow();
  if (n != static_cast<arma::uword>(target.ncol()) || data.n_cols != n)
    return false;
  for (arma::uword i = 0; i < n; ++i) {
    if (target(i, i) != 1) return false;
    for (arma::uword j = 0; j < n; ++j) {
      if (target(i, j) < -1 || target(i, j) > 1 || target(i, j) != target(j, i))
        return false;
    }
  }
  mat target_mat = as<mat>(target);
  return target_mat.is_sympd();
}

mat computeCorrelation(const mat& data) {
  return cor(data);
}

double frobeniusNorm(const mat& A, const mat& B) {
  mat diff = A - B;
  return sqrt(accu(diff % diff));
}

bool areAllColumnsNumeric(DataFrame df) {
  for (int i = 0; i < df.size(); i++) {
    if (TYPEOF(df[i]) != REALSXP && TYPEOF(df[i]) != INTSXP) {
      return false;
    }
  }
  return true;
}

// [[Rcpp::export]]
SEXP lcor_C_randomised(DataFrame data_df, NumericMatrix target, int passes = 10) {
  if (!areAllColumnsNumeric(data_df)) {
    stop("All columns must be numeric.");
  }

  int nRows = data_df.nrows();
  int nCols = data_df.ncol();
  mat data_mat(nRows, nCols);
  for (int i = 0; i < nCols; i++) {
    data_mat.col(i) = as<vec>(data_df[i]);
  }

  if (!checkIntegrity(data_mat, target)) {
    stop("Target correlation matrix failed integrity check.");
  }

  mat target_mat = as<mat>(target);
  double initialFrobNorm = frobeniusNorm(computeCorrelation(data_mat), target_mat);

  std::random_device rd;
  std::mt19937 g(rd());

  // Repeat the optimization process for a fixed number of passes
  for (int pass = 0; pass < passes; ++pass) {
    // Loop over each column in the data matrix
    for (int col = 0; col < nCols; ++col) {
      // Create two random permutations of row indices
      std::vector<int> i_indices(nRows);
      std::vector<int> j_indices(nRows);
      std::iota(i_indices.begin(), i_indices.end(), 0);
      std::iota(j_indices.begin(), j_indices.end(), 0);
      std::shuffle(i_indices.begin(), i_indices.end(), g);
      std::shuffle(j_indices.begin(), j_indices.end(), g);

      // Iterate over the randomized row pairs
      for (int k = 0; k < nRows; ++k) {
        int i = i_indices[k];
        int j = j_indices[k];
        if (i == j) continue; // Skip if same row

        // Swap values in the current column between rows i and j
        std::swap(data_mat(i, col), data_mat(j, col));

        // Compute Frobenius norm of updated correlation matrix
        double newFrobNorm = frobeniusNorm(computeCorrelation(data_mat), target_mat);

        // Keep the swap only if Frobenius norm improves
        if (newFrobNorm >= initialFrobNorm) {
          std::swap(data_mat(i, col), data_mat(j, col)); // Revert the swap
        } else {
          initialFrobNorm = newFrobNorm; // Accept the swap
        }
      }
    }
  }

  return wrap(data_mat);
}
