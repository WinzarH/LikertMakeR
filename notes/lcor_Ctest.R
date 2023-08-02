
library(Rcpp)
sourceCpp("lcor_Cpp.cpp")

mydat3 <- data.frame(x1 = rnorm(32), x2 = rnorm(32), x3 = rnorm(32))

target3 <- matrix(c(1.00, 0.50, 0.75, 0.50, 1.00, 0.25, 0.75, 0.25, 1.00), nrow = 3)

new3 <- lcor(mydat3, target3)

cor(new3) |> round(3)

