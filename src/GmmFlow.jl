module GmmFlow

include("utils.jl")
include("data.jl")
include("model.jl")

export
    # data.jl
    traindata, mapdata,
    # utils.jl
    getworkers, addworkers, # cleanup!,
    # model.jl
    modelname, genmodel, savemodel,
    loadmodel, mapcluster, savemap,
    mapstats

end