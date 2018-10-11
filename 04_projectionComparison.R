#5) Network comparison

#get matrices from graphs
xxx = as.matrix(get.adjacency(mappy))
xxx[1:10,1:10]
yyy = as.matrix(get.adjacency(bp))
yyy[1:10,1:10]

#matrices may be unordered. As commnames are numbers, just sort
xxx = xxx[order(as.numeric(rownames(xxx))),
          order(as.numeric(colnames(xxx)))
          ]
xxx[1:10,1:10]
yyy = yyy[order(as.numeric(rownames(yyy))),
          order(as.numeric(colnames(yyy)))
          ]
yyy[1:10,1:10]

#to find which links are in both networks, multiply both matrices
#if there is a link in ModuleProjection and EnrichmentProjection, 
#product will be != 0
zzz = xxx*yyy

mappy
bp

which(degree(mappy)==max(degree(mappy)))
which(degree(bp)==max(degree(bp)))

l_comm[7]
l_comm[227]

head_of(graph = mappy, es = E(mappy))$name



sort(which(xxx!=0))
sort(which(yyy!=0))

any(which(xxx!=0)%in%which(yyy!=0))
which(which(xxx!=0)%in%which(yyy!=0), arr.ind = TRUE)

zzz = xxx*yyy
which(zzz!=0, arr.ind = TRUE)

E(mappy)[234%--%134]
E(mappy)[134%--%293]
V(mappy)[name=="293"]
neighbors(graph = mappy, v = "293")
neighbors(graph = bp, v = "293")

l_comm["293"]
l_comm["134"]
