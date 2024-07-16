@testset "distributed.jl" begin
    # basic example
    function sleep_id(x...)
        sleep(0.25)
        return myid()
    end
    ex = Experiment(
        "test",
        sleep_id,
        rand,
        Dict{Any,Any}("x!" => [10, 20, 30]),
        Dict{Any,Any}("solver!" => ["cat", "dog"]),
    )
    # remove workers
    rmprocs(workers())
    df = run(ex)
    @test all(df.result .== 1)

    # add 2 more
    addprocs(6)
    @everywhere import OptiTest
    df = run(ex)
    @test minimum(df.result) < maximum(df.result)
    rmprocs(workers())
end
