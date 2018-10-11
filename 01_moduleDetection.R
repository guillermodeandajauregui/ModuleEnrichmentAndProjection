#1) Module detection

#libraries
library(igraph)
library(data.table)
library(tidyverse)
#read graph

cases = fread("data/Basal_11675.sif")
cntrl = fread("data/Normal_11675.sif")

g_cases = graph_from_data_frame(d = cases[,c(1,3,2)], directed = FALSE)
E(g_cases)$weight = E(g_cases)$V2

#detect modules
modules_cases = infomap.community(graph = g_cases, nb.trials = 1000)
#assign module membership to vertices
V(g_cases)$infomap = membership(modules_cases)

write.table(x = get.data.frame(x = g_cases, "vertices"), 
            file = "results/dict_commInfomap_cases.txt", 
            row.names = FALSE, 
            col.names = TRUE, 
            sep = "\t", 
            quote = FALSE)
