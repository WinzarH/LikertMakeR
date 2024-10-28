## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, include = FALSE---------------------------------------------------
library(LikertMakeR)

## ----logo, fig.align='center', echo=FALSE, out.width = '25%'------------------
knitr::include_graphics("LikertMakeR_3.png")

## ----lfastExample-------------------------------------------------------------
x1 <- lfast(
  n = 512,
  mean = 2.5,
  sd = 0.75,
  lowerbound = 1,
  upperbound = 5,
  items = 4
)

## ----fig1, fig.height=3, fig.width=4, fig.align='center', echo = FALSE--------
## distribution of x

hist(x1,
  cex.axis = 0.5, cex.main = 0.75,
  breaks = seq(from = 1, to = 5, by = 0.25),
  col = "skyblue", xlab = NULL, ylab = NULL,
  main = paste("mu=", round(mean(x1), 2), ", sd=", round(sd(x1), 2))
)

## ----lfastx3------------------------------------------------------------------
x3 <- lfast(256, 3, 2, 0, 10)

## ----fig2, fig.height=3, fig.width=4, fig.align='center', echo = FALSE--------
hist(x3,
  cex.axis = 0.5, cex.main = 0.75,
  breaks = seq(from = 0, to = 10, by = 1.0),
  col = "skyblue", xlab = NULL, ylab = NULL,
  main = paste("mu=", round(mean(x3), 2), ", sd=", round(sd(x3), 2))
)

## ----lcorExample--------------------------------------------------------------
## generate uncorrelated synthetic data
n <- 128
lowerbound <- 1
upperbound <- 5
items <- 5

mydat3 <- data.frame(
  x1 = lfast(n, 2.5, 0.75, lowerbound, upperbound, items),
  x2 = lfast(n, 3.0, 1.50, lowerbound, upperbound, items),
  x3 = lfast(n, 3.5, 1.00, lowerbound, upperbound, items)
)

## ----mydat3Head, echo = FALSE-------------------------------------------------
head(mydat3, 6)

## ----mydat3Moments, echo = FALSE----------------------------------------------
moments <- data.frame(
  mean = apply(mydat3, 2, mean) |> round(3),
  sd = apply(mydat3, 2, sd) |> round(3)
)

t(moments)

## ----mydat3Cor, echo = FALSE--------------------------------------------------
cor(mydat3) |> round(3)

## ----tgt3---------------------------------------------------------------------
## describe a target correlation matrix

tgt3 <- matrix(
  c(
    1.00, 0.85, 0.75,
    0.85, 1.00, 0.65,
    0.75, 0.65, 1.00
  ),
  nrow = 3
)

## ----new3---------------------------------------------------------------------
## apply lcor() function

new3 <- lcor(mydat3, tgt3)

## ----new3Head, echo = FALSE---------------------------------------------------
head(new3, 6)

## ----new3Cor, echo = FALSE----------------------------------------------------
cor(new3) |> round(3)

## ----cor_matrix_4-------------------------------------------------------------
## define parameters
items <- 4
alpha <- 0.85
# variance <- 0.5 ## by default

## apply makeCorrAlpha() function
set.seed(42)

cor_matrix_4 <- makeCorrAlpha(items, alpha)

## ----cor_matrix_4Print, echo = FALSE------------------------------------------
cor_matrix_4 |> round(3)

## ----cor_matrix_4Alpha--------------------------------------------------------
## using helper function alpha()

alpha(cor_matrix_4)

## ----fig3, fig.height=4, fig.width=4, fig.align='center', echo = TRUE---------
## using helper function eigenvalues()

eigenvalues(cor_matrix_4, 1)

## ----cor_matrix_12------------------------------------------------------------
## define parameters
items <- 12
alpha <- 0.90
variance <- 1.0

## apply makeCorrAlpha() function
set.seed(42)

cor_matrix_12 <- makeCorrAlpha(items, alpha, variance)

## ----cor_matrix_12Print, echo = FALSE-----------------------------------------
cor_matrix_12 |> round(2)

## ----fig4, fig.height=4, fig.width=4, fig.align='center', echo = TRUE---------
alpha(cor_matrix_12)

eigenvalues(cor_matrix_12, 1) |> round(3)

## ----makeItemsExample---------------------------------------------------------
## define parameters

