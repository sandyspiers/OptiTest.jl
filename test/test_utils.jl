@testset "utils.jl" begin
    # test all keys method
    d = Dict("x" => nothing, "y" => 5)
    @test nested_keys(d) == [("x",), ("y",)]
    d = Dict("xx" => nothing, "yy" => Dict("zz" => 5), "aa" => "hello")
    @test nested_keys(d) == [("xx",), ("yy", "zz"), ("aa",)]

    # test nested get
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test nested_get(d, ("y", "z")) == 5
    @test nested_get(d, "x") === nothing

    # test nested set
    d = AnyDict("x" => nothing, "y" => AnyDict("z" => 5))
    nested_set!(d, ("y", "z"), "hello!")
    @test d["y"]["z"] == "hello!"
    nested_set!(d, "x", 50)
    @test d["x"] == 50
end
