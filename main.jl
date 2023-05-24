push!(LOAD_PATH, "src/")
# push!(DEPOT_PATH, JULIA_DEPOT_PATH)

#using Pkg
#Pkg.activate(".")
#Pkg.instantiate()
#Pkg.build()

using JuMP
using Gurobi
using CPLEX

import data
import parameters
import formulations

params = parameters.read_parameters(ARGS)

#julia main.jl --inst instancia --form ${form} 

# read instance data
inst = data.read_data(params.inst_name)

if (params.form == "kclusters")
    formulations.kclustersForm(inst, params)
end
