using ConfParser
using DelimitedFiles
using MAT
using GaussianMixtures:Data

"read train data into 2d array"
function traindata(conf::ConfParse)::Data
    @info "Loading source data"
    @time X = _getdata(conf, "train_data_file", "train_attr_name")

    @info "!!!Debug message in traindata!!!"
    @info "Converting them to BigData"
    @time data = _splitdata(X, getworkers(conf))

    X = nothing
    GC.gc()
    @debug "Cleaning up initial array $(size(X))"

    data
end

"read mapping data into 2d array"
function mapdata(conf::ConfParse)::Array{Float64,2}
    @info "Loading map data"
    _getdata(conf, "map_data_file", "map_attr_name")
end

"read data from Matlab file"
function _readmat(filename::String, dataname::String)::Array{Float64,2}
    matopen(filename) do file
        read(file, dataname)
    end
end

"define file type by it's extension"
function _filetype(filename::String)::Symbol
    Symbol(SubString(filename, findlast(".", filename).start + 1))
end

"read data into 2d array"
function _getdata(conf::ConfParse, filename::String, attrname::String)::Array{Float64,2}
    path = retrieve(conf, "environment", "path")
    file = retrieve(conf, "environment", filename)

    type = _filetype(path * file)

    if type == :csv
        readdlm(path * file, ',')
    elseif type == :mat
        attr = retrieve(conf, "mat", attrname)
        _readmat(path * file, attr)
    end
end

"convert single data array into GaussianMixtures.Data array"
function _splitdata(arr::Array{Float64,2}, procs::Int)::Data
    step = convert(Int, floor(length(arr[:,1])/procs))
    res = Array{Array{Float64,2}}(undef, procs)

    for i=1:procs
        if i != procs
            res[i] = arr[(1+(i-1)*step):i*step,:]
        else
            res[i] = arr[(1+(i-1)*step):end,:]
        end
    end

    Data(res)
end
