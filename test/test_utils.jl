@testset "utils.jl" begin
    # test all keys method
    d = Dict("x" => nothing, "y" => 5)
    @test all_keys(d) == [("x",), ("y",)]
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test all_keys(d) == [("x",), ("y", "z")]

    # test rec get
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test rec_get(d, ("y", "z")) == 5

    # test rec set
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    rec_set!(d, ("y", "z"), 100)
    @test d["y"]["z"] == 100
end
