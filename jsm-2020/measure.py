import gudhi
import igraph
import matplotlib
import matplotlib.pyplot as plt
import numpy             as np
import os
import re
import pandas            as pd
import sys

from collections import namedtuple
from glob        import glob


Totals = namedtuple("Totals", ["devices", "loads"])


Analysis = namedtuple("Analysis", [
  "adjacency"  ,
  "rips"       ,
  "simplex"    ,
  "persistence",
  "diagram"    ,
])


Metrics = namedtuple("Metric", [
  "loss"        ,
  "betti_0"     ,
  "betti_1"     ,
  "bottleneck_0",
  "bottleneck_1",
])


Impact = namedtuple("Impact", [
  "reactance",
  "maxpower" ,
  "power"    ,
  "residue"  ,
  "count"    ,
])


def read_network(filename = "ACTIVSg2000.gml"):
  g = igraph.read(filename)
  return g.subgraph_edges(filter(lambda e: e["reactance"] > 0, g.es))


def read_base(prefix = "00/Line"):
  devices = pd.read_csv(prefix + "-0-0-devices.tsv", index_col = "Case", sep = "\t")
  loads   = pd.read_csv(prefix + "-0-0-loads.tsv"  , index_col = "Case", sep = "\t")
  return Totals(
    devices = sum(1 - devices.iloc[0]),
    loads   = sum(loads.iloc[0])      ,
  )


def read_cases(prefix, total_devices, total_loads):
  devices = pd.read_csv(prefix + "-devices.tsv", index_col = "Case", sep = "\t")
  loads   = pd.read_csv(prefix + "-loads.tsv"  , index_col = "Case", sep = "\t")
  outages = pd.DataFrame(
    devices.apply(lambda row: sum(row), axis = 1),
    index = devices.index,
    columns = ["Outage Count"],
  )
  outages["Outage Fraction"] = outages["Outage Count"] / total_devices
  outages["Outages"] = devices.apply(lambda row: list(row.index[row].values), axis=1)
  served = pd.DataFrame(
    loads.apply(lambda row: sum(row), axis = 1),
    index = loads.index,
    columns = ["Served MW"],
  )
  served["Unserved MW"] = total_loads - served["Served MW"]
  served["Unserved Fraction"] = 1 - served["Served MW"] / total_loads
  return outages.join(served)


def analyze_persistence(
  graph                       ,
  attribute                   ,
  reciprocate          = False,
  max_dimension        = 5    ,
  homology_coeff_field = 2    ,
):
  subgraph = graph.subgraph_edges(filter(lambda e: e[attribute] > 0, graph.es))
  adjacency = np.array(subgraph.get_adjacency(attribute).data)
  unconnected = adjacency == 0
  limit = np.array(adjacency[~unconnected].min() if reciprocate else adjacency.max())
  if reciprocate:
    with np.errstate(divide='ignore'):
      limit     = np.divide(1, limit    )
      adjacency = np.divide(1, adjacency)
  adjacency[unconnected] = 3 * limit
  rips = gudhi.RipsComplex(distance_matrix = adjacency, max_edge_length = 2 * limit)
  simplex = rips.create_simplex_tree(max_dimension = max_dimension)
  persistence = simplex.persistence(homology_coeff_field = homology_coeff_field, min_persistence = 0)
  diagram = [
    simplex.persistence_intervals_in_dimension(d)
    for d in range(0, simplex.dimension())
  ]
  return Analysis(
    adjacency   = adjacency  ,
    rips        = rips       ,
    simplex     = simplex    ,
    persistence = persistence,
    diagram     = diagram    ,
  )


def analyze_persistences(
  graph                   ,
  max_dimension        = 5,
  homology_coeff_field = 2,
):
  return Impact(
    reactance = analyze_persistence(graph, "reactance", False, max_dimension, homology_coeff_field),
    maxpower  = analyze_persistence(graph, "maxpower" , True , max_dimension, homology_coeff_field),
    power     = analyze_persistence(graph, "power"    , True , max_dimension, homology_coeff_field),
    residue   = analyze_persistence(graph, "residue"  , True , max_dimension, homology_coeff_field),
    count     = analyze_persistence(graph, "count"    , True , max_dimension, homology_coeff_field),
  )


def measure_aspect(
  base_analysis               ,
  edges                       ,
  graph                       ,
  attribute                   ,
  reciprocate          = False,
  max_dimension        = 5    ,
  homology_coeff_field = 2    ,
):
  analysis = analyze_persistence(graph, attribute, reciprocate, max_dimension, homology_coeff_field)
  betti = analysis.simplex.betti_numbers()
  return Metrics(
    loss         = sum(map(lambda e: e[attribute], edges))                           ,
    betti_0      = betti[0]                                                          ,
    betti_1      = betti[1]                                                          ,
    bottleneck_0 = gudhi.bottleneck_distance(getattr(base_analysis, attribute).diagram[0], analysis.diagram[0]),
    bottleneck_1 = gudhi.bottleneck_distance(getattr(base_analysis, attribute).diagram[1], analysis.diagram[1]),
  )