n <- 128
dfMeans <- c(2.5, 3.0, 3.0, 3.5)
dfSds <- c(1.0, 1.0, 1.5, 0.75)
lowerbound <- rep(1, 4)
upperbound <- rep(5, 4)

corMat <- matrix(
  c(
    1.00, 0.25, 0.35, 0.45,
    0.25, 1.00, 0.70, 0.75,
    0.35, 0.70, 1.00, 0.85,
    0.45, 0.75, 0.85, 1.00
  ),
  nrow = 4, ncol = 4
)

## apply makeItems() function
df <- makeItems(
  n = n,
  means = dfMeans,
  sds = dfSds,
  lowerbound = lowerbound,
  upperbound = upperbound,
  cormatrix = corMat
)

## test the function
head(df)
tail(df)
apply(df, 2, mean) |> round(3)
apply(df, 2, sd) |> round(3)
cor(df) |> round(3)

## ----genCorrelation-----------------------------------------------------------
## define parameters
k <- 6
alpha <- 0.85

## generate correlation matrix
set.seed(42)
myCorr <- makeCorrAlpha(k, alpha)

## display correlation matrix
myCorr |> round(3)

### checking Cronbach's Alpha
alpha(myCorr)

## ----gendataframe-------------------------------------------------------------
## define parameters
n <- 256
myMeans <- c(2.75, 3.00, 3.00, 3.25, 3.50, 3.5)
mySds <- c(1.00, 0.75, 1.00, 1.00, 1.00, 1.5)
lowerbound <- rep(1, k)
upperbound <- rep(5, k)

## Generate Items
myItems <- makeItems(n, myMeans, mySds, lowerbound, upperbound, myCorr)

## resulting data frame
head(myItems)
tail(myItems)

## means and standard deviations
myMoments <- data.frame(
  means = apply(myItems, 2, mean) |> round(3),
  sds = apply(myItems, 2, sd) |> round(3)
) |> t()
myMoments

## Cronbach's Alpha of data frame
alpha(NULL, myItems)

## ----fig5, fig.height=5, fig.width=5, fig.align='center', echo=FALSE, warning=FALSE----
# Correlation panel
panel.cor <- function(x, y) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits = 2)
  txt <- paste0(r)
  cex.cor <- 0.8 / strwidth(txt)
  text(0.5, 0.5, txt, cex = 1.25)
}
# Customize upper panel
upper.panel <- function(x, y) {
  points(x, y, pch = 19, col = "#0000ff11")
}
# diagonals
panel.hist <- function(x, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5))
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks
  nB <- length(breaks)
  y <- h$counts
  y <- y / max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "#0000ff50")
}
# Create the plots
pairs(myItems,
  lower.panel = panel.cor,
  upper.panel = upper.panel,
  diag.panel = panel.hist
)

## ----correlateScales_dataframes, echo = TRUE----------------------------------
n <- 32
lower <- 1
upper <- 5

### attitude #1
cor_1 <- makeCorrAlpha(items = 4, alpha = 0.90)
means_1 <- c(2.5, 2.5, 3.0, 3.5)
sds_1 <- c(0.9, 1.0, 0.9, 1.0)
Att_1 <- makeItems(
  n, means_1, sds_1,
  rep(lower, 4), rep(upper, 4),
  cor_1
)

### attitude #2
cor_2 <- makeCorrAlpha(items = 5, alpha = 0.85)
means_2 <- c(2.5, 2.5, 3.0, 3.0, 3.5)
sds_2 <- c(1.0, 1.0, 0.9, 1.0, 1.5)
Att_2 <- makeItems(
  n, means_2, sds_2,
  rep(lower, 5), rep(upper, 5),
  cor_2
)

### attitude #3
cor_3 <- makeCorrAlpha(items = 6, alpha = 0.75)
means_3 <- c(2.5, 2.5, 3.0, 3.0, 3.5, 3.5)
sds_3 <- c(1.0, 1.5, 1.0, 1.5, 1.0, 1.5)

Att_3 <- makeItems(
  n, means_3, sds_3,
  rep(lower, 6), rep(upper, 6),
  cor_3
)

### behavioural intention
intent <- lfast(n, mean = 3.0, sd = 3, lowerbound = 0, upperbound = 10) |>
  data.frame()
names(intent) <- "int"

