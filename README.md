# GmmFlow.jl
Configurable wrapper around [GaussianMixtures.jl](https://github.com/davidavdav/GaussianMixtures.jl)

## Installation
Install by url `pkg> add git@github.com:AmebaBrain/GmmFlow.jl.git`

## Usage
* edit [gmm.ini](https://github.com/AmebaBrain/GmmFlow.jl/blob/master/test/gmm.ini) file according to your needs
* execute [run.jl](https://github.com/AmebaBrain/GmmFlow.jl/blob/master/test/run.jl) from julia interpreter

## Features
* support `.csv` and `.mat` Matlab source data files
* auto-generating and saving model file via [JLD2](https://github.com/JuliaIO/JLD2.jl) and results mapping file as `.csv`
* configurable parallelization degree
* configurable flow
  * generate model only
  * map cluster by existing model
  * generate model and perform mapping
* support for default and split models
