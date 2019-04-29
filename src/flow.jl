using ConfParser
using GaussianMixtures

"generate and storing model from training data"
function modelflow(conf::ConfParse)::GMM
    data = traindata(conf)

    gmm = genmodel(conf, data)

    savemodel(conf, gmm)

    #cleanup!(data)     # for some reason doesn't remove variable from memory
    data = nothing
    GC.gc()

    gmm
end

"maps input data by using generated model"
function mapflow(conf::ConfParse)::SharedArray{Int16}
    gmm = loadmodel(conf)

    X = mapdata(conf)

    @info "Preparing shared array from loaded source data"
    @time S = convert(SharedArray, X)

    #cleanup!(X)        # for some reason doesn't remove variable from memory
    X = nothing
    GC.gc()

    res = mapcluster(S, gmm)

    savemap(conf, res)
    mapstats(conf, res)

    res
end

"main processing flow"
function mainflow(conf::ConfParse)::Union{GMM,SharedArray{Int16}}
    flow = retrieve(conf, "processing", "type")

    if flow == "all"
        modelflow(conf)
        mapflow(conf)
    elseif flow == "gmm"
        modelflow(conf)
    elseif flow == "map"
        mapflow(conf)
    else
        error("Unknown processing type $flow")
    end
end
