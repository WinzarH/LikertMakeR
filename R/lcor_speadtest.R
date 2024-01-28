## runtime tests for lcor() and lcor_C()
library(LikertMakeR)
library(microbenchmark)

 n <- 32
 lowerbound <- 1
 upperbound <- 5
 items <- 5

 mydat4 <- data.frame(
   x1 = lfast(n, 2.5, 0.75, lowerbound, upperbound, items),
   x2 = lfast(n, 3.0, 1.00, lowerbound, upperbound, items),
   x3 = lfast(n, 3.0, 1.50, lowerbound, upperbound, items),
   x4 = lfast(n, 3.5, 1.00, lowerbound, upperbound, items)
 )

 ### check correlation
 # cor(mydat3) |> round(3)

 ## describe a target correlation matrix
 tgt4 <- matrix(
   c(
     1.00, 0.90, 0.80, 0.70,
     0.90, 1.00, 0.60, 0.50,
     0.80, 0.60, 1.00, 0.40,
     0.70, 0.50, 0.40, 1.00
   ),
   nrow = 4, ncol = 4
 )

 ## apply lcor function
 new4 <- LikertMakeR::lcor_C(mydat4, tgt4)
