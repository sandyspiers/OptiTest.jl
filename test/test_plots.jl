@testset "ploter.jl" begin
    # test style guide getters
    sg = Dict(
        (:s => :a) => Dict(:l => "a"),
        (:s => :b) => Dict(:l => "b"),
        (:t => :c) => Dict(:m => "c"),
    )
    @test style_kwargs((:s => :a), sg) == Dict(:l => "a")
    @test style_kwargs((:s => :b), sg) == Dict(:l => "b")
    @test style_kwargs((:t => :c), sg) == Dict(:m => "c")
    @test style_kwargs([(:s => :a), (:t => :c)], sg) == Dict(:l => "a", :m => "c")
    sg = Dict(
        (:s => :a) => Dict(:l => "a"),
        (:s => :b) => Dict(:l => "b"),
        (:t => :c) => Dict(:m => "c", (:s => :a) => Dict(:l => "overwrite!")),
    )
    @test style_kwargs((:s => :a), sg) == Dict(:l => "a")
    @test style_kwargs((:t => :c), sg) == Dict(:m => "c")
    @test style_kwargs([(:s => :a), (:t => :c)], sg) == Dict(:l => "overwrite!", :m => "c")
    sg = Dict(
        (:s => :a) => Dict(:l => "a"),
        (:s => :b) => Dict(:l => "b"),
        (:t => :c) => Dict(
            :m => "c",
            (:s => :a) =>
                Dict(:l => "overwrite!", (:s => :a) => Dict(:l => "doubleoverwrite!!")),
        ),
    )
    @test style_kwargs((:s => :a), sg) == Dict(:l => "a")
    @test style_kwargs((:t => :c), sg) == Dict(:m => "c")
    @test style_kwargs([(:s => :a), (:t => :c)], sg) ==
        Dict(:l => "doubleoverwrite!!", :m => "c")

    # basic test to see each one runs
    function random_solve_time(dict)
        if dict["speed"] == :slow
            dict["solve_time"] = rand() * 8
        elseif dict["speed"] == :medium
            dict["solve_time"] = rand() * 5
        elseif dict["speed"] == :fast
            dict["solve_time"] = rand() * 3
        else
            dict["solve_time"] = 0
        end
        return dict
    end

    experiment = Dict(
        "test!" => 1:100,
        "speed!" => [:slow, :medium, :fast],
        "motivation!" => [:low, :high],
        "save_results" => false,
    )
    df = run(experiment, random_solve_time)
    @test nrow(df) == 600
    identifiers = [:speed, :motivation]
    solve_time = :solve_time
    for plot_type in PLOT_TYPES
        plot(plot_type(df, identifiers, solve_time))
        @test true
    end
end
