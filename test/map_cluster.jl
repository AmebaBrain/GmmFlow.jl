using Distributed

addworkers(conf)

@everywhere using GmmFlow, SharedArrays, JLD2, LinearAlgebra, GaussianMixtures

gmm = loadmodel(conf)

X = mapdata(conf)

@info "Preparing shared array from loaded source data"
@time S = convert(SharedArray, X)

#cleanup!(X)
X = nothing
GC.gc()

res = mapcluster(S, gmm)

savemap(conf, res)
mapstats(conf, res)