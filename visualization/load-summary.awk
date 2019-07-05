#!/usr/bin/gawk -f

BEGIN {
  FS = "\t"
  OFS = "\t"

  print "Case", "Sequence", "Maximum Load [MW]", "Served Load [MW]", "Directly Shed Load [MW]", "Cascading Shed Load [MW]"
}

BEGINFILE {
  run = gensub("^.*\\/result-(.*)\\.tsv$", "\\1", "g", FILENAME)
}

FNR == 1 {
  for (i = 3; i <= NF; ++i) {
    key[i] = $i
    unkey[$i]  = i
  }
}

$2 == "LIMITS" {
  loadLimit = 0
  generationLimit = 0
  for (i = 3; i <= NF; ++i) {
    field = key[i]
    value = $i
    limits[field] = value
    if (index(field, "G_") == 1)
      generationLimit += value
    else if (index(field, "L_") == 1)
      loadLimit += value
  }
}

$2 == "LOCALLY_SOLVED" {
  sequence = $1
  loadServed = 0
  loadDirect = 0
  for (i = 3; i <= NF; ++i) {
    field = key[i]
    value = $i
    if (index(field, "L_") == 1) {
      loadServed += value
      if ($unkey[gensub("^L", "b", "g", field)] == "false")
        loadDirect += limits[field]
    }
  }
  loadCascade = loadLimit - loadServed - loadDirect
  if (loadCascade < 0) {
    loadCascade = 0
    loadDirect = loadLimit - loadServed - loadCascade
  }
  print run, sequence, loadLimit, loadServed, loadDirect, loadCascade
}
