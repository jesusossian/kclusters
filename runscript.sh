#!/bin/bash

method_=mip # lp or mip
prob_=kclusters
form_=kclusters
solver_=cplex
maxtime_=3600

mkdir -p result
mkdir -p report

for inst_ in K11 K12 K13 K14
do
	julia main.jl \
	--inst instances/${inst_}.dat \
	--form ${form_} \
	--method ${method_} \
	--solver ${solver_} \
	--maxtime ${maxtime_} \
	>> report/${inst_}.txt
done
mv saida.txt result/${prob_}.txt

