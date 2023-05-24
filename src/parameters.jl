module parameters

struct parameter_data
  inst_name::String
  form::String
  solver::String
  method::String
  maxtime::Int
  tolgap::Float64
  maxnodes::Int
end

export parameter_data, read_parameters

function read_parameters(ARGS)

  ### Set standard values for the parameters ###
  inst_name = "instances/K11.dat"
  form = "kclusters"
  solver = "cplex"
  method = "mip"
  maxtime = 3600
  tolgap = 1e-6
  maxnodes = 10000000.0

  ### Read the parameters and setvalues whenever provided ###
  for param in 1:length(ARGS)
    if ARGS[param] == "--inst"
      inst_name = ARGS[param+1]
      param += 1
    elseif ARGS[param] == "--form"
      form = ARGS[param+1]
      param += 1
    elseif ARGS[param] == "--solver"
      solver = ARGS[param+1]
      param += 1
    elseif ARGS[param] == "--method"
      method = ARGS[param+1]
      param += 1
    elseif ARGS[param] == "--maxtime"
      maxtime = parse(Int,ARGS[param+1])
      param += 1
    elseif ARGS[param] == "--tolgap"
      tolgap = parse(Float64,ARGS[param+1])
      param += 1
    elseif ARGS[param] == "--maxnodes"
      maxnodes = parse(Float64,ARGS[param+1])
    end
  end

  params = parameter_data(
    inst_name,
    form,
    solver,
    method,
    maxtime,
    tolgap,
    maxnodes
  )

  return params

end 

end
