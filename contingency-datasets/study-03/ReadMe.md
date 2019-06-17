# Random Permutations of Sequences of Branch Contingencies


## Results

| NESTA 30 IEEE                                                                                               | NESTA 118 IEEE                                                                                               | NESTA 3120 SP MP                                                                                              |
|-------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| 1000 cases                                                                                                  | 1000 cases                                                                                                   | 60+ cases                                                                                                     |
|  [all results](https://nrel-demos.s3-us-west-2.amazonaws.com/tda-ps/study-03/nesta_case30_ieee/results.zip) |  [all results](https://nrel-demos.s3-us-west-2.amazonaws.com/tda-ps/study-03/nesta_case118_ieee/results.zip) |  [all results](https://nrel-demos.s3-us-west-2.amazonaws.com/tda-ps/study-03/nesta_case3120sp_mp/results.zip) |
|  [summary of results](nesta_case30_ieee/summary.tsv)                                                        |  [nesta_case118_ieee/summary.tsv](nesta_case118_ieee/summary.tsv)                                            |  [nesta_case3120sp_mp/summary.tsv](nesta_case3120sp_mp/summary.tsv)                                           |
| ![nesta_case30_ieee/summary.png](nesta_case30_ieee/summary.png)                                             | ![nesta_case118_ieee/summary.png](nesta_case118_ieee/summary.png)                                            | ![nesta_case3120sp_mp/summary.png](nesta_case3120sp_mp/summary.png)                                           |


## Networks

| NESTA 30 IEEE                                               | NESTA 118 IEEE                                                | NESTA 3120 SP MP                                                |
|-------------------------------------------------------------|---------------------------------------------------------------|-----------------------------------------------------------------|
|  [nesta_case30_ieee/graph.dot](nesta_case30_ieee/graph.dot) |  [nesta_case118_ieee/graph.dot](nesta_case118_ieee/graph.dot) |  [nesta_case3120sp_mp/graph.dot](nesta_case3120sp_mp/graph.dot) |
| ![nesta_case30_ieee/graph.svg](nesta_case30_ieee/graph.svg) | ![nesta_case118_ieee/graph.svg](nesta_case118_ieee/graph.svg) | ![nesta_case3120sp_mp/graph.svg](nesta_case3120sp_mp/graph.svg) |


## Key to Directories and Files


### Directories

Each directory contains contingency cases for a different network.


### Files

| File             | Description                    |
|------------------|--------------------------------|
| graph.dot        | GraphViz .dot file for network |
| graph.svg        | SVG image of network           |
| branches.tsv     | line/transformer connectivity  |
| loads.tsv        | load connectivity              |
| generators.tsv   | generator connectivity         |
| results-*i*.tsv  | results of contigency case *i* |


### Fields in results files

The row with `Sequence = -1` and `Status = "LIMITS"` shows the maximum allowed values fro the flows, generation, and consumption.

| Field    | Description                                |
|----------|--------------------------------------------|
| Sequence | Number of node contingencies               |
| Status   | Whether the solution was successful        |
| b\_*i*   | Whehter bus *i* is in service              |
| f\_*i*   | Whether line/transformer *i* is in service |
| g\_*i*   | Whether load *i* is in service             |
| F\_*i*   | Per-unit flow in line/transformer *i*      |
| G\_*i*   | Per-unit generation at generator *i*       |
| L\_*i*   | Per-unit consumption at load *i*           |
