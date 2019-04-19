using Distributed
using GmmFlow

data = traindata(conf)

addworkers(conf)

@everywhere using GaussianMixtures
gmm = genmodel(conf, data)

savemodel(conf, gmm)

#cleanup!(data)
data = nothing
GC.gc()