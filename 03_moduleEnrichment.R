#3) Module enrichment and bipartite network

library(HTSanalyzeR)
library(tidyverse)
library(plyr)
library(data.table)
library(igraph)
load("GOs_and_pathways.RData")
#get list of communities 
l_comm_cases = communities(modules_cases)
#in case we are provided with communities already identified for each vertex
## tmp_df = get.data.frame(g, "vertices")
## tmp_l  = lapply(X = unique(tmp_df$infomap), FUN = function(i){
##   filter(tmp_df, infomap==i)$name
## })

#Enrich


enrichment_list_cases = lapply(X = seq_along(l_comm_cases), FUN = function(i){
  
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

enrichment_df_cases = ldply(enrichment_list_cases, data.frame)
enrichment_df_cases$Adjusted.Pvalue2 = p.adjust(enrichment_df_cases$Pvalue, method = "BH")
#which(enrichment_df_cases$Adjusted.Pvalue<0.05)
#which(enrichment_df_cases$Adjusted.Pvalue2<0.05)


#4) Enrichment projection

b_cases = graph_from_data_frame(enrichment_df_cases, directed = FALSE)
b_cases = delete.edges(graph = b_cases, edges = E(b_cases)[Adjusted.Pvalue2>0.05])

V(b_cases)$type = TRUE
V(b_cases)$type[grep(pattern = "GO_", x = V(b_cases)$name)] = FALSE
V(b_cases)$type
bp_cases = bipartite_projection(graph = b_cases, which = TRUE)
V(bp_cases)$name
E(bp_cases)$weight
components(bp_cases)
bp_cases
plot(bp_cases)

write.graph(graph = bp_cases, file = "results/bp_cases.gml", "gml")

