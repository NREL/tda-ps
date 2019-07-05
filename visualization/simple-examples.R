require(data.table)
require(iplot)


# Comment the following line when not using iplot in the visualization laboratory.
plotty_init()


# Read and organize example data.
w <- fread("../contingency-datasets/study-03/nesta_case3120sp_mp/summary.tsv")
cases <- unique(w$Case)
n <- length(cases)
colors <- rainbow(n)
invisible(w[, Color:=colors[Case]])


# Make a simple scatterplot.
example1 <- function()
{
  iplot(w$Case, w$Sequence, w$Load, col=w$Color, xlab="Case", ylab="Contingencies", zlab="System Load")
}


# Make a simple line plot.
example2 <- function()
{
  first <- TRUE
  for (i in cases) {
    ww <- w[Case == i]
    if (first) {
      first <- FALSE
      iplot(ww$Case, ww$Sequence, ww$Load, col=colors[i],
            type="l", xlab="Case", ylab="Contingencies", zlab="System Load",
            xlim=range(w$Case), ylim=range(w$Sequence), zlim=range(w$Load)
           )
    } else
      ilines(ww$Case, ww$Sequence, ww$Load, col=colors[i])
  }
}
