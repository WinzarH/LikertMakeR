// lcor() code translated to C++

#include <iostream>
#include <cmath>
#include <vector>
#include <numeric>
#include <algorithm>

const int multiplier = 10000; // constant value to multiply with

// lcor function rearranges values in each column
std::vector<std::vector<double>> lcor(const std::vector<std::vector<double>> &data, const std::vector<std::vector<double>> &target) {
  int n = data.size(); // number of rows in data
  int nc = data[0].size(); // number of columns in data

  // Copy the data to a new variable
  std::vector<std::vector<double>> current_dat = data;
  auto current_cor = cor(current_dat); // calculate the correlation matrix for current data
  auto target_cor = target;
  int diff_score = sum(abs(target_cor - current_cor)) * multiplier; // calculate the difference score between target and current correlation matrices

  // Generate a complete list of value-pairs as switch candidates
  std::vector<std::pair<int, int>> ye;
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n; j++) {
      if (i != j) {
        ye.emplace_back(i, j); // add the pair to ye if i and j are not equal
      }
    }
  }

  int ny = ye.size(); // number of value pairs

  // Begin column selection loop
  for (int r = 0; r < ny; r++) {
    // Other columns are relative to first column
    for (int colID = 1; colID < nc; colID++) {
      int i = ye[r].first;
      int j = ye[r].second;

      if (current_dat[i][colID] == current_dat[j][colID]) {
        break; // exit the inner loop if values in two locations are equal
      }

      double ii = current_dat[i][colID];
      double jj = current_dat[j][colID];

      current_dat[i][colID] = jj;
      current_dat[j][colID] = ii;

      // if switched values reduce the difference between correlation matrices
      if (sum(abs(target_cor - cor(current_dat))) * multiplier < diff_score) {
        current_cor = cor(current_dat); // update the current correlation matrix
        diff_score = sum(abs(target_cor - current_cor)) * multiplier; // update the difference score
      } else {
        current_dat[i][colID] = ii;
        current_dat[j][colID] = jj;
      }
    }
  }

  return current_dat;
}


