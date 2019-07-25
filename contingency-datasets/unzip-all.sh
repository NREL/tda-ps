#!/usr/bin/env bash

mkdir study-01/nesta_case118_ieee  >& /dev/null
mkdir study-01/nesta_case30_ieee   >& /dev/null
mkdir study-02/nesta_case118_ieee  >& /dev/null
mkdir study-02/nesta_case118_ieee  >& /dev/null
mkdir study-02/nesta_case30_ieee   >& /dev/null
mkdir study-02/nesta_case30_ieee   >& /dev/null
mkdir study-02/nesta_case3120sp_mp >& /dev/null
mkdir study-03/nesta_case118_ieee  >& /dev/null
mkdir study-03/nesta_case30_ieee   >& /dev/null
mkdir study-03/nesta_case30_ieee   >& /dev/null
mkdir study-03/nesta_case3120sp_mp >& /dev/null
mkdir study-05/nesta_case118_ieee  >& /dev/null

unzip -o study-01/nesta_case118_ieee/results.zip  -d study-01/nesta_case118_ieee
unzip -o study-01/nesta_case30_ieee/results.zip   -d study-01/nesta_case30_ieee
unzip -o study-02/nesta_case118_ieee/results.zip  -d study-02/nesta_case118_ieee
unzip -o study-02/nesta_case118_ieee/unique.zip   -d study-02/nesta_case118_ieee
unzip -o study-02/nesta_case30_ieee/results.zip   -d study-02/nesta_case30_ieee
unzip -o study-02/nesta_case30_ieee/unique.zip    -d study-02/nesta_case30_ieee
unzip -o study-02/nesta_case3120sp_mp/results.zip -d study-02/nesta_case3120sp_mp
unzip -o study-03/nesta_case118_ieee/results.zip  -d study-03/nesta_case118_ieee
unzip -o study-03/nesta_case30_ieee/results.zip   -d study-03/nesta_case30_ieee
unzip -o study-03/nesta_case30_ieee/unique.zip    -d study-03/nesta_case30_ieee
unzip -o study-03/nesta_case3120sp_mp/results.zip -d study-03/nesta_case3120sp_mp
unzip -o study-05/nesta_case118_ieee/results.zip  -d study-05/nesta_case118_ieee
