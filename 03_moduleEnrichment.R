#3) Module enrichment and bipartite network

library(HTSanalyzeR)
library(tidyverse)
library(plyr)
library(data.table)
library(igraph)
load("GOs_and_pathways.RData")

#set variables
pvalue_threshold = 0.05

#cases
#get list of communities 
l_comm_cases = communities(modules_cases)
#in case we are provided with communities already identified for each vertex
## tmp_df = get.data.frame(g, "vertices")
## tmp_l  = lapply(X = unique(tmp_df$infomap), FUN = function(i){
##   filter(tmp_df, infomap==i)$name
## })

#Enrich

enrichment_list_cases = parallel::mclapply(X = seq_along(l_comm_cases), mc.cores = 4, FUN = function(i){
#enrichment_list_cases = lapply(X = seq_along(l_comm_cases), FUN = function(i){
  
  nomen = names(l_comm_cases)[i]
  
  my_enrichment = HTSanalyzeR::multiHyperGeoTest(collectionOfGeneSets = LIST_GO, 
                                                 universe = V(g_cases)$name, 
                                                 hits = l_comm_cases[[i]], 
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


#calculate adjusted pvalue for all communities
enrichment_df_cases$Adjusted.Pvalue2 = p.adjust(enrichment_df_cases$Pvalue, method = "BH")

write.table(x = enrichment_df_cases, 
            file = "results/enrichment_df_cases.txt", 
            row.names = FALSE, 
            col.names = TRUE, 
            sep = "\t", 
            quote = FALSE)

#which(enrichment_df_cases$Adjusted.Pvalue<0.05)
#which(enrichment_df_cases$Adjusted.Pvalue2<0.05)


#bipartite graph
b_cases = graph_from_data_frame(enrichment_df_cases, directed = FALSE)
b_cases = delete.edges(graph = b_cases, 
                       edges = E(b_cases)[Adjusted.Pvalue2>pvalue_threshold]
                       )

V(b_cases)$type = TRUE
V(b_cases)$type[grep(pattern = "GO_", x = V(b_cases)$name)] = FALSE

#add a value that tells us if the comm shows enrichment or not
#if it has neighbors, it enriches. Else, no
V(b_cases)$enrich = degree(b_cases)
V(b_cases)$enrich = ifelse(V(b_cases)$enrich==0, "NO", "YES")

#write out bipartite
write.graph(b_cases, file = "results/bipartite_cases.gml", "gml")

#remove big enrichment list from memory
rm(enrichment_df_cases)

#4) Enrichment projection



#projection
bp_cases = bipartite_projection(graph = b_cases, which = TRUE)

write.graph(graph = bp_cases, file = "results/bp_cases.gml", "gml")

#cntrl
#get list of communities 
l_comm_cntrl = communities(modules_cntrl)
#in case we are provided with communities already identified for each vertex
## tmp_df = get.data.frame(g, "vertices")
## tmp_l  = lapply(X = unique(tmp_df$infomap), FUN = function(i){
##   filter(tmp_df, infomap==i)$name
## })

#Enrich

enrichment_list_cntrl = parallel::mclapply(X = seq_along(l_comm_cntrl), mc.cores = 4, FUN = function(i){
  #enrichment_list_cntrl = lapply(X = seq_along(l_comm_cntrl), FUN = function(i){
  
  nomen = names(l_comm_cntrl)[i]
  
  my_enrichment = HTSanalyzeR::multiHyperGeoTest(collectionOfGeneSets = LIST_GO, 
                                                 universe = V(g_cntrl)$name, 
                                                 hits = l_comm_cntrl[[i]], 
                                                 minGeneSetSize = 1, 
                                                 pAdjustMethod = "BH", 
                                                 verbose = TRUE
  )
  print(nrow(my_enrichment))
  my_2 = tibble::rownames_to_column(as.data.frame(my_enrichment))#%>%filter(Adjusted.Pvalue<10)
  my_3 = cbind(comm = nomen, my_2)
  return(my_3)
  
})

enrichment_df_cntrl = ldply(enrichment_list_cntrl, data.frame)


#calculate adjusted pvalue for all communities
enrichment_df_cntrl$Adjusted.Pvalue2 = p.adjust(enrichment_df_cntrl$Pvalue, method = "BH")

write.table(x = enrichment_df_cntrl, 
            file = "results/enrichment_df_cntrl.txt", 
            row.names = FALSE, 
            col.names = TRUE, 
            sep = "\t", 
            quote = FALSE)
#which(enrichment_df_cntrl$Adjusted.Pvalue<0.05)
#which(enrichment_df_cntrl$Adjusted.Pvalue2<0.05)


#bipartite graph
b_cntrl = graph_from_data_frame(enrichment_df_cntrl, directed = FALSE)
b_cntrl = delete.edges(graph = b_cntrl, 
                       edges = E(b_cntrl)[Adjusted.Pvalue2>pvalue_threshold]
)

V(b_cntrl)$type = TRUE
V(b_cntrl)$type[grep(pattern = "GO_", x = V(b_cntrl)$name)] = FALSE

#add a value that tells us if the comm shows enrichment or not
#if it has neighbors, it enriches. Else, no
V(b_cntrl)$enrich = degree(b_cntrl)
V(b_cntrl)$enrich = ifelse(V(b_cntrl)$enrich==0, "NO", "YES")

#write out bipartite
write.graph(b_cntrl, file = "results/bipartite_cntrl.gml", "gml")

#remove big enrichment list from memory
rm(enrichment_df_cntrl)
#4) Enrichment projection



#projection
bp_cntrl = bipartite_projection(graph = b_cntrl, which = TRUE)

write.graph(graph = bp_cntrl, file = "results/bp_cntrl.gml", "gml")