def measure_impact(
  base_analysis           ,
  graph                   ,
  row                     ,
  max_dimension        = 5,
  homology_coeff_field = 2,
):
  edges = graph.es.select(lambda e: e["label"] in row["Outages"])
  subgraph = graph.subgraph_edges(filter(lambda e: not(e["label"] in row["Outages"]), graph.es))
  return Impact(
    reactance = measure_aspect(base_analysis, edges, subgraph, "reactance", False, max_dimension, homology_coeff_field),
    maxpower  = measure_aspect(base_analysis, edges, subgraph, "maxpower" , True , max_dimension, homology_coeff_field),
    power     = measure_aspect(base_analysis, edges, subgraph, "power"    , True , max_dimension, homology_coeff_field),
    residue   = measure_aspect(base_analysis, edges, subgraph, "residue"  , True , max_dimension, homology_coeff_field),
    count     = measure_aspect(base_analysis, edges, subgraph, "count"    , True , max_dimension, homology_coeff_field),
  )


def measure_impacts(
  base_analysis           ,
  results                 ,
  graph                   ,
  max_dimension        = 5,
  homology_coeff_field = 2,
):
  impacts = results.apply(lambda row: measure_impact(base_analysis, graph, row, max_dimension, homology_coeff_field), axis=1)
  results["Reactance Loss pu"      ] = impacts.apply(lambda i: i.reactance.loss        )
  results["Reactance Betti 0"      ] = impacts.apply(lambda i: i.reactance.betti_0     )
  results["Reactance Betti 1"      ] = impacts.apply(lambda i: i.reactance.betti_1     )
  results["Reactance Bottleneck 0" ] = impacts.apply(lambda i: i.reactance.bottleneck_0)
  results["Reactance Bottleneck 1" ] = impacts.apply(lambda i: i.reactance.bottleneck_1)
  results["Capacity Loss MW"       ] = impacts.apply(lambda i: i.maxpower.loss         )
  results["Capacity Betti 0"       ] = impacts.apply(lambda i: i.maxpower.betti_0      )
  results["Capacity Betti 1"       ] = impacts.apply(lambda i: i.maxpower.betti_1      )
  results["Capacity Bottleneck 0"  ] = impacts.apply(lambda i: i.maxpower.bottleneck_0 )
  results["Capacity Bottleneck 1"  ] = impacts.apply(lambda i: i.maxpower.bottleneck_1 )
  results["Base Flow Loss MW"      ] = impacts.apply(lambda i: i.power.loss            )
  results["Base Flow Betti 0"      ] = impacts.apply(lambda i: i.power.betti_0         )
  results["Base Flow Betti 1"      ] = impacts.apply(lambda i: i.power.betti_1         )
  results["Base Flow Bottleneck 0" ] = impacts.apply(lambda i: i.power.bottleneck_0    )
  results["Base Flow Bottleneck 1" ] = impacts.apply(lambda i: i.power.bottleneck_1    )
  results["Residue Loss MW"        ] = impacts.apply(lambda i: i.residue.loss          )
  results["Residue Betti 0"        ] = impacts.apply(lambda i: i.residue.betti_0       )
  results["Residue Betti 1"        ] = impacts.apply(lambda i: i.residue.betti_1       )
  results["Residue Bottleneck 0"   ] = impacts.apply(lambda i: i.residue.bottleneck_0  )
  results["Residue Bottleneck 1"   ] = impacts.apply(lambda i: i.residue.bottleneck_1  )
  results["Unweighted Loss"        ] = impacts.apply(lambda i: i.count.loss            )
  results["Unweighted Betti 0"     ] = impacts.apply(lambda i: i.count.betti_0         )
  results["Unweighted Betti 1"     ] = impacts.apply(lambda i: i.count.betti_1         )
  results["Unweighted Bottleneck 0"] = impacts.apply(lambda i: i.count.bottleneck_0    )
  results["Unweighted Bottleneck 1"] = impacts.apply(lambda i: i.count.bottleneck_1    )


def plot_persistences(
  graph                   ,
  max_dimension        = 5,
  homology_coeff_field = 2,
):
  analyses = analyze_persistences(graph, max_dimension, homology_coeff_field)
  gudhi.plot_persistence_barcode(analyses.reactance.persistence)
  plt.savefig("barcode-reactance.png")
  plt.close()
  gudhi.plot_persistence_barcode(analyses.maxpower.persistence)
  plt.savefig("barcode-maxpower.png")
  plt.close()
  gudhi.plot_persistence_barcode(analyses.power.persistence)
  plt.savefig("barcode-power.png")
  plt.close()
  gudhi.plot_persistence_barcode(analyses.residue.persistence)
  plt.savefig("barcode-residue.png")
  plt.close()
  gudhi.plot_persistence_barcode(analyses.count.persistence)
  plt.savefig("barcode-count.png")
  plt.close()
  return analyses


# FIXME: Add unweighted to analysis.
# FIXME: Add remaining capacity to analysis.


graph = read_network()
analysis = plot_persistences(graph)
totals = read_base()
for folder in sys.argv[1:]:
  for filename in glob(os.path.join(folder, "*-loads.tsv")):
    prefix = re.sub(r"-(devices|loads).tsv$", "", filename)
    if os.path.isfile(prefix + "-results.tsv"):
      continue
    print("Prefix: ", prefix)
    results = read_cases(prefix, totals.devices, totals.loads)
    append = False
    for indices in np.array_split(results.index, max(int(results.shape[0] / 10), 1)):
      batch = results.loc[indices].copy()
      measure_impacts(analysis, batch, graph)
      batch["Outages"] = list(map(str, batch["Outages"]))
      with open(prefix + "-results.tsv", "a" if append else "w") as file:
        batch.to_csv(file, header = not(append), sep = "\t")
      append = True

