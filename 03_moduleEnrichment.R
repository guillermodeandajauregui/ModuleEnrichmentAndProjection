#3) Module enrichment and bipartite network

library(HTSanalyzeR)
library(tidyverse)
library(plyr)
library(data.table)
library(igraph)
load("GOs_and_pathways.RData")
#get list of communities 
l_comm = communities(modules)
#in case we are provided with communities already identified for each vertex
## tmp_df = get.data.frame(g, "vertices")
## tmp_l  = lapply(X = unique(tmp_df$infomap), FUN = function(i){
##   filter(tmp_df, infomap==i)$name
## })

#Enrich


enrichment_list = lapply(X = seq_along(l_comm), FUN = function(i){
  
  nomen = names(l_comm)[i]
  
  my_enrichment = HTSanalyzeR::multiHyperGeoTest(collectionOfGeneSets = LIST_GO, 
                                                 universe = V(g)$name, 
                                                 hits = l_comm[[i]], 
                                                 minGeneSetSize = 1, 
                                                 pAdjustMethod = "BH", 
                                                 verbose = TRUE
  )
  print(nrow(my_enrichment))
  my_2 = tibble::rownames_to_column(as.data.frame(my_enrichment))#%>%filter(Adjusted.Pvalue<10)
  my_3 = cbind(comm = nomen, my_2)
  return(my_3)
  
})

enrichment_df = ldply(enrichment_list, data.frame)
enrichment_df$Adjusted.Pvalue2 = p.adjust(enrichment_df$Pvalue, method = "BH")
which(enrichment_df$Adjusted.Pvalue<0.05)
which(enrichment_df$Adjusted.Pvalue2<0.05)


#4) Enrichment projection

b = graph_from_data_frame(enrichment_df, directed = FALSE)
b = delete.edges(graph = b, edges = E(b)[Adjusted.Pvalue2>0.05])

V(b)$type = TRUE
V(b)$type[grep(pattern = "GO_", x = V(b)$name)] = FALSE
V(b)$type
bp = bipartite_projection(graph = b, which = TRUE)
V(bp)$name
E(bp)$weight
components(bp)
bp
plot(bp)

write.graph(graph = bp, file = "results/bp.gml", "gml")

