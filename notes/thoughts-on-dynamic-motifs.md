# Dynamic Motifs for Network Degradation and Restoration (12 May 2019)


## Goal

Extend the network motif concept to the dynamics of degration and restoration of complex networks.


## Basic Idea

Consider a time-dependent network $G(t)$ as a fixed set of nodes and a dynamic set of links between the nodes: i.e., the connectivity between the nodes may change over time as links are removed (degraded) or added (restored). The removal and addition of links defines a d
iscrete sequence of times where the network configuration has changed between adjacent time configurations: $G(t_i)$ for $i \in \{1,\ldots,n\}$. Also assume that each node can be colored as "operative" or "inoperative". (In an electric power system, for example, customer
 demand is met at operative nodes, but not at inoperative ones.)

Represent this time-dependent network as a static, multi-layer network consisting of the subnetworks $G(t_i)$ where $G(t_i)$ and $G(t_{i+1})$ are connected by temporal, *directed* links from each node at time $t_i$ to the same node at time $t_{i+1}$. We color the links i
n each $G(t_i)$ as "spatial" and the links between the $G(t_i)$ as "temporal". (Note that the links within the $G(t_i)$ are undirected, but the links between them are directed.) We can now apply the previously developed theory of network motifs to these multilayer networ
ks, but making a distinction between the temporal or spatial color of the links when defining the motifs: namely, two subnetworks belong to the same motif if and only if they have the same pattern of directedness and coloring for their links.

At this level of abstraction, all of the methods of motif analysis can be applied to these dynamic networks that involve both degradation of links and restoration of them: here the motifs that include temporal links represent degradation or restoration processes.


## Application to Electric Power Systems

We hypothesize that, in the case of electric power systems, the concentration of dynamic motifs relates to the health of the network during degradation and restoration: particular motifs may correlate more severe degradation or more effective restoration. In order to study this, we propose to execute time-dependent power-system simulations (optimal power flow with dispatch) in the presence of degradation (e.g., component failure or

attack) and restoration for statistically-design computer experiments where failure/attack patterns and restoration strategies are varied. The results of each simulation will color the nodes as operative or inoperative according to whether customer load is served or shed at the node, respectively.

We will employ local and global topological, graph-theoretic, and statistical techniques to understand the relationship between the concentration of motifs of different types and the system’s ability to serve customer load. In particular, the coloring of nodes according to their operativeness allows us enables detailed study of the relationship between dynamic motifs and system health.
