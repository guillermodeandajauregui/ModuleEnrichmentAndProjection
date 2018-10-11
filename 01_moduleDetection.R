#1) Module detection

#libraries
library(igraph)
library(data.table)
library(tidyverse)
#read graph

da.fr = fread("data/Basal_11675.sif")
g = graph_from_data_frame(d = da.fr[,c(1,3,2)], directed = FALSE)
E(g)$weight = E(g)$V2

#detect modules
modules = infomap.community(graph = g, nb.trials = 1000)
#assign module membership to vertices
V(g)$infomap = membership(modules)

write.table(x = get.data.frame(x = g, "vertices"), 
            file = "results/dict_commInfomap.txt", 
            row.names = FALSE, 
            col.names = TRUE, 
            sep = "\t", 
            quote = FALSE)
