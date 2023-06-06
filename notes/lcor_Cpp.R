## Rearrange columns in a data-frame to fit a predefined correlation matrix
##



library(LikertMakeR)
# Load the Rcpp and RcppEigen packages
library(Rcpp)
library(RcppEigen)

# Define the C++ code as a string
cpp_code <- '
  double lcor_cpp(NumericMatrix data, NumericMatrix target) {
    double multiplier = 10000;
    NumericMatrix current_dat = clone(data);
    Eigen::MatrixXd current_cor = RcppEigen::as<Eigen::MatrixXd>(cor(current_dat));
    NumericMatrix target_cor = clone(target);
    double diff_score = sum((abs(target_cor - current_cor)) * multiplier);
    int n = current_dat.nrow();
    int nc = current_dat.ncol();
    NumericMatrix ye(n*n, 2);
    int k = 0;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i != j) {
          ye(k, 0) = i;
          ye(k, 1) = j;
          k++;
        }
      }
    }
    NumericMatrix ye_sub = ye(Range(0, k-1), Range(0, 1));
    int ny = ye_sub.nrow();
    for (int colID = 1; colID < nc; colID++) {
      for (int r = 0; r < ny; r++) {
        int i = ye_sub(r, 0);
        int j = ye_sub(r, 1);
        if (current_dat(i, colID) != current_dat(j, colID)) {
          NumericMatrix current_dat_copy = clone(current_dat);
          double temp = current_dat_copy(i, colID);
          current_dat_copy(i, colID) = current_dat_copy(j, colID);
          current_dat_copy(j, colID) = temp;
          Eigen::MatrixXd current_cor_copy = RcppEigen::as<Eigen::MatrixXd>(cor(current_dat_copy));
          double diff = sum(abs(target_cor - current_cor_copy)) * multiplier;
          if (diff < diff_score) {
            diff_score = diff;
            current_dat = clone(current_dat_copy);
            current_cor = RcppEigen::as<Eigen::MatrixXd>(cor(current_dat));
          }
        }
      }
    }
    return diff_score;
  }
'

# Create a function in R that calls the C++ function using Rcpp
lcor <- cppFunction(cpp_code, includes = c("#include <RcppEigen.h>"))


n <- 128
x1 <- lfast(n, 3.5, 1.0, 1, 5, 5)
x2 <- lfast(n, 1.5, 0.75, 1, 5, 5)
x3 <- lfast(n, 3.0, 1.5, 1, 5, 5)


mydat3 <- cbind(x1, x2, x3) |> data.frame()
plot(mydat3)
##
cor(mydat3)
##
## describe a target correlation matrix

tgt3 <- matrix(
  c(
    1.00, 0.75, 0.75,
    0.75, 1.00, 0.75,
    0.75, 0.75, 1.00
  ),
  nrow = 3
)

new3 <- lcor(mydat3, tgt3)

cor(new3) |> round(3)
plot(new3)
