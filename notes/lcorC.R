library(LikertMakeR)
library(Rcpp)

sourceCpp("lcorC.cpp")

n <- 64

x1 <- lfast(n, 2.5, 0.75, 1, 5, 5)
x2 <- lfast(n, 3.0, 1.50, 1, 5, 5)
x3 <- lfast(n, 3.5, 1.00, 1, 5, 5)

mydat3 <- cbind(x1, x2, x3) |> data.frame()

tgt3 <- matrix(
  c(
    1.00, 0.80, 0.75,
    0.80, 1.00, 0.90,
    0.75, 0.90, 1.00
  ),
  nrow = 3
)

lcor(mydat3, tgt3)

bench::mark(
  mean(x),
  meanC(x)
)

meanC(x)
mean(x)

