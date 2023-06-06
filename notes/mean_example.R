library(Rcpp)

sourceCpp("mean_example.cpp")

x <- runif(1e5)
bench::mark(
  mean(x),
  meanC(x)
)

meanC(x)
mean(x)
