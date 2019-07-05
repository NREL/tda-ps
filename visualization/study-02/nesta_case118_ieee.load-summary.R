require(data.table)
require(igraph)
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


br <- fread("../../contingency-datasets/study-02/nesta_case118_ieee/branches.tsv"  )
lo <- fread("../../contingency-datasets/study-02/nesta_case118_ieee/loads.tsv"     )
ge <- fread("../../contingency-datasets/study-02/nesta_case118_ieee/generators.tsv")
wg <- graph_from_edgelist(as.matrix(br[, .(From_Bus, To_Bus)]))
wl <- layout_nicely(wg, dim=3)


display_graph <- function() {
  iplot(
    wl[, 1], wl[, 2], wl[, 3],
    w_size=0.020,
    col=mapply(
      function(u) {
        is_load      = u %in% lo$At_Bus
        is_generator = u %in% ge$At_Bus
        if (is_load && is_generator)
          "red"
        else if (is_load)
          "blue"
        else if (is_generator)
          "green"
        else
          "black"
      },
      1:length(wl)
    ),
    id=-1
  )
  if (immersive)
    itooltips(mapply(function(u) paste("Bus", u), 1:length(wl)), id=-1)
  for (i in 1:dim(br)[1]) {
    ilines(
      c(wl[br[i, From_Bus], 1], wl[br[i, To_Bus], 1]),
      c(wl[br[i, From_Bus], 2], wl[br[i, To_Bus], 2]),
      c(wl[br[i, From_Bus], 3], wl[br[i, To_Bus], 3]),
      col="orange",
      w_size=0.005,
      id=i
    )
    if (immersive)
      itooltips(rep(paste("Branch", i), 2), i)
  }
}


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
