#include <Rcpp.h>
#include <iostream>
#include <Eigen/Dense>

using namespace Rcpp;
using namespace std;
using namespace Eigen;

// [[Rcpp::export]]
MatrixXd lcor(MatrixXd data, MatrixXd target) {
  
  // Multiply the difference between the target and current correlation matrices by a multiplier
  MatrixXd diff_score = (target - data) * multiplier;
  
  // Get the number of rows and columns in the data
  int n = data.rows();
  int nc = data.cols();
  
  // Generate a complete list of value-pairs as switch candidates
  MatrixXd ye = MatrixXd::Zero(n, n);
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      ye(i, j) = (i * n) + j;
    }
  }
  
  // Remove pairs where the two values are the same
  ye = ye.array() != ye.rowwise().sum().array();
  
  // Begin column selection loop
  // For each column in the data set ...
  for (int r = 0; r < nc; r++) {
    
    // Other columns are relative to first column
    //
### Begin row values swap loop
    for (int colID = r + 1; colID < nc; colID++) {
      
      // Locate data points to switch
      int i = ye(r, 0);
      int j = ye(r, 1);
      
      // Check that values in two locations are different
      if (data(i, colID) == data(j, colID)) {
        continue;
      }
      
      // Record values in case they need to be put back
      double ii = data(i, colID);
      double jj = data(j, colID);
      
      // Swap the values in selected locations
      data(i, colID) = jj;
      data(j, colID) = ii;
      
      // If switched values reduce the difference between correlation
      // matrices then keep the switch, otherwise put them back
      MatrixXd new_diff_score = (target - data) * multiplier;
      if (new_diff_score < diff_score) {
        // Update data-frame and target statistic
        diff_score = new_diff_score;
      } else {
        // Swap values back
        data(i, colID) = ii;
        data(j, colID) = jj;
      }
    }
  }
  
  return data;
}
