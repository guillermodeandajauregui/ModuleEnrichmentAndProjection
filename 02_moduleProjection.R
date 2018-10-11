#2) Module flow projection

#libraries
library(igraph)
library(data.table)
library(tidyverse)
library(dplyr)
source("MapFlow_2.R")

#Make projection to the community space
flow_cases = mapflow(g_cases, modules)

#export 
write.graph(flow_cases, "results/flow_cases.gml", "gml")
