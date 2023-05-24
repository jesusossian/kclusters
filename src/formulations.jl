# kclustersForm

module formulations

using JuMP
using Gurobi
using CPLEX
using data
using parameters

mutable struct stdFormVars
  x
  y
end

export kclustersForm, stdFormVars

# function to model the problem 
function kclustersForm(inst::instance_data, params::parameter_data)

  #outputfile = open(resultsPL, "w")

  N = inst.N
  K = inst.K
  Mk = inst.Mk
  S = inst.S

  ### select solver and define parameters ###
  if params.solver == "gurobi"
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model,"TimeLimit",params.maxtime) # time limit
    set_optimizer_attribute(model,"MIPGap",params.tolgap) # relative MIP optimality gap
    #set_optimizer_attribute(model,"NodeLimit",params.maxnodes) # MIP node limit
    #set_optimizer_attribute(model,"NodeMethod",0) # method used to solve MIP node relaxations
    #set_optimizer_attribute(model,"Method",-1) # method used in root node
    set_optimizer_attribute(model,"Threads",1) # number of threads
    set_optimizer_attribute(model,"SolutionLimit", 1) # first viable solution
    #set_optimizer_attribute(model,"Presolve",0)
    #set_optimizer_attribute(model,"Cuts", 0) # Global cut aggressiveness setting.
  elseif params.solver == "cplex"
    model = Model(CPLEX.Optimizer)
    set_optimizer_attribute(model,"CPX_PARAM_TILIM",params.maxtime) # time limit
    set_optimizer_attribute(model,"CPX_PARAM_EPGAP",params.tolgap) # relative MIP optimality gap
    #set_optimizer_attribute(model,"CPX_PARAM_LPMETHOD ",0) # method used in root node
    #set_optimizer_attribute(model,"CPX_PARAM_NODELIM",params.maxnodes) # MIP node limit
    set_optimizer_attribute(model,"CPX_PARAM_THREADS",1) # number of threads 
    #set_optimizer_attribute(model,"CPXPARAM_Benders_Strategy",3) # 3 full   
  else
    println("No solver selected")
    return 0
  end
  
  #set_silent(model)
  
  @variable(model, x[1:N, 1:K] >= 0, Bin)
  @variable(model, 0 <= y[1:N,1:N,1:K] <= 1)
  
  @objective(model, Max, sum(S[i,j]*y[i,j,k] for i in 1:(N-1), j in i+1:N, k in 1:K))
  
  @constraint(model, constraint1[i in 1:N, j in i+1:N, k in 1:K], y[i,j,k]-x[i,k]-x[j,k]+1 >= 0)
  @constraint(model, constraint2[i in 1:N, j in i+1:N, k in 1:K], y[i,j,k]-x[i,k] <= 0)
  @constraint(model, constraint3[i in 1:N, j in i+1:N, k in 1:K], y[i,j,k]-x[j,k] <= 0)
  @constraint(model, constraint4[i in 1:N], sum(x[i,k] for k in 1:K) <= 1)
  @constraint(model, constraint5[k in 1:K], sum(x[i,k] for i in 1:N) == Mk)
  @constraint(model, constraint6[j in 1:N, k in 1:K], sum(y[i,j,k] for i in 1:j-1) + sum(y[j,i,k] for i in j+1:N) == (Mk-1)*x[j,k])

  if params.method == "lp"
    relax_integrality(model)
  end

  # write_to_file(model,"kcluster.lp")

  ### solving the problem ###
  optimize!(model)
  
  # println("solucoes viavel = ", result_count(model))

  opt = 0
  if termination_status(model) == MOI.OPTIMAL    
    println("status = ", termination_status(model))
    opt = 1
  else
    println("status = ", termination_status(model))
  end
    
  ### get solutions ###
  
  if params.method == "mip"
    bbound = objective_bound(model)
    nodes = node_count(model)
    gap = MOI.get(model, MOI.RelativeGap())
  end
  bsol = objective_value(model)
  time = solve_time(model)

  ### print solutions ###
  open("saida.txt","a") do f
    if params.method == "mip"
      write(f,"$(params.inst_name);$(params.form);$(params.method);$(bbound);$(bsol);$(gap);$(time);$(nodes);$(opt)\n")
    else
      write(f,"$(params.inst_name);$(params.form);$(params.method);$(bestsol);$(time)\n")
    end
  end

#  println(outputfile,"Optimal Solution:")
#  for i in 1:N
#    for k in 1:K
#      if x[i,k] != 0.0
#        println(outputfile,"x[$i,$k] = ", JuMP.value(x[i,k]))
#      end
#    end
#  end

#  for i in 1:N
#    for j in i+1:N
#      for k in 1:K
#        if y[i,j,k] != 0.0
#          println(outputfile,"y[$i,$j,$k] = ", JuMP.value(y[i,j,k]))
#        end
#      end
#    end
#  end
#  close(outputfile)

end

end
