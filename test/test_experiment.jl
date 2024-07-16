@testset "experiments.jl" begin
    # basic example
    ex = Experiment(
        "test",
        (x...) -> println(x...),
        rand,
        Dict{Any,Any}("x!" => [10, 20, 30]),
        Dict{Any,Any}("solver!" => ["cat", "dog"]),
    )
    tsts = tests!(ex)
    @test length(tsts) == 6
    @test first(tsts).instance_params["x"] == 10
    @test last(tsts).solver_params["solver"] == "dog"
    # test seed
    ex = Experiment(
        "test",
        (x...) -> println(x...),
        rand,
        Dict{Any,Any}("x!" => [10, 20, 30], "seed" => 0),
        Dict{Any,Any}("solver!" => ["cat", "dog", "monkey"], "tt!" => [1, 3]),
    )
    tsts = tests!(ex)
    @test length(tsts) == 18
    for t in tsts
    end
    @test ex.instance_params["seed"] == 3
    # test copy
    ex = Experiment(
        "test",
        (x...) -> println(x...),
        rand,
        Dict{Any,Any}("x!" => [10, 20, 30], "seed" => 0),
        Dict{Any,Any}("solver!" => ["cat", "dog", "monkey"], "tt!" => [1, 3]),
    )
    tsts = tests(ex)
    @test length(tsts) == 18
    @test tsts[1].instance_params["seed"] == 1
    @test tsts[end].instance_params["seed"] == 3
end
