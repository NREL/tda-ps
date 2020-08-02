Topology-Based Machine-Learning for Modeling Power-System Responses to Contingencies
====================================================================================


Abstract
--------

This is the companion dataset to the presentation NREL/PR-6A20-77485, which was presented at the 2020 Joint Statistical Meeting on August 3, 2020. Developed for the machine-learning predictive modeling of power-system responses to disruptions, it contains results of power-system contingency analyses along with graph and topology measurements under each contingency scenario of the power system.


Files
-----

*   `ACTIVEsg2000.gml`: Graph describing the power system.
*   `partial-results-20200731.tsv`: Results of the power-system simulations and graph/topology measurements.


Data Dictionary for `ACTIVsg2000.gml`
-------------------------------------

The file is in Graph Markup Language (GML) format. It contains the following attributes.

| Attribute  | Type             | Units         | Description                                                    |
|------------|------------------|---------------|----------------------------------------------------------------|
| label      | character string | n/a           | Identifier for the component.                                  |
| device     | character string | n/a           | Type of device.                                                |
| maxpower   | real number      | MW            | Capacity (maximum flow/generation/consumption) for the device. |
| flow       | real number      | MW            | Flow/generation/consumption in the base (no outages) case.     |
| residue    | real number      | MW            | Unused capacity in the base case.                              |
| count      | integer          | dimensionless | Number of components.                                          |
| resistance | real number      | per unit      | Electrical resistance of the component.                        |
| reactance  | real number      | per unit      | Electrical reactance of the component.                         |


Data Dictionary for `partial-results-20200731.tsv`
--------------------------------------------------

The file is in tab-separated-value (TSV) format with the header in the first line. It contains the fields below.

| Field                   | Type             | Units         |                                                                                  |
|-------------------------|------------------|---------------|----------------------------------------------------------------------------------|
| Devices                 | character string | n/a           | Types of devices allowed in the contignency.                                     |
| Radius                  | real number      | dimensionless | Radius of subgraph in which contingencies are chosen.                            |
| Fraction                | real number      | dimensionless | Fraction of components within the subgraph that are outaged.                     |
| Outage Count            | real number      | dimensionless | Number of components that are outaged.                                           |
| Outage Fraction         | real number      | dimensionless | Fraction of components in whole graph that are outaged.                          |
| Outages                 | list of integers | n/a           | Identifiers for the components that are outaged.                                 |
| Served MW               | real number      | MW            | Customer load that is served.                                                    |
| Unserved MW             | real number      | MW            | Customer load that is not served.                                                |
| Unserved Fraction       | real number      | dimensionless | Fraction of customer load that is not served.                                    |
| Reactance Loss pu       | real number      | per-unit      | Total reactance for the outaged components.                                      |
| Reactance Betti 0       | real number      | dimensionless | First Betti number, computed using reactance as the edge weight.                 |
| Reactance Betti 1       | real number      | dimensionless | Second Betti number, computed using reactance as the edge weight.                |
| Reactance Bottleneck 0  | real number      | dimensionless | First bottleneck distance, computed using reactance as the edge weight.          |
| Reactance Bottleneck 1  | real number      | dimensionless | Second bottleneck distance, computed using reactance as the edge weight.         |
| Capacity Loss MW        | real number      | MW            | Total component capacity for the outaged components.                             |
| Capacity Betti 0        | real number      | dimensionless | First Betti number, computed using capacity as the edge weight.                  |
| Capacity Betti 1        | real number      | dimensionless | Second Betti number, computed using capacity as the edge weight.                 |
| Capacity Bottleneck 0   | real number      | dimensionless | First bottleneck distance, computed using capacity as the edge weight.           |
| Capacity Bottleneck 1   | real number      | dimensionless | Second bottleneck distance, computed using capacity as the edge weight.          |
| Flow Loss MW            | real number      | MW            | Total amount of base flow that was in the outaged components.                    |
| Flow Betti 0            | real number      | dimensionless | First Betti number, computed using base flow as the edge weight.                 |
| Flow Betti 1            | real number      | dimensionless | Second Betti number, computed using base flow as the edge weight.                |
| Flow Bottleneck 0       | real number      | dimensionless | First bottleneck distance, computed using base flow as the edge weight.          |
| Flow Bottleneck 1       | real number      | dimensionless | Second bottleneck distance, computed using base flow as the edge weight.         |
| Residue Loss MW         | real number      | MW            | Total residual capacity that was in the outaged components.                      |
| Residue Betti 0         | real number      | dimensionless | First Betti number, computed using residual capacity as the edge weight.         |
| Residue Betti 1         | real number      | dimensionless | Second Betti number, computed using residual capacity as the edge weight.        |
| Residue Bottleneck 0    | real number      | dimensionless | First bottleneck distance, computed using residual capacity as the edge weight.  |
| Residue Bottleneck 1    | real number      | dimensionless | Second bottleneck distance, computed using residual capacity as the edge weight. |
| Unweighted Loss         | real number      | dimensionless | Total number of components outaged.                                              |
| Unweighted Betti 0      | real number      | dimensionless | First Betti number, computed using unweighted edges.                             |
| Unweighted Betti 1      | real number      | dimensionless | Second Betti number, computed using unweighted edges.                            |
| Unweighted Bottleneck 0 | real number      | dimensionless | First bottleneck distance, computed using unweighted edges.                      |
| Unweighted Bottleneck 1 | real number      | dimensionless | Second bottleneck distance, computed using unweighted edges.                     |