## ----dataframe_properties-----------------------------------------------------
## Attitude #1
A1_moments <- data.frame(
  means = apply(Att_1, 2, mean) |> round(2),
  sds = apply(Att_1, 2, sd) |> round(2)
) |> t()
A1_moments
cor(Att_1) |> round(2)

## Attitude #2
A2_moments <- data.frame(
  means = apply(Att_2, 2, mean) |> round(2),
  sds = apply(Att_2, 2, sd) |> round(2)
) |> t()

A2_moments
cor(Att_2) |> round(2)

## Attitude #3
A3_moments <- data.frame(
  means = apply(Att_3, 2, mean) |> round(2),
  sds = apply(Att_3, 2, sd) |> round(2)
) |> t()

A3_moments
cor(Att_3) |> round(2)

## Intention

intent_moments <- data.frame(
  mean = apply(intent, 2, mean) |> round(2),
  sd = apply(intent, 2, sd) |> round(2)
) |> t()

intent_moments

## ----correlateScales_parameters-----------------------------------------------
### target scale correlation matrix
scale_cors <- matrix(
  c(
    1.0, 0.6, 0.5, 0.3,
    0.6, 1.0, 0.4, 0.2,
    0.5, 0.4, 1.0, 0.1,
    0.3, 0.2, 0.1, 1.0
  ),
  nrow = 4
)

data_frames <- list("A1" = Att_1, "A2" = Att_2, "A3" = Att_3, "Int" = intent)

## ----my_correlated_scales-----------------------------------------------------
my_correlated_scales <- correlateScales(
  dataframes = data_frames,
  scalecors = scale_cors
)

## ----fig6, fig.height=9, fig.width=9, fig.align='center', echo=FALSE, warning=FALSE----
# Correlation panel
panel.cor <- function(x, y) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits = 2)
  txt <- paste0(r)
  cex.cor <- 0.8 / strwidth(txt)
  text(0.5, 0.5, txt, cex = 1.25)
}
# Customize upper panel
upper.panel <- function(x, y) {
  points(x, y, pch = 19, col = "#0000ff11")
}
# diagonals
panel.hist <- function(x, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5))
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks
  nB <- length(breaks)
  y <- h$counts
  y <- y / max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "#0000ff50")
}
# Create the plots
pairs(my_correlated_scales,
  lower.panel = panel.cor,
  upper.panel = upper.panel,
  diag.panel = panel.hist
)

## ----newdata_check------------------------------------------------------------
## data structure
str(my_correlated_scales)

## ----fig7, fig.height=4, fig.width=5, fig.align='center', echo = TRUE---------
## eigenvalues of dataframe correlations
eigenvalues(cormatrix = cor(my_correlated_scales), scree = TRUE) |> round(2)

## ----alphaExample-------------------------------------------------------------
## define parameters
df <- data.frame(
  V1 = c(4, 2, 4, 3, 2, 2, 2, 1),
  V2 = c(3, 1, 3, 4, 4, 3, 2, 3),
  V3 = c(4, 1, 3, 5, 4, 1, 4, 2),
  V4 = c(4, 3, 4, 5, 3, 3, 3, 3)
)

corMat <- matrix(
  c(
    1.00, 0.35, 0.45, 0.75,
    0.35, 1.00, 0.65, 0.55,
    0.45, 0.65, 1.00, 0.65,
    0.75, 0.55, 0.65, 1.00
  ),
  nrow = 4, ncol = 4
)

## apply function examples
alpha(cormatrix = corMat)
alpha(data = df)
alpha(NULL, df)
alpha(corMat, df)

## ----eigenExample-------------------------------------------------------------
## define parameters
correlationMatrix <- matrix(
  c(
    1.00, 0.25, 0.35, 0.45,
    0.25, 1.00, 0.70, 0.75,
    0.35, 0.70, 1.00, 0.85,
    0.45, 0.75, 0.85, 1.00
  ),
  nrow = 4, ncol = 4
)

## apply function
evals <- eigenvalues(cormatrix = correlationMatrix)

print(evals)

## ----fig8, fig.height=4, fig.width=4, fig.align='center', echo = TRUE---------
evals <- eigenvalues(correlationMatrix, 1)

## ----eval = FALSE-------------------------------------------------------------
#  n <- 128
#  sample(1:5, n,
#    replace = TRUE,
#    prob = c(0.1, 0.2, 0.4, 0.2, 0.1)
#  )

