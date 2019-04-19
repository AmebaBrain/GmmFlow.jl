using ConfParser
using Distributed

"get number of workers that will be used"
function getworkers(conf::ConfParse)::Int
    workers = retrieve(conf, "calc", "workers")

    if workers == "auto"
        workers_cnt = Sys.CPU_THREADS
    else
        workers_cnt = parse(Int, workers)
    end

    workers_cnt = min(workers_cnt, Sys.CPU_THREADS)
end

"launch workers up to the specified number"
function addworkers(conf::ConfParse)::Int
    workers = getworkers(conf)

    @info "Adding $workers workers"
    if nworkers() == 1
        addprocs(workers)
    else
        addprocs(workers - nworkers())
    end

    workers
end

"cleanup variable from memory - such implementation doesn't work"
function cleanup!(var)
    var = nothing
    GC.gc()
end