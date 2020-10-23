using CFMG, Test
using Pkg

if (in("JLD", keys(Pkg.installed())) == false)
  Pkg.add("JLD")
end

if (in("Statistics", keys(Pkg.installed())) == false)
  Pkg.add("Statistics")
end

using JLD

function CFMG_test1()
  # try
    # generate model with CFMG
    generate_default_project("./default1")
    cp("config/Network.vff", "./default1/Network.vff", force=true)
    make_julia_model("./default1/Network.vff", "./default2")

    # run the model
    println("change pwd to make model run normal")
    println(pwd())
    cd("./default2/")
    println(pwd())
    println("run the model")
    print("__DIR__ at test1.jl ")
    println(@__DIR__)
    include("default2/Static.jl")  # this is interesting!

    # verify simulation results
    println("load std result")
    test1_result_path = normpath(joinpath(@__DIR__, "test1_result.jld"))
    test1_result = load(test1_result_path)["soln_std"]
    println(static_soln_object)
    @assert test1_result.exit_flag == static_soln_object.exit_flag "check exit_flag"
    @assert test1_result.status_flag == static_soln_object.status_flag "check status_flag"
    @assert norm(test1_result.objective_value - static_soln_object.objective_value) < 1e-8 "Check objective_value"
    @assert norm(test1_result.flux - static_soln_object.flux) < 1e-8 "Check flux"

    # remove generated files
    # sleep(60)
    cd("../")
    rm("./default1", recursive=true)
    rm("./default2", recursive=true)
    # @assert 0 == 1
    # println(pwd())
    # default1 = normpath(joinpath(@__DIR__, "default1/"))
    # default2 = normpath(joinpath(@__DIR__, "default2/"))
    # rm(default1, recursive=true)
    # rm(default2, recursive=true)

  # catch e
  #   return false
  # end

  return true
end

# CFMG_test1()
