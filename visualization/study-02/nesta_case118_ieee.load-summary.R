require(data.table)
require(iplot)

immersive <- FALSE
if (immersive && !exists("plotty_initialized")) {
  plotty_init()
  plotty_initialized <= TRUE
}


w <- fread("nesta_case118_ieee.load-summary.tsv")
w <- w[Case <= 1000]
cases <- unique(w$Case)
n <- length(cases)
colors <- rainbow(n)
invisible(w[, Color:=colors[Case]])


display_shed <- function(n=1000, eps=0.1) {
  display_cases(
    "Served Load [MW]"        ,
    "Cascading Shed Load [MW]",
    "Directly Shed Load [MW]" ,
    n=n, eps=eps
  )
}

display_sequence <- function(n=100, eps=0.1) {
  display_cases(
    "Sequence"                ,
    "Cascading Shed Load [MW]",
    "Directly Shed Load [MW]" ,
    n=n, eps=eps
  )
}

display_cases <- function(xcol, ycol, zcol, n=100, eps=0.1)
{
  first <- TRUE
  for (i in cases[1:min(n, length(cases))]) {
    ww <- w[Case == i]
    cc <- ww[1, Color]
    xx <- ww[[xcol]]
    yy <- ww[[ycol]]
    zz <- ww[[zcol]]
    mask <- abs(head(xx, -1) - tail(xx, -1)) > eps |
            abs(head(yy, -1) - tail(yy, -1)) > eps |
            abs(head(zz, -1) - tail(zz, -1)) > eps 
    xx <- xx[mask]
    yy <- yy[mask]
    zz <- zz[mask]
    if (first) {
      first <- FALSE
      iplot(
        xx, yy, zz,
        col=cc,
        type="l",
        xlab=xcol,
        ylab=ycol,
        zlab=zcol,
        xlim=c(0, max(w[[xcol]])),
        ylim=c(0, max(w[[ycol]])),
        zlim=c(0, max(w[[zcol]])),
        wx_lim=c(-1.25, 1.25),
        wy_lim=c( 0.25, 2.00),
        wz_lim=c( 0.25, 1.25),
        w_size=0.002,
        id=i
      )
    } else
      ilines(
        xx, yy, zz,
        col=cc,
        w_size=0.002,
        id=i
      )
   if (immersive)
     itooltips(rep(paste("Case", i), length(xx)), id=i)
  }
}
