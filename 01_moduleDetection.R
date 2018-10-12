#1) Module detection

#libraries
library(igraph)
library(data.table)
library(tidyverse)
#read graph

cases = fread("data/Basal_11675.sif")
cntrl = fread("data/Normal_11675.sif")

#cases
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

#cntrl
g_cntrl = graph_from_data_frame(d = cntrl[,c(1,3,2)], directed = FALSE)
E(g_cntrl)$weight = E(g_cntrl)$V2

#detect modules
modules_cntrl = infomap.community(graph = g_cntrl, nb.trials = 1000)
#assign module membership to vertices
V(g_cntrl)$infomap = membership(modules_cntrl)

write.table(x = get.data.frame(x = g_cntrl, "vertices"), 
            file = "results/dict_commInfomap_cntrl.txt", 
            row.names = FALSE, 
            col.names = TRUE, 
            sep = "\t", 
            quote = FALSE)

#write out community structures
saveRDS(object = modules_cntrl, file = "results/modules_cntrl.RDS")
saveRDS(object = modules_cases, file = "results/modules_cases.RDS")
