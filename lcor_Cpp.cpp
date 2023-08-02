#include <Rcpp.h>
#include <iostream>
//#include <eigen3/Eigen/Dense>

using namespace Rcpp;
using namespace std;
//using namespace Eigen;
//#include <Rcpp.h>






// [[Rcpp::export]]
DataFrame lcor(DataFrame data, NumericMatrix target) {
  // Initialize variables
  int multiplier = 10000;
  DataFrame current_dat = data;
  NumericMatrix current_cor(data.ncol(), data.ncol());
  NumericMatrix target_cor = target;
  double diff_score = sum((abs(target_cor - current_cor)) * multiplier);
  int n = nrow(current_dat);
  int nc = ncol(current_dat);

  // Generate a complete list of value-pairs as switch candidates
  NumericMatrix ye = expand.grid(seq_len(n), seq_len(n));
  ye = subset(ye, ye[, 1] != ye[, 2]);
  int ny = nrow(ye);

  // Begin column selection loop
  // For each column in the data set ...
  for (int r = 0; r < ny; r++) {
    // Other columns are relative to first column
    //
    // Begin row values swap loop
    for (int colID = 1; colID < nc; colID++) {
      // Locate data points to switch
      int i = ye[r, 0];
      int j = ye[r, 1];

      // Check that values in two locations are different
      if (current_dat[i, colID] == current_dat[j, colID]) {
        continue;
      }

      // Record values in case they need to be put back
      double ii = current_dat[i, colID];
      double jj = current_dat[j, colID];

      // Swap the values in selected locations
      current_dat[i, colID] = jj;
      current_dat[j, colID] = ii;

      // If switched values reduce the difference between correlation
      // matrices then keep the switch, otherwise put them back
      double new_diff_score = sum((abs(target_cor - correlation_matrix(current_dat))) * multiplier);
      if (new_diff_score < diff_score) {
        // Update data-frame and target statistic
        current_cor = correlation_matrix(current_dat);
        diff_score = new_diff_score;
      } else {
        // Swap values back
        current_dat[i, colID] = ii;
        current_dat[j, colID] = jj;
      }
    } // end row values swap loop
  } // end column selection loop

  return(current_dat);
}

// This function finds the correlation matrix of a dataframe with k columns.
NumericMatrix correlation_matrix(DataFrame data) {
  // Check that the dataframe has at least two columns.
  if (data.ncol() < 2) {
    throw std::invalid_argument("The dataframe must have at least two columns.");
  }

  // Calculate the correlation matrix.
  NumericMatrix correlation_matrix(data.ncol(), data.ncol());
  for (int i = 0; i < data.ncol(); i++) {
    for (int j = 0; j < data.ncol(); j++) {
      correlation_matrix(i, j) = cor(data[, i], data[, j]);
    }
  }

  return(correlation_matrix);
}

#include <iostream>
#include <vector>
#include <algorithm>
#include <numeric>

using namespace std;

// Calculates the difference between two correlation matrices.
vector<vector<double>> difference_of_matrices(const vector<vector<double>>& matrix1, const vector<vector<double>>& matrix2) {
  // Get the number of rows and columns of the matrices.
  int n_rows = matrix1.size();
  int n_cols = matrix1[0].size();

  // Create a matrix to store the difference of the correlation coefficients.
  vector<vector<double>> difference_matrix(n_cols, vector<double>(n_cols));

  // Loop through the rows and columns of the matrices.
  for (int i = 0; i < n_rows; i++) {
    for (int j = 0; j < n_cols; j++) {

      // Calculate the difference of the correlation coefficients between the i-th and j-th columns of the matrices.
      double difference_coefficient = matrix1[i][j] - matrix2[i][j];

      // Store the difference coefficient in the i-th row and j-th column of the difference matrix.
      difference_matrix[i][j] = difference_coefficient;
    }
  }

  // Return the difference matrix.
  // return difference_matrix;
  int n_rows = difference_matrix.size();
  int n_cols = difference_matrix[0].size();

  // Initialize the sum to 0.
  double sum = 0.0;
}

// Calculates the sum of all elements in a matrix.
double sum_of_elements_in_matrix(const vector<vector<double>>& matrix) {
  // Get the number of rows and columns of the matrix.
  int n_rows = matrix.size();
  int n_cols = matrix[0].size();

  // Initialize the sum to 0.
  double sum = 0.0;

  // Loop through the rows and columns of the matrix.
  for (int i = 0; i < n_rows; i++) {
    for (int j = 0; j < n_cols; j++) {

      // Add the element at the i-th row and j-th column to the sum.
      sum += matrix[i][j];
    }
  }

  // Return the sum.
  double diff_score = sum * multiplier;
  return diff_score;
}

