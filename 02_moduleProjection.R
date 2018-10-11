#2) Module flow projection

#libraries
library(igraph)
library(data.table)
library(tidyverse)
library(dplyr)
source("MapFlow_2.R")

#Make projection to the community space
mappy = mapflow(g, modules)

#export 
write.graph(mappy, "results/mappy.gml", "gml")
