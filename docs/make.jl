import Pkg; Pkg.add("Documenter")
push!(LOAD_PATH,"../src/")
using Documenter  #, lcmsim

makedocs(sitename="LCMsim"
         )