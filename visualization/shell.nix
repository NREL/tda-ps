{iplotAvailable ? true}:

with import <nixpkgs> {};

let

  iplot = import ./iplot.nix {
    inherit stdenv fetchgit openssl zlib R rPackages;
  };

in

  stdenv.mkDerivation rec {
    name = "browse-tpca-tsne";
    phases = "buildPhase";
    dontBuild = true;
    buildInputs = [
      R
      rPackages.data_table
      rPackages.GGally
      rPackages.ggplot2
      rPackages.igraph
      rPackages.memo
      rPackages.plotrix
      rPackages.shiny
      rPackages.shinyjs
    ]
    ++
    (
      if iplotAvailable
        then [
          iplot
          rPackages.codetools
          rPackages.jsonlite
          rPackages.Rcpp
        ]
        else []
    );
#   shellHook = ''
#     Rscript browse-visualizations.R ${host} ${port}
#     exit
#   '';
  }
