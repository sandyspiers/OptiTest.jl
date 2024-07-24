@testset "experiments.jl" begin
    @testset "distributed" begin
        # sleeper helper fn
        function sleep_id(test_dict)
            sleep(0.25)
            test_dict["id"] = myid()
            return test_dict
        end

        # simple experiment
        ex = Dict("x!" => 1:9, "save_results" => false)

        # check it runs without any workers (ie single threaded)
        rmprocs(workers())
        df = run(ex, sleep_id)
        @test length(df.id) == 9
        @test all(df.id .== 1)

        # add 3 workers
        addprocs(3)
        @everywhere import OptiTest
        df = run(ex, sleep_id)
        @test length(df.id) == 9
        @test minimum(df.id) < maximum(df.id)
        rmprocs(workers())

        # test it works for singles
        rmprocs(workers())
        ex = Dict("x" => 9, "save_results" => false)
        df = run(ex, sleep_id)
        @test length(df.id) == 1
        @test all(df.id .== 1)
    end

    @testset "helpers" begin
        rmprocs(workers())
        function solve(dict)
            println("Hello I'm $(myid())")
            dict["id"] = myid()
            return dict
        end
        rm("test_write"; force=true, recursive=true)
        dir =
            ex = Dict(
                "x!" => 1:9,
                "name" => "test",
                "dir" => "test_write",
                "save_setup" => true,
                "save_log" => true,
                "save_results" => true,
            )
        run(ex, solve)
        files = readdir("test_write")
        @test "test.json" ∈ files
        @test "test.log" ∈ files
        @test "test.csv" ∈ files
    end
end
