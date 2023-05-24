module data

#using Statistics
#using Random

struct instance_data
  N::Int
  K::Int
  Mk::Int
  S
end

export instance_data, read_data

# function for read and print instance
function read_data(instance)

  file = open(instance)
  fileText = read(file, String)
  tokens = split(fileText) 

#  outputfile = open(results, "w")

  aux = 1
  #read the problem dimension
  N = parse(Int,tokens[aux])
  #println(N)
  aux += 1
  K = parse(Int,tokens[aux])
  #println(K)
  aux += 1
  Mk = parse(Int,tokens[aux])
  #println(Mk)
  S = zeros(Float64,N,N)
  
  for i in 1:N-1
    for j in i+1:N
      aux += 1
      S[i,j] = parse(Float64,tokens[aux])
    end 
  end

#  println(outputfile,"$N")
#  println(outputfile,"$K")
#  println(outputfile,"$Mk")
#  println(outputfile)

#  for i in 1:N-1
#    for j in i+1:N
#      print(outputfile,"$(S[i,j]) ")
#    end
#    println(outputfile)
#  end

#  println(outputfile)
  
  close(file)
  
#  close(outputfile)
  
  inst = instance_data(N,K,Mk,S)
  
  return inst
  
end

end
