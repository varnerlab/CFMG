using CFMG
using Test

# write a default test -
function default_cfmg_test()
    return true
end

# setup the test set for the code generator -
@testset "cfmg_test_set" begin
    @test default_cfmg_test() == true
end