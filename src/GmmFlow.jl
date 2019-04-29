module GmmFlow

include("utils.jl")
include("data.jl")
include("model.jl")
include("flow.jl")

export
    # data.jl
    traindata, mapdata,
    # utils.jl
    getworkers, addworkers, # cleanup!,
    # model.jl
    modelname, genmodel, savemodel,
    loadmodel, mapcluster, savemap,
    mapstats,
    # flow.jl
    modelflow,
    mapflow,
    mainflow
end