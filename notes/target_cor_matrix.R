## define a target correlation matrix with all same correlations

# Set the matrix size
k <- 4

# Set the off-diagonal value
off_diag_value <- 0.7

# Generate the matrix
matrix_data <- diag(1, nrow = k) + off_diag_value * (1 - diag(1, nrow = k))

# Print the resulting matrix
print(matrix_data)
