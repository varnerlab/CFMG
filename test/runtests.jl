using CFMG
using Test

include("test1.jl")

# write a default test -
function default_cfmg_test()
    return true
end

# setup the test set for the code generator -
@testset "cfmg_test_set" begin
    @test default_cfmg_test() == true
    # @test CFMG_test1() == true
end

# @testset "example_model" begin
#     @test CFMG_test1() == true
# end

@time begin CFMG_test1() end
