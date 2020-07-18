with import <nixpkgs> {};

let

  dependencies = rec {

    IRdisplay = stdenv.mkDerivation rec {
      name = "IRdisplay";
      buildInputs = [ R ];
      src = fetchgit {
        url = "https://github.com/IRkernel/IRdisplay";
        rev = "6f2757549d8902f3928e1e2eacadf1c65e3931a8";
        sha256 = "179safd480g2s60fp6kca9sxgsgf925rf852pc6lz0qr1ggkwc7d";
        fetchSubmodules = true;
      };
      buildPhase = ":";
      installPhase = ''
        mkdir -p $out
        export R_LIBS=$out
        ${R}/bin/R CMD INSTALL .
      '';
    };
  
    IRkernel = stdenv.mkDerivation rec {
      name = "IRkernel";
      buildInputs = [ R IRdisplay ];
      src = fetchgit {
        url ="https://github.com/IRkernel/IRkernel";
        rev ="39456a0596bbe39257f60b1567d6029c5497961e";
        sha256 = "1zwgahkz7678y1hrd7wmc13dy4zwwihawp3nxkdd1a365hqjvbin";
        fetchSubmodules= false;
      };
      buildPhase = ":";
      installPhase = ''
        mkdir -p $out
        export R_LIBS=$out:${IRdisplay}
        ${R}/bin/R CMD INSTALL .
      '';
    };
  
    R = rWrapper.override {
      packages = with rPackages; [
        # Kernel
        crayon
        digest
        evaluate
        jsonlite
        pbdZMQ
        repr
        uuid
        # Custom packages
        arm
        BH
        circlize
        codetools
        data_table
        deSolve
        DBI
      # dplr
        FNN
        GGally
        glmulti
        ggplot2
        highr
        Hmisc
        httr
        igraph
        InformationValue
      # iplot
        keras
        kernlab
        knitr
        kSamples
        lubridate
        magrittr
        memo
        mlogit
        mnlogit
        multinomRob
        nnet
        np
        plotrix
        quantmod
        quantreg
        randomForest
        Rcpp
        RcppEigen
        regclass
        reshape2
        rpart
        rTensor
        shiny
        shinyjs
        smbinning
        SPARQL
        sqldf
        stringr
      # TDA
        tensorflow
        tidyr
        validann
        yaml
      ];
    };
  
    jupyter_config_dir = stdenv.mkDerivation {
      name = "jupyter-config";
      buildInputs = [
        python36Packages.jupyter
        IRkernel
      ];
      ir_json = builtins.toJSON {
        argv = [ "${R}/bin/R"
                 "--slave" "-e" "IRkernel::main()"
                 "--args" "{connection_file}" ];
        env = { "R_LIBS_USER" = ".R:${IRkernel}:${IRdisplay}"; };
        display_name = "R";
        language = "R";
      };
      builder = writeText "builder.sh" ''
        source $stdenv/setup
        mkdir -p $out/share/jupyter/kernels/ir
        echo $out
        echo $R_SITE_LIBS
        cat > $out/share/jupyter/kernels/ir/kernel.json << EOF
        $ir_json
        EOF
      '';
    };

  };

in

  with dependencies;
  stdenv.mkDerivation rec {
    name = "jupyter-local";
    buildInputs = [
      jupyter_config_dir
      python36Packages.jupyter
    ];
    shellHook = ''
      mkdir -p $PWD/.R
#     cp -nr ${jupyter_config_dir}/.jupyter  $PWD/
#     chmod -R u+w .R .jupyter
      export HOME=$PWD
      export JUPYTER_PATH=${jupyter_config_dir}/share/jupyter
      export JUPYTER_CONFIG_DIR=${jupyter_config_dir}/share/jupyter
#     jupyter notebook --no-browser
#     exit
    '';
  }
