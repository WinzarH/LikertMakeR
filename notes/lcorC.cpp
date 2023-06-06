#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericMatrix lcorC(NumericMatrix data, NumericMatrix target) {
  double multiplier = 10000.0;
  NumericMatrix current_dat = clone(data);
  NumericMatrix current_cor = cor_cpp(current_dat);
  NumericMatrix target_cor = clone(target);
  double diff_score = sum(abs(target_cor - current_cor)) * multiplier;
  int n = current_dat.nrow();
  int nc = current_dat.ncol();
  
  // generate a complete list of value-pairs as switch candidates
  IntegerMatrix ye = expand_grid_cpp(seq(1, n), seq(1, n));
  // no need to switch with yourself so we can remove these pairs
  ye = ye.rowSums() != 2;
  int ny = ye.nrow();
  
  // begin column selection loop
  // for each column in the data set ...
  for (int r = 0; r < ny; ++r) {
    // Other columns are relative to first column
    //
    // begin row values swap loop
    for (int colID = 1; colID < nc; ++colID) {
      // locate data points to switch
      int i = ye(r, 0) - 1;
      int j = ye(r, 1) - 1;
      
      // check that values in two locations are different
      if (current_dat(i, colID) == current_dat(j, colID)) {
        break;
      }
      
      // record values in case they need to be put back
      double ii = current_dat(i, colID);
      double jj = current_dat(j, colID);
      
      // swap the values in selected locations
      current_dat(i, colID) = jj;
      current_dat(j, colID) = ii;
      
      // if switched values reduce the difference between correlation
      // matrices then keep the switch, otherwise put them back
      double new_diff_score = sum(abs(target_cor - cor_cpp(current_dat))) * multiplier;
      if (new_diff_score < diff_score) {
        // update data-frame and target statistic
        current_cor = cor_cpp(current_dat);
        diff_score = new_diff_score;
      } else {
        // swap values back
        current_dat(i, colID) = ii;
        current_dat(j, colID) = jj;
      }
    } // end row values swap loop
  } // end column selection loop
  
  return current_dat;
} // end lcor function

// [[Rcpp::export]]
NumericMatrix cor_cpp(NumericMatrix X) {
  int n = X.nrow();
  int p = X.ncol();
  NumericMatrix cor_mat(p, p);
  for (int i = 0; i < p; i++) {
    for (int j = i; j < p; j++) {
      double sum_xy = 0.0;
      double sum_x = 0.0;
      double sum_y = 0.0;
      double sum_x2 = 0.0;
      double sum_y2 = 0.0;
      for (int k = 0; k < n; k++) {
        double x = X(k, i);
        double y = X(k, j);
        sum_xy += x * y;
        sum_x += x;
        sum_y += y;
        sum_x2 += x * x;
        sum_y2 += y * y;
      }
      double numerator = n * sum_xy - sum_x * sum_y
      
