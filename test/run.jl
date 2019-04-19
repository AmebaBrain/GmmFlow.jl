using ConfParser

conf = ConfParse("gmm.ini")
parse_conf!(conf)

flow = retrieve(conf, "processing", "type")

if flow == "all"
    include("gen_model.jl")
    include("map_cluster.jl")
elseif flow == "gmm"
    include("gen_model.jl")
elseif flow == "map"
    include("map_cluster.jl")
else
    error("Unknown processing type $flow")
end