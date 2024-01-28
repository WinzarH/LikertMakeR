// File: lcor_C.cpp
// Author: Hume Winzar
// Date: January 2024
// Purpose: This file contains the C++ implementation of the 'lcor()' function
//          for rearranging values in each column of a data matrix to match
//          a target correlation matrix.
//          The function is part of the LikertMakeR package.


#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace arma;

// Function to check the integrity of the data matrix and target matrix
bool checkIntegrity(const mat& data, const NumericMatrix& target) {
  // Check if target is a square matrix
  arma::uword n = target.nrow();
  if (n != static_cast<arma::uword>(target.ncol())) {
    Rcpp::Rcout << "Error: 'target' must be square." << std::endl;
    return false;
  }

  // Check if the number of columns in data matches the size of target
  if (data.n_cols != n) {
    Rcpp::Rcout << "Error: Number of columns in 'data' must match dimensions of 'target'." << std::endl;
    return false;
  }

  // Check if target is symmetric, has 1s on diagonal, and values in range [-1, 1]
  for (arma::uword i = 0; i < n; ++i) {
    if (target(i, i) != 1) {
      Rcpp::Rcout << "Error: 'target' must have '1' in the diagonals." << std::endl;
      return false;
    }
    for (arma::uword j = 0; j < n; ++j) {
      if (target(i, j) < -1 || target(i, j) > 1) {
        Rcpp::Rcout << "Error: 'target' values must be within the range of -1 and 1." << std::endl;
        return false;
      }
      if (i != j && target(i, j) != target(j, i)) {
        Rcpp::Rcout << "Error: 'target' must be symmetric." << std::endl;
        return false;
      }
    }
  }

  // Check if target is positive definite
  mat target_mat = as<mat>(target);
  if (!target_mat.is_sympd()) {
    Rcpp::Rcout << "Error: Target must be positive-definite. Requested correlations are not possible." << std::endl;
    return false;
  }

  return true;
}


// Function to compute the correlation matrix
mat computeCorrelation(const mat& data) {
  // Use Armadillo's cor() function for simplicity here
  return cor(data);
}

// Function to compute the Frobenius norm of the difference between two matrices
double frobeniusNorm(const mat& A, const mat& B) {
  mat diff = A - B;
  return sqrt(accu(diff % diff)); // '%': element-wise multiplication
}



// Function to check if all columns in DataFrame are numeric
bool areAllColumnsNumeric(DataFrame df) {
  for (int i = 0; i < df.size(); i++) {
    if (TYPEOF(df[i]) != REALSXP && TYPEOF(df[i]) != INTSXP) {
      return false;
    }
  }
  return true;
}

// Main function to optimize the data to match target correlation matrix
// [[Rcpp::export]]
DataFrame lcor_C(DataFrame data_df, NumericMatrix target) {
  // Check if all columns in DataFrame are numeric
  if (!areAllColumnsNumeric(data_df)) {
    stop("Error: All columns in the data frame must be numeric.");
  }

  // Convert DataFrame to arma::mat
  int nRows = data_df.nrows();
  int nCols = data_df.ncol();
  mat data_mat(nRows, nCols);
  for (int i = 0; i < nCols; i++) {
    data_mat.col(i) = as<vec>(data_df[i]);
  }

  // Check integrity of data and target matrix
  if (!checkIntegrity(data_mat, target)) {
    stop("Integrity check failed.");
  }


  // Calculate initial Frobenius norm
  double initialFrobNorm = frobeniusNorm(computeCorrelation(data_mat), as<mat>(target));

  // Generate swap candidates
  std::vector<std::pair<int, int>> swapCandidates;
  for (int i = 0; i < nRows; ++i) {
    for (int j = 0; j < nRows; ++j) {
      if (i != j) {
        swapCandidates.push_back(std::make_pair(i, j));
      }
    }
  }

  // Iterate over all columns and swap candidates
  for (size_t r = 0; r < swapCandidates.size(); ++r) {
    for (int col = 0; col < nCols; ++col) {
      int i = swapCandidates[r].first;
      int j = swapCandidates[r].second;

      // Perform the swap
      double temp = data_mat(i, col);
      data_mat(i, col) = data_mat(j, col);
      data_mat(j, col) = temp;

      // Calculate new Frobenius norm
      double newFrobNorm = frobeniusNorm(computeCorrelation(data_mat), as<mat>(target));

      // Revert the swap if the new Frobenius norm is not lower
      if (newFrobNorm >= initialFrobNorm) {
        data_mat(j, col) = data_mat(i, col);
        data_mat(i, col) = temp;
      } else {
        // Update the initial Frobenius norm
        initialFrobNorm = newFrobNorm;
      }
    }
  }

  DataFrame optimized_data = wrap(data_mat);
  return optimized_data;
}
