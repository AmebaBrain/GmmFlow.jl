using ConfParser
using GaussianMixtures
using Distributed
using SharedArrays
using JLD2, FileIO, LinearAlgebra   # model serialization

function genmodel(conf::ConfParse, data::Data)::GMM
    classes = parse(Int, retrieve(conf, "gmm", "classes"))
    km_iter = parse(Int, retrieve(conf, "gmm", "km_iter"))
    em_iter = parse(Int, retrieve(conf, "gmm", "em_iter"))
    final_iter = parse(Int, retrieve(conf, "gmm", "final_iter"))
    model_type = retrieve(conf, "gmm", "model_type")

    local gmm::GMM

    @info "Start creating $model_type model..."
    if model_type == "default"
        @time gmm = GMM(classes, data, kind=:full, nInit=km_iter, nIter=em_iter)
    elseif model_type == "split"
        @time gmm = GMM(classes, data, method=:split, kind=:full, nIter=em_iter, nFinal=final_iter)
    else
        error("Unknown model type $model_type")
    end

    gmm
end

function modelname(conf::ConfParse)
    path = retrieve(conf, "environment", "path")
    model_file = retrieve(conf, "environment", "model_file")

    if model_file == "<train_data_file>-<model_type>-<classes>.jld2"
        filename = retrieve(conf, "environment", "train_data_file")
        model_type = retrieve(conf, "gmm", "model_type")
        classes = parse(Int, retrieve(conf, "gmm", "classes"))

        filename = SubString(filename, 1, findlast(".", filename).start - 1)

        model_file = filename * '-' * model_type * '-' * string(classes) * ".jld2"
    end

    path * model_file
end

function savemodel(conf::ConfParse, gmm::GMM)
    @info "Saving model"
    @save modelname(conf) gmm
end

function loadmodel(conf::ConfParse)
    @info "Loading model"
    model_name = modelname(conf)
    let m2 = model_name
        @time @everywhere @load $m2 gmm
    end
    @load model_name gmm
    gmm
end

function mapcluster(arr::SharedArray{Float64,2}, gmm::GMM)::SharedArray{Int16}
    @info "Initializing results array"
    @time res = SharedArray{Int16}(size(arr,1))

    @info "Start calculations"
    # we have to calculate per single input vector for memory saving
    # for each input vector "gmmposterior" returns another Float64 vector
    # with number of elements equal to number of clusters
    # for 100 clusters model 10^6 such vectors take 700 Mb of memory
    @time @sync @distributed for i = 1:size(arr,1)
        res[i] = findmax(gmmposterior(gmm, arr[i:i,:])[1][:])[2]
    end

    res
end

function savemap(conf::ConfParse, arr::SharedArray{Int16})
    path = retrieve(conf, "environment", "path")
    res_file = retrieve(conf, "environment", "res_file")

    if res_file == "<map_data_file>-<model_type>-<classes>-map.csv"
        filename = retrieve(conf, "environment", "map_data_file")
        model_type = retrieve(conf, "gmm", "model_type")
        classes = parse(Int, retrieve(conf, "gmm", "classes"))

        filename = SubString(filename, 1, findlast(".", filename).start - 1)

        res_file = filename * '-' * model_type * '-' * string(classes) * "-map.csv"
    end

    @info "Writing results into a file"
    @time writedlm(path * res_file, arr, ',')
end

function mapstats(conf::ConfParse, arr::SharedArray{Int16})
    classes = parse(Int, retrieve(conf, "gmm", "classes"))
    @info "Statistics"
    @info "----------"
    @info "Classes: $classes"
    @info "Minimal class: $(minimum(arr))"
    @info "Maximum class: $(maximum(arr))"
    @info "Vectors: $(length(arr))"
    @info "Mapped: $(length(arr[arr .> 0]))"
    @info "Non Mapped: $(length(arr[arr .== 0]))"
end