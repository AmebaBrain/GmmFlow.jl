@info "Parsing config file"
using ConfParser
conf = ConfParse("gmm.ini")
parse_conf!(conf)

@info "Triggering execution flow"
using Distributed
using GmmFlow
addworkers(conf)
@everywhere using GmmFlow, SharedArrays, JLD2, LinearAlgebra, GaussianMixtures

mainflow(conf)