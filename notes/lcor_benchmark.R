## compare lcor function original with lcor function suggested by
## Google Bard <https://bard.google.com/>



lcor_original <- function(data, target) {
  multiplier <- 10000
  current_dat <- data
  current_cor <- cor(current_dat)
  target_cor <- target
  diff.score <- sum((abs(target_cor - current_cor)) * multiplier)
  n <- nrow(current_dat)
  nc <- ncol(current_dat)

  ## generate a complete list of value-pairs as switch candidates
  ye <- expand.grid(c(1:n), c(1:n))
  ## no need to switch with yourself so we can remove these pairs
  ye <- subset(ye, ye[, 1] != ye[, 2])
  ny <- nrow(ye)

  ## begin column selection loop
  ## for each column in the data set ...
  for (r in 1:ny) {
    ## Other columns are relative to first column
    ##
    ### begin row values swap loop
    for (colID in 2:nc) {
      ## locate data points to switch
      i <- ye[r, 1]
      j <- ye[r, 2]

      ## check that values in two locations are different
      if (current_dat[i, colID] == current_dat[j, colID]) {
        break
      }

      ## record values in case they need to be put back
      ii <- current_dat[i, colID]
      jj <- current_dat[j, colID]

      ## swap the values in selected locations
      current_dat[i, colID] <- jj
      current_dat[j, colID] <- ii

      ## if switched values reduce the difference between correlation
      ## matrices then keep the switch, otherwise put them back
      new.diff.score <- sum((abs(target_cor - cor(current_dat))) * multiplier)
      if (new.diff.score < diff.score) {
        ## update data-frame and target statistic
        current_cor <- cor(current_dat)
        diff.score <- new.diff.score
      } else {
        ## swap values back
        current_dat[i, colID] <- ii
        current_dat[j, colID] <- jj
      }
    } ## end row values swap loop
  } ## end column selection loop

  return(current_dat)
} ## end lcor function




lcor_new <- function(data, target) {
  # Initialize variables
  n <- nrow(data)
  nc <- ncol(data)
  current_cor <- cor(data)
  target_cor <- target
  diff.score <- sum((abs(target_cor - current_cor)) * 10000)

  # Generate a complete list of value-pairs as switch candidates
  ye <- expand.grid(1:n, 1:n)
  ye <- subset(ye, ye[, 1] != ye[, 2])
  ny <- nrow(ye)

  # Begin column selection loop
  for (r in 1:ny) {
    # Other columns are relative to first column
    for (colID in 2:nc) {
      # Locate data points to switch
      i <- ye[r, 1]
      j <- ye[r, 2]

      # Check that values in two locations are different
      if (data[i, colID] == data[j, colID]) {
        next
      }

      # Record values in case they need to be put back
      ii <- data[i, colID]
      jj <- data[j, colID]

      # Swap the values in selected locations
      data[i, colID] <- jj
      data[j, colID] <- ii

      # Calculate the new difference score
      new.diff.score <- sum((abs(target_cor - cor(data))) * 10000)

      # If the new difference score is less than the old, keep the switch
      if (new.diff.score < diff.score) {
        diff.score <- new.diff.score
      } else {
        # Otherwise, swap the values back
        data[i, colID] <- ii
        data[j, colID] <- jj
      }
    }
  }

  # Return the data frame
  return(data)
}



library(microbenchmark)


tgt3 <- matrix(
  c(
    1.00, 0.50, 0.75,
    0.50, 1.00, 0.25,
    0.75, 0.25, 1.00
  ),
  nrow = 3
)

tgt4 <- matrix(
  c(
    1.00, 0.75, 0.75, 0.75,
    0.75, 1.00, 0.75, 0.75,
    0.75, 0.75, 1.00, 0.75,
    0.75, 0.75, 0.75, 1.00
  ),
  nrow = 4
)
mydat4 <- sample(c(1:7), 512, replace = TRUE) |>
  matrix(ncol = 4)




tm <- microbenchmark(
  lcor_original(mydat4, tgt4),
  lcor_new(mydat4, tgt4),
  times = 100
)

summary(tm)
# ggplot2::autoplot(tm)

library(ggplot2)

autoplot(tm) +
  labs(
    title = "lcor() equivalent-value check",
    subtitle = "New code NEXT; Original code BREAK"
  ) +
  theme_minimal()
